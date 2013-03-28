with System.Machine_Code;

with SK.KC;
with SK.VMX;
with SK.Constants;
with SK.Subjects;

package body SK.Dump
is

   -------------------------------------------------------------------------

   procedure Dump_Registers
     (GPR : CPU.Registers_Type;
      RIP : Word64; CS  : Word64; RFL : Word64; RSP : Word64; SS  : Word64;
      CR0 : Word64; CR2 : Word64; CR3 : Word64; CR4 : Word64)
   is
   begin
      KC.Put_String ("RIP: ");
      KC.Put_Word64 (Item => RIP);
      KC.Put_String (" CS : ");
      KC.Put_Word16 (Item => Word16 (CS));
      KC.New_Line;
      KC.Put_String ("RSP: ");
      KC.Put_Word64 (Item => RSP);
      KC.Put_String (" SS : ");
      KC.Put_Word16 (Item => Word16 (SS));
      KC.New_Line;

      KC.Put_String (Item => "RAX: ");
      KC.Put_Word64 (Item => GPR.RAX);
      KC.Put_String (Item => " RBX: ");
      KC.Put_Word64 (Item => GPR.RBX);
      KC.Put_String (Item => " RCX: ");
      KC.Put_Word64 (Item => GPR.RCX);
      KC.New_Line;

      KC.Put_String (Item => "RDX: ");
      KC.Put_Word64 (Item => GPR.RDX);
      KC.Put_String (Item => " RSI: ");
      KC.Put_Word64 (Item => GPR.RSI);
      KC.Put_String (Item => " RDI: ");
      KC.Put_Word64 (Item => GPR.RDI);
      KC.New_Line;

      KC.Put_String (Item => "RBP: ");
      KC.Put_Word64 (Item => GPR.RBP);
      KC.Put_String (Item => " R08: ");
      KC.Put_Word64 (Item => GPR.R08);
      KC.Put_String (Item => " R09: ");
      KC.Put_Word64 (Item => GPR.R09);
      KC.New_Line;

      KC.Put_String (Item => "R10: ");
      KC.Put_Word64 (Item => GPR.R10);
      KC.Put_String (Item => " R11: ");
      KC.Put_Word64 (Item => GPR.R11);
      KC.Put_String (Item => " R12: ");
      KC.Put_Word64 (Item => GPR.R12);
      KC.New_Line;

      KC.Put_String (Item => "R13: ");
      KC.Put_Word64 (Item => GPR.R13);
      KC.Put_String (Item => " R14: ");
      KC.Put_Word64 (Item => GPR.R14);
      KC.Put_String (Item => " R15: ");
      KC.Put_Word64 (Item => GPR.R15);
      KC.New_Line;

      KC.Put_String (Item => "CR0: ");
      KC.Put_Word64 (Item => CR0);
      KC.Put_String (Item => " CR2: ");
      KC.Put_Word64 (Item => CR2);
      KC.Put_String (Item => " CR3: ");
      KC.Put_Word64 (Item => CR3);
      KC.New_Line;

      KC.Put_String (Item => "CR4: ");
      KC.Put_Word64 (Item => CR4);
      KC.Put_String (" EFL: ");
      KC.Put_Word32 (Item => Word32 (RFL));
      KC.New_Line;
   end Dump_Registers;
   pragma Inline_Always (Dump_Registers);

   -------------------------------------------------------------------------

   procedure Print_State (Subject : Skp.Subject_Id_Type)
   is
      RIP, RSP, CS, SS, CR0, CR3, CR4, RFL : Word64;
      State : constant Subjects.State_Type
        := Subjects.Get_State (Id => Subject);
   begin
      VMX.VMCS_Read (Field => Constants.GUEST_RIP,
                     Value => RIP);
      VMX.VMCS_Read (Field => Constants.GUEST_RSP,
                     Value => RSP);
      VMX.VMCS_Read (Field => Constants.GUEST_SEL_CS,
                     Value => CS);
      VMX.VMCS_Read (Field => Constants.GUEST_SEL_SS,
                     Value => SS);
      VMX.VMCS_Read (Field => Constants.GUEST_CR0,
                     Value => CR0);
      VMX.VMCS_Read (Field => Constants.GUEST_CR3,
                     Value => CR3);
      VMX.VMCS_Read (Field => Constants.GUEST_CR4,
                     Value => CR4);
      VMX.VMCS_Read (Field => Constants.GUEST_RFLAGS,
                     Value => RFL);

      Dump_Registers (GPR => State.Regs,
                      RIP => RIP,
                      CS  => CS,
                      RFL => RFL,
                      RSP => RSP,
                      SS  => SS,
                      CR0 => CR0,
                      CR2 => 0,
                      CR3 => CR3,
                      CR4 => CR4);
      KC.New_Line;
   end Print_State;

   -------------------------------------------------------------------------

   procedure Print_State (Context : Isr_Context_Type)
   is
      CR0, CR2, CR3, CR4 : Word64;
   begin
      System.Machine_Code.Asm
        (Template => "movq %%cr0, %0",
         Outputs  => (Word64'Asm_Output ("=r", CR0)),
         Volatile => True);
      System.Machine_Code.Asm
        (Template => "movq %%cr2, %0",
         Outputs  => (Word64'Asm_Output ("=r", CR2)),
         Volatile => True);
      System.Machine_Code.Asm
        (Template => "movq %%cr3, %0",
         Outputs  => (Word64'Asm_Output ("=r", CR3)),
         Volatile => True);
      System.Machine_Code.Asm
        (Template => "movq %%cr4, %0",
         Outputs  => (Word64'Asm_Output ("=r", CR4)),
         Volatile => True);

      KC.Put_Line ("[KERNEL PANIC]");

      KC.Put_String ("Vector: ");
      KC.Put_Byte (Item => Byte (Context.Vector));
      KC.Put_String (", Error: ");
      KC.Put_Word64 (Item => Context.Error_Code);
      KC.New_Line;
      KC.New_Line;

      Dump_Registers (GPR => Context.GPR,
                      RIP => Context.RIP,
                      CS  => Context.CS,
                      RFL => Context.RFLAGS,
                      RSP => Context.RSP,
                      SS  => Context.SS,
                      CR0 => CR0,
                      CR2 => CR2,
                      CR3 => CR3,
                      CR4 => CR4);

      CPU.Hlt;
   end Print_State;

end SK.Dump;
