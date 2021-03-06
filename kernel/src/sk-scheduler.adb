--
--  Copyright (C) 2013-2015  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2013-2015  Adrian-Ken Rueegsegger <ken@codelabs.ch>
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--

with Skp.Interrupts;
with Skp.Scheduling;
with Skp.Subjects;

with SK.VMX;
with SK.Constants;
with SK.CPU;
with SK.Apic;
with SK.Dump;

package body SK.Scheduler
is

   -------------------------------------------------------------------------

   --  Inject pending event into subject identified by ID.
   procedure Inject_Event (Subject_Id : Skp.Subject_Id_Type)
   with
      Global  => (Input  => Subjects.State,
                  In_Out => (Events.State, X86_64.State)),
      Depends =>
        ((Events.State, X86_64.State) =>
            (Events.State, Subjects.State, Subject_Id, X86_64.State))
   is
      RFLAGS        : SK.Word64;
      Intr_State    : SK.Word64;
      Event         : SK.Byte;
      Event_Present : Boolean;
      Event_Pending : Boolean;
   begin
      RFLAGS := Subjects.Get_RFLAGS (Id => Subject_Id);

      --  Check guest interruptibility state (see Intel SDM Vol. 3C, chapter
      --  24.4.2).

      VMX.VMCS_Read (Field => Constants.GUEST_INTERRUPTIBILITY,
                     Value => Intr_State);

      if Intr_State = 0
        and then SK.Bit_Test
          (Value => RFLAGS,
           Pos   => Constants.RFLAGS_IF_FLAG)
      then
         Events.Consume_Event (Subject => Subject_Id,
                               Found   => Event_Present,
                               Event   => Event);

         if Event_Present then
            VMX.VMCS_Write
              (Field => Constants.VM_ENTRY_INTERRUPT_INFO,
               Value => Constants.VM_INTERRUPT_INFO_VALID + SK.Word64 (Event));
         end if;
      end if;

      Events.Has_Pending_Events (Subject       => Subject_Id,
                                 Event_Pending => Event_Pending);

      if Event_Pending then
         VMX.VMCS_Set_Interrupt_Window (Value => True);
      end if;
   end Inject_Event;

   -------------------------------------------------------------------------

   --  Perform subject handover from the currently active to the new subject.
   procedure Subject_Handover
     (New_Id   : Skp.Subject_Id_Type;
      New_VMCS : SK.Word64)
   with
      Global  => (In_Out => (CPU_Global.State, Subjects_Sinfo.State,
                             X86_64.State)),
      Depends => (CPU_Global.State     =>+ New_Id,
                  X86_64.State         =>+ New_VMCS,
                  Subjects_Sinfo.State =>+ (CPU_Global.State, New_Id))
   is
      Current_Sched_Group : constant Skp.Scheduling.Scheduling_Group_Range
        := Skp.Scheduling.Get_Group_ID
          (CPU_ID   => CPU_Global.CPU_ID,
           Major_ID => CPU_Global.Get_Current_Major_Frame_ID,
           Minor_ID => CPU_Global.Get_Current_Minor_Frame_ID);
   begin

      --  Transfer minor frame start/end values to sinfo region of next subject
      --  in the current scheduling group.

      Subjects_Sinfo.Copy_Scheduling_Info
        (Src_Id => CPU_Global.Get_Subject_ID (Group => Current_Sched_Group),
         Dst_Id => New_Id);

      CPU_Global.Set_Subject_ID
        (Group      => Current_Sched_Group,
         Subject_ID => New_Id);

      VMX.Load (VMCS_Address => New_VMCS);
   end Subject_Handover;

   -------------------------------------------------------------------------

   --  Update scheduling information. If the end of the current major frame is
   --  reached the major frame start time is updated by adding the period of
   --  the just expired major frame to the current start value. Additionally,
   --  the minor frame index is reset and the major frame is switched to the
   --  one set by Tau0.
   --  On regular minor frame switches the minor frame index is incremented by
   --  one.
   --  The current subject parameter is used to determine whether a new VMCS
   --  must be loaded, i.e. the next, to-be scheduled subject is not the same.
   procedure Update_Scheduling_Info (Current_Subject : Skp.Subject_Id_Type)
   with
      Global  =>
        (Input  => Tau0_Interface.State,
         In_Out => (CPU_Global.State, Events.State, MP.Barrier, Timers.State,
                    Subjects_Sinfo.State, X86_64.State)),
      Depends =>
        ((Timers.State,
          Events.State)         =>+ (Current_Subject, Tau0_Interface.State,
                                     CPU_Global.State, Timers.State,
                                     X86_64.State),
         (CPU_Global.State,
          MP.Barrier,
          Subjects_Sinfo.State) =>+ (CPU_Global.State, Tau0_Interface.State),
         X86_64.State           =>+ (CPU_Global.State, Tau0_Interface.State,
                                     Current_Subject))
   is
      use type Skp.Scheduling.Major_Frame_Range;
      use type Skp.Scheduling.Minor_Frame_Range;
      use type Skp.Scheduling.Barrier_Index_Range;

      Current_Major_ID : constant Skp.Scheduling.Major_Frame_Range
        := CPU_Global.Get_Current_Major_Frame_ID;
      Current_Minor_ID : constant Skp.Scheduling.Minor_Frame_Range
        := CPU_Global.Get_Current_Minor_Frame_ID;

      --  Save current major frame CPU cycles for schedule info export.
      Current_Major_Frame_Start : constant SK.Word64
        := CPU_Global.Get_Current_Major_Start_Cycles;

      Next_Minor_ID   : Skp.Scheduling.Minor_Frame_Range;
      Next_Subject_ID : Skp.Subject_Id_Type;
   begin
      if Current_Minor_ID < CPU_Global.Get_Current_Major_Length then

         --  Sync on minor frame barrier if necessary and switch to next
         --  minor frame in current major frame.

         declare
            Current_Barrier : constant Skp.Scheduling.Barrier_Index_Range
              := Skp.Scheduling.Get_Barrier
                (CPU_ID   => CPU_Global.CPU_ID,
                 Major_ID => Current_Major_ID,
                 Minor_ID => Current_Minor_ID);
         begin
            if Current_Barrier /= Skp.Scheduling.No_Barrier then
               MP.Wait_On_Minor_Frame_Barrier (Index => Current_Barrier);
            end if;
         end;

         Next_Minor_ID := Current_Minor_ID + 1;
      else

         --  Switch to first minor frame in next major frame.

         Next_Minor_ID := Skp.Scheduling.Minor_Frame_Range'First;

         MP.Wait_For_All;
         if CPU_Global.Is_BSP then
            declare

               --  Next major frame ID used to access the volatile New_Major
               --  variable. Do not move the declaration outside of this scope
               --  as it is only updated on the BSP. All other CPUs must get
               --  the value from CPU_Global.

               Next_Major_ID    : Skp.Scheduling.Major_Frame_Range;
               Next_Major_Start : SK.Word64;
            begin
               Tau0_Interface.Get_Major_Frame (ID => Next_Major_ID);

               --  Increment major frame start time by period of major frame
               --  that just ended.

               Next_Major_Start := CPU_Global.Get_Current_Major_Start_Cycles
                 + Skp.Scheduling.Major_Frames (Current_Major_ID).Period;

               CPU_Global.Set_Current_Major_Frame (ID => Next_Major_ID);
               CPU_Global.Set_Current_Major_Start_Cycles
                 (TSC_Value => Next_Major_Start);

               if Current_Major_ID /= Next_Major_ID then
                  MP.Set_Minor_Frame_Barrier_Config
                    (Config => Skp.Scheduling.Major_Frames
                       (Next_Major_ID).Barrier_Config);
               end if;
            end;
         end if;
         MP.Wait_For_All;
      end if;

      --  Subject switch.

      Next_Subject_ID := CPU_Global.Get_Subject_ID
        (Group => Skp.Scheduling.Get_Group_ID
           (CPU_ID   => CPU_Global.CPU_ID,
            Major_ID => CPU_Global.Get_Current_Major_Frame_ID,
            Minor_ID => Next_Minor_ID));
      if Current_Subject /= Next_Subject_ID then

         --  New minor frame contains different subject -> Load VMCS.

         VMX.Load (VMCS_Address => Skp.Subjects.Get_VMCS_Address
                   (Subject_Id => Next_Subject_ID));
      end if;

      --  Update current minor frame globally.

      CPU_Global.Set_Current_Minor_Frame (ID => Next_Minor_ID);

      --  Check and possibly inject timer into subject.

      declare
         Timer_Value  : SK.Word64;
         Timer_Vector : SK.Byte;
      begin

         --  Inject expired timer.

         Timers.Get_Timer (Subject => Next_Subject_ID,
                           Value   => Timer_Value,
                           Vector  => Timer_Vector);
         if Timer_Value <= CPU.RDTSC64 then
            Events.Insert_Event (Subject => Next_Subject_ID,
                                 Event   => Timer_Vector);
            Timers.Clear_Timer (Subject => Next_Subject_ID);
         end if;
      end;

      --  Export scheduling information to subject.

      Subjects_Sinfo.Export_Scheduling_Info
        (Id                 => Next_Subject_ID,
         TSC_Schedule_Start => Current_Major_Frame_Start +
           Skp.Scheduling.Get_Deadline
             (CPU_ID   => CPU_Global.CPU_ID,
              Major_ID => Current_Major_ID,
              Minor_ID => Current_Minor_ID),
         TSC_Schedule_End   => CPU_Global.Get_Current_Major_Start_Cycles +
           Skp.Scheduling.Get_Deadline
             (CPU_ID   => CPU_Global.CPU_ID,
              Major_ID => CPU_Global.Get_Current_Major_Frame_ID,
              Minor_ID => Next_Minor_ID));
   end Update_Scheduling_Info;

   -------------------------------------------------------------------------

   procedure Set_VMX_Exit_Timer
   is
      Now      : constant SK.Word64 := CPU.RDTSC64;
      Deadline : SK.Word64;
      Cycles   : SK.Word64;
   begin

      --  Absolute deadline is given by start of major frame plus the number of
      --  CPU cycles until the end of the current minor frame relative to major
      --  frame start.

      Deadline := CPU_Global.Get_Current_Major_Start_Cycles +
        Skp.Scheduling.Get_Deadline
          (CPU_ID   => CPU_Global.CPU_ID,
           Major_ID => CPU_Global.Get_Current_Major_Frame_ID,
           Minor_ID => CPU_Global.Get_Current_Minor_Frame_ID);

      if Deadline > Now then
         Cycles := Deadline - Now;
      else
         Cycles := 0;
      end if;

      VMX.VMCS_Write (Field => Constants.GUEST_VMX_PREEMPT_TIMER,
                      Value => Cycles / 2 ** Skp.Scheduling.VMX_Timer_Rate);
   end Set_VMX_Exit_Timer;

   -------------------------------------------------------------------------

   procedure Init
   is
      use type Skp.CPU_Range;

      Now                : constant SK.Word64 := CPU.RDTSC64;
      Initial_Subject_ID : Skp.Subject_Id_Type;
      Initial_VMCS_Addr  : SK.Word64 := 0;
      Controls           : Skp.Subjects.VMX_Controls_Type;
      VMCS_Addr          : SK.Word64;
   begin
      CPU_Global.Set_Scheduling_Groups
        (Data => Skp.Scheduling.Scheduling_Groups);

      Initial_Subject_ID := CPU_Global.Get_Current_Subject_ID;

      --  Setup VMCS and state of subjects running on this logical CPU.

      for I in Skp.Subject_Id_Type loop
         if Skp.Subjects.Get_CPU_Id (Subject_Id => I) = CPU_Global.CPU_ID then

            --  Initialize subject state.

            Subjects.Clear_State (Id => I);

            --  Initialize subject timer.

            Timers.Init_Timer (Subject => I);

            --  VMCS

            VMCS_Addr := Skp.Subjects.Get_VMCS_Address (Subject_Id => I);
            Controls  := Skp.Subjects.Get_VMX_Controls (Subject_Id => I);

            VMX.Clear (VMCS_Address => VMCS_Addr);
            VMX.Load  (VMCS_Address => VMCS_Addr);
            VMX.VMCS_Setup_Control_Fields
              (IO_Bitmap_Address  => Skp.Subjects.Get_IO_Bitmap_Address
                 (Subject_Id => I),
               MSR_Bitmap_Address => Skp.Subjects.Get_MSR_Bitmap_Address
                 (Subject_Id => I),
               MSR_Store_Address  => Skp.Subjects.Get_MSR_Store_Address
                 (Subject_Id => I),
               MSR_Count          => Skp.Subjects.Get_MSR_Count
                 (Subject_Id => I),
               Ctls_Exec_Pin      => Controls.Exec_Pin,
               Ctls_Exec_Proc     => Controls.Exec_Proc,
               Ctls_Exec_Proc2    => Controls.Exec_Proc2,
               Ctls_Exit          => Controls.Exit_Ctrls,
               Ctls_Entry         => Controls.Entry_Ctrls,
               CR0_Mask           => Skp.Subjects.Get_CR0_Mask
                 (Subject_Id => I),
               CR4_Mask           => Skp.Subjects.Get_CR4_Mask
                 (Subject_Id => I),
               Exception_Bitmap   => Skp.Subjects.Get_Exception_Bitmap
                 (Subject_Id => I));
            VMX.VMCS_Setup_Host_Fields;
            VMX.VMCS_Setup_Guest_Fields
              (PML4_Address => Skp.Subjects.Get_PML4_Address (Subject_Id => I),
               EPT_Pointer  => Skp.Subjects.Get_EPT_Pointer (Subject_Id => I),
               CR0_Value    => Skp.Subjects.Get_CR0 (Subject_Id => I),
               CR4_Value    => Skp.Subjects.Get_CR4 (Subject_Id => I),
               CS_Access    => Skp.Subjects.Get_CS_Access (Subject_Id => I));

            if Initial_Subject_ID = I then
               Initial_VMCS_Addr := VMCS_Addr;
               Subjects_Sinfo.Export_Scheduling_Info
                 (Id                 => I,
                  TSC_Schedule_Start => Now,
                  TSC_Schedule_End   => Now + Skp.Scheduling.Get_Deadline
                    (CPU_ID   => CPU_Global.CPU_ID,
                     Major_ID => Skp.Scheduling.Major_Frame_Range'First,
                     Minor_ID => Skp.Scheduling.Minor_Frame_Range'First));
            end if;

            --  State

            Subjects.Set_RIP
              (Id    => I,
               Value => Skp.Subjects.Get_Entry_Point (Subject_Id => I));
            Subjects.Set_RSP
              (Id    => I,
               Value => Skp.Subjects.Get_Stack_Address (Subject_Id => I));
            Subjects.Set_CR0
              (Id    => I,
               Value => Skp.Subjects.Get_CR0 (Subject_Id => I));
         end if;
      end loop;

      --  Load first subject and set preemption timer ticks.

      VMX.Load (VMCS_Address => Initial_VMCS_Addr);

      if CPU_Global.Is_BSP then

         --  Set minor frame barriers config.

         MP.Set_Minor_Frame_Barrier_Config
           (Config => Skp.Scheduling.Major_Frames
              (Skp.Scheduling.Major_Frame_Range'First).Barrier_Config);

         --  Set initial major frame start time to now.

         CPU_Global.Set_Current_Major_Start_Cycles (TSC_Value => Now);
      end if;
   end Init;

   -------------------------------------------------------------------------

   --  Handle hypercall with given event number.
   procedure Handle_Hypercall
     (Current_Subject : Skp.Subject_Id_Type;
      Event_Nr        : SK.Word64)
   with
      Global  =>
        (In_Out => (CPU_Global.State, Events.State, Subjects.State,
                    Subjects_Sinfo.State, X86_64.State)),
      Depends =>
        ((CPU_Global.State,
          Events.State,
          X86_64.State)       =>+ (Current_Subject, Event_Nr),
         Subjects.State       =>+ Current_Subject,
         Subjects_Sinfo.State =>+ (CPU_Global.State, Current_Subject,
                                   Event_Nr))
   is
      use type Skp.Dst_Vector_Range;
      use type Skp.Subjects.Event_Entry_Type;

      Event       : Skp.Subjects.Event_Entry_Type;
      Dst_CPU     : Skp.CPU_Range;
      Valid_Event : Boolean;
      RIP         : SK.Word64;
   begin
      Valid_Event := Event_Nr <= SK.Word64 (Skp.Subjects.Event_Range'Last);

      if Valid_Event then
         Event := Skp.Subjects.Get_Event
           (Subject_Id => Current_Subject,
            Event_Nr   => Skp.Subjects.Event_Range (Event_Nr));

         if Event.Dst_Subject /= Skp.Invalid_Subject then
            if Event.Dst_Vector /= Skp.Invalid_Vector then
               Events.Insert_Event (Subject => Event.Dst_Subject,
                                    Event   => SK.Byte (Event.Dst_Vector));

               if Event.Send_IPI then
                  Dst_CPU := Skp.Subjects.Get_CPU_Id
                    (Subject_Id => Event.Dst_Subject);
                  Apic.Send_IPI (Vector  => SK.Constants.IPI_Vector,
                                 Apic_Id => SK.Byte (Dst_CPU));
               end if;
            end if;

            if Event.Handover then
               Subject_Handover
                 (New_Id   => Event.Dst_Subject,
                  New_VMCS => Skp.Subjects.Get_VMCS_Address
                    (Subject_Id => Event.Dst_Subject));
            end if;
         end if;
      end if;

      pragma Debug
        (not Valid_Event or Event = Skp.Subjects.Null_Event,
         Dump.Print_Spurious_Event
           (Current_Subject => Current_Subject,
            Event_Nr        => Event_Nr));

      RIP := Subjects.Get_RIP (Id => Current_Subject);
      RIP := RIP + Subjects.Get_Instruction_Length (Id => Current_Subject);
      Subjects.Set_RIP (Id    => Current_Subject,
                        Value => RIP);
   end Handle_Hypercall;

   -------------------------------------------------------------------------

   --  Handle external interrupt request with given vector.
   procedure Handle_Irq (Vector : SK.Byte)
   with
      Global  => (In_Out => (Events.State, VTd.State, X86_64.State)),
      Depends => ((Events.State, VTd.State) =>+ Vector, X86_64.State =>+ null)
   is
      Vect_Nr : Skp.Interrupts.Remapped_Vector_Type;
      Route   : Skp.Interrupts.Vector_Route_Type;
   begin
      if Vector >= Skp.Interrupts.Remap_Offset then
         if Vector = SK.Constants.VTd_Fault_Vector then
            VTd.Process_Fault;
         else
            Vect_Nr := Skp.Interrupts.Remapped_Vector_Type (Vector);
            Route   := Skp.Interrupts.Vector_Routing (Vect_Nr);
            if Route.Subject in Skp.Subject_Id_Type then
               Events.Insert_Event
                 (Subject => Route.Subject,
                  Event   => SK.Byte (Route.Vector));
            end if;

            pragma Debug
              (Route.Subject not in Skp.Subject_Id_Type
               and then Vector /= SK.Constants.IPI_Vector,
               Dump.Print_Message_8
                 (Msg  => "Spurious IRQ vector",
                  Item => Vector));
         end if;
      end if;

      pragma Debug (Vector < Skp.Interrupts.Remap_Offset,
                    Dump.Print_Message_8 (Msg  => "IRQ with invalid vector",
                                          Item => Vector));
      Apic.EOI;
   end Handle_Irq;

   -------------------------------------------------------------------------

   --  Handle trap with given number using trap table of current subject.
   procedure Handle_Trap
     (Current_Subject : Skp.Subject_Id_Type;
      Trap_Nr         : SK.Word64)
   with
      Global  =>
        (In_Out => (CPU_Global.State, Events.State, Subjects_Sinfo.State,
                    X86_64.State)),
      Depends =>
        ((CPU_Global.State,
          Events.State,
          X86_64.State)       =>+ (Current_Subject, Trap_Nr),
         Subjects_Sinfo.State =>+ (CPU_Global.State, Current_Subject, Trap_Nr))
   is
      use type Skp.Dst_Vector_Range;

      Trap_Entry : Skp.Subjects.Trap_Entry_Type;

      ----------------------------------------------------------------------

      procedure Panic_No_Trap_Handler
      with
         Global  => (In_Out => (X86_64.State)),
         Depends => (X86_64.State =>+ null),
         No_Return
      is
      begin
         pragma Debug (Dump.Print_Message_16
                       (Msg  => ">>> No handler for trap",
                        Item => Word16 (Trap_Nr)));
         pragma Debug (Dump.Print_Subject (Subject_Id => Current_Subject));

         CPU.Panic;
      end Panic_No_Trap_Handler;

      ----------------------------------------------------------------------

      procedure Panic_Unknown_Trap
      with
         Global  => (In_Out => (X86_64.State)),
         Depends => (X86_64.State =>+ null),
         No_Return
      is
      begin
         pragma Debug (Dump.Print_Message_64 (Msg  => ">>> Unknown trap",
                                              Item => Trap_Nr));
         pragma Debug (Dump.Print_Subject (Subject_Id => Current_Subject));

         CPU.Panic;
      end Panic_Unknown_Trap;

   begin
      if not (Trap_Nr <= SK.Word64 (Skp.Subjects.Trap_Range'Last)) then
         Panic_Unknown_Trap;
      end if;

      Trap_Entry := Skp.Subjects.Get_Trap
        (Subject_Id => Current_Subject,
         Trap_Nr    => Skp.Subjects.Trap_Range (Trap_Nr));

      if Trap_Entry.Dst_Subject = Skp.Invalid_Subject then
         Panic_No_Trap_Handler;
      end if;

      if Trap_Entry.Dst_Vector < Skp.Invalid_Vector then
         Events.Insert_Event
           (Subject => Trap_Entry.Dst_Subject,
            Event   => SK.Byte (Trap_Entry.Dst_Vector));
      end if;

      --  Handover to trap handler subject.

      Subject_Handover
        (New_Id   => Trap_Entry.Dst_Subject,
         New_VMCS => Skp.Subjects.Get_VMCS_Address
           (Subject_Id => Trap_Entry.Dst_Subject));
   end Handle_Trap;

   -------------------------------------------------------------------------

   procedure Handle_Vmx_Exit (Subject_Registers : in out SK.CPU_Registers_Type)
   is
      Exit_Status     : SK.Word64;
      Current_Subject : Skp.Subject_Id_Type;

      ----------------------------------------------------------------------

      procedure Panic_Exit_Failure
      with
         Global  => (In_Out => (X86_64.State)),
         Depends => (X86_64.State =>+ null),
         No_Return
      is
      begin
         pragma Debug (Dump.Print_VMX_Entry_Error
                       (Current_Subject => Current_Subject,
                        Exit_Reason     => Exit_Status));

         CPU.Panic;
      end Panic_Exit_Failure;
   begin
      Current_Subject := CPU_Global.Get_Current_Subject_ID;

      VMX.VMCS_Read (Field => Constants.VMX_EXIT_REASON,
                     Value => Exit_Status);

      if SK.Bit_Test (Value => Exit_Status,
                      Pos   => Constants.VM_EXIT_ENTRY_FAILURE)
      then
         Panic_Exit_Failure;
      end if;

      Subjects.Save_State (Id   => Current_Subject,
                           Regs => Subject_Registers);
      FPU.Save_State (ID => Current_Subject);

      if Exit_Status = Constants.EXIT_REASON_EXTERNAL_INT then
         Handle_Irq (Vector => SK.Byte'Mod (Subjects.Get_Interrupt_Info
                     (Id => Current_Subject)));
      elsif Exit_Status = Constants.EXIT_REASON_VMCALL then
         Handle_Hypercall (Current_Subject => Current_Subject,
                           Event_Nr        => Subject_Registers.RAX);
      elsif Exit_Status = Constants.EXIT_REASON_TIMER_EXPIRY then

         --  Minor frame ticks consumed, update scheduling information.

         Update_Scheduling_Info (Current_Subject => Current_Subject);
      elsif Exit_Status = Constants.EXIT_REASON_INTERRUPT_WINDOW then

         --  Resume subject to inject pending event.

         VMX.VMCS_Set_Interrupt_Window (Value => False);
      else
         Handle_Trap (Current_Subject => Current_Subject,
                      Trap_Nr         => Exit_Status);
      end if;

      Current_Subject := CPU_Global.Get_Current_Subject_ID;

      Inject_Event (Subject_Id => Current_Subject);

      Set_VMX_Exit_Timer;
      FPU.Restore_State (ID => Current_Subject);
      Subjects.Restore_State
        (Id   => Current_Subject,
         Regs => Subject_Registers);
   end Handle_Vmx_Exit;

end SK.Scheduler;
