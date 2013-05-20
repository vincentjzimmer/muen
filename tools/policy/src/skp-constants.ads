package Skp.Constants
is

   --  Pin-Base VM-Execution Controls

   VM_CTRL_EXT_INT_EXITING : constant := 16#0000_0001#;
   VM_CTRL_PREEMPT_TIMER   : constant := 16#0000_0040#;

   --  Primary Processor-Based VM-Execution Controls

   VM_CTRL_EXIT_HLT        : constant := 16#0000_0080#;
   VM_CTRL_EXIT_INVLPG     : constant := 16#0000_0200#;
   VM_CTRL_EXIT_MWAIT      : constant := 16#0000_0400#;
   VM_CTRL_EXIT_RDPMC      : constant := 16#0000_0800#;
   VM_CTRL_EXIT_RDTSC      : constant := 16#0000_1000#;
   VM_CTRL_EXIT_CR3_LOAD   : constant := 16#0000_8000#;
   VM_CTRL_EXIT_CR3_STORE  : constant := 16#0001_0000#;
   VM_CTRL_EXIT_CR8_LOAD   : constant := 16#0008_0000#;
   VM_CTRL_EXIT_CR8_STORE  : constant := 16#0010_0000#;
   VM_CTRL_EXIT_MOV_DR     : constant := 16#0080_0000#;
   VM_CTRL_IO_BITMAPS      : constant := 16#0200_0000#;
   VM_CTRL_MSR_BITMAPS     : constant := 16#1000_0000#;
   VM_CTRL_EXIT_MONITOR    : constant := 16#2000_0000#;
   VM_CTRL_SECONDARY_PROC  : constant := 16#8000_0000#;

   --  Secondary Processor-Based VM-Execution Controls

   VM_CTRL_ENABLE_EPT      : constant := 16#0000_0002#;
   VM_CTRL_EXIT_DT         : constant := 16#0000_0004#;
   VM_CTRL_EXIT_WBINVD     : constant := 16#0000_0040#;

   --  VM-Exit Controls

   VM_CTRL_EXIT_IA32E_MODE : constant := 16#0000_0200#;
   VM_CTRL_EXIT_ACK_INT    : constant := 16#0000_8000#;
   VM_CTRL_EXIT_SAVE_TIMER : constant := 16#0040_0000#;

   --  VM-Entry Controls

   VM_CTRL_ENTR_IA32E_MODE : constant := 16#0000_0200#;

end Skp.Constants;