package Skp.Kernel
is

   Stack_Address       : constant := 16#0011_4000#;
   CPU_Store_Address   : constant := 16#0011_6000#;
   Tau0_Iface_Address  : constant := 16#001f_f000#;
   Subj_States_Address : constant := 16#001e_0000#;
   Subj_Timers_Address : constant := 16#0040_0000#;
   IO_Apic_Address     : constant := 16#001f_c000#;
   Subj_Sinfo_Address  : constant := 16#0050_0000#;
   Subj_Sinfo_Size     : constant := 16#7000#;

end Skp.Kernel;
