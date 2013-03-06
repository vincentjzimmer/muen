with System.Storage_Elements;

with SK.Constants;
with SK.Console;
with SK.Console_VGA;

package body SK.Subjects
is

   type Subject_Array is array (Index_Type) of State_Type;

   --  Descriptors used to manage subjects.
   Descriptors : Subject_Array;

   --  Test subject console width and height.
   subtype Width_Type  is Natural range 1 .. 80;
   subtype Height_Type is Natural range 1 .. 12;

   --# accept Warning, 350, Guest_Stack_Address, "Imported from Linker";
   Guest_Stack_Address : SK.Word64;
   pragma Import (C, Guest_Stack_Address, "guest_stack_pointer");
   --# end accept;

   --# accept Warning, 350, VMCS_Address, "Imported from Linker";
   VMCS_Address : SK.Word64;
   pragma Import (C, VMCS_Address, "vmcs_pointer");
   --# end accept;

   -------------------------------------------------------------------------

   function Get_State (Idx : Index_Type) return State_Type
   is
   begin
      return Descriptors (Idx);
   end Get_State;

   -------------------------------------------------------------------------

   procedure Set_State
     (Idx   : Index_Type;
      State : State_Type)
   is
   begin
      Descriptors (Idx) := State;
   end Set_State;

   -------------------------------------------------------------------------

   procedure Subject_Main_0
   is
      --# hide Subject_Main_0;

      package VGA is new SK.Console_VGA
        (Width_Type   => Width_Type,
         Height_Type  => Height_Type,
         Base_Address => System'To_Address (16#000b_8000#));

      package Text_IO is new SK.Console
        (Initialize      => VGA.Init,
         Output_New_Line => VGA.New_Line,
         Output_Char     => VGA.Put_Char);

      Name    : constant String := "Subject 0";
      Counter : SK.Word32       := 0;
      Idx     : Positive        := 1;
      Dlt     : Integer         := -1;
   begin
      Text_IO.Init;
      Text_IO.Put_Line (Item => Name);
      Text_IO.New_Line;

      for I in Name'Range loop
         Text_IO.Put_Char (Item => Character'Val (176));
      end loop;

      while True loop
         if Counter mod 2**19 = 0 then
            VGA.Set_Position (X => Integer (Idx - Dlt),
                              Y => 3);
            Text_IO.Put_Char (Item => Character'Val (176));
            if Idx = Name'Last then
               Dlt := -1;
            elsif Idx = Name'First then
               Dlt := 1;
            end if;
            VGA.Set_Position (X => Integer (Idx),
                              Y => 3);
            Text_IO.Put_Char (Item => Character'Val (178));
            Idx := Idx + Dlt;
         end if;
         Counter := Counter + 1;
      end loop;
   end Subject_Main_0;

   -------------------------------------------------------------------------

   procedure Subject_Main_1
   is
      --# hide Subject_Main_1;

      package VGA is new SK.Console_VGA
        (Width_Type   => Width_Type,
         Height_Type  => Height_Type,
         Base_Address => System'To_Address (16#000b_8820#));

      package Text_IO is new SK.Console
        (Initialize      => VGA.Init,
         Output_New_Line => VGA.New_Line,
         Output_Char     => VGA.Put_Char);

      Name    : constant String := "Subject 1";
      Counter : SK.Word32       := 0;
      Idx     : Positive        := 1;
      Dlt     : Integer         := -1;
   begin
      Text_IO.Init;
      Text_IO.Put_Line (Item => Name);
      Text_IO.New_Line;

      for I in Name'Range loop
         Text_IO.Put_Char (Item => Character'Val (176));
      end loop;

      while True loop
         if Counter mod 2**19 = 0 then
            VGA.Set_Position (X => Integer (Idx - Dlt),
                              Y => 3);
            Text_IO.Put_Char (Item => Character'Val (176));
            if Idx = Name'Last then
               Dlt := -1;
            elsif Idx = Name'First then
               Dlt := 1;
            end if;
            VGA.Set_Position (X => Integer (Idx),
                              Y => 3);
            Text_IO.Put_Char (Item => Character'Val (178));
            Idx := Idx + Dlt;
         end if;
         Counter := Counter + 1;
      end loop;
   end Subject_Main_1;

begin

   --# hide SK.Subjects;

   declare
      Revision, Unused_High, VMCS_Region0, VMCS_Region1 : SK.Word32;
      for VMCS_Region0'Address use System'To_Address (VMCS_Address);
      for VMCS_Region1'Address use System'To_Address (VMCS_Address + 4096);
   begin
      CPU.Get_MSR
        (Register => Constants.IA32_VMX_BASIC,
         Low      => Revision,
         High     => Unused_High);
      VMCS_Region0 := Revision;
      VMCS_Region1 := Revision;

      Descriptors (Descriptors'First)
        := State_Type'
          (Launched      => False,
           Regs          => CPU.Null_Regs,
           Stack_Address => Guest_Stack_Address,
           VMCS_Address  => VMCS_Address,
           Entry_Point   => SK.Word64
             (System.Storage_Elements.To_Integer
                (Value => Subject_Main_0'Address)));
      Descriptors (Descriptors'Last)
        := State_Type'
          (Launched      => False,
           Regs          => CPU.Null_Regs,
           Stack_Address => Guest_Stack_Address - 4096,
           VMCS_Address  => VMCS_Address        + 4096,
           Entry_Point   => SK.Word64
             (System.Storage_Elements.To_Integer
                (Value => Subject_Main_1'Address)));
   end;
end SK.Subjects;
