--
--  Copyright (C) 2013  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2013  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

package SK.Constants
is

   -----------------------
   -- Interrupt vectors --
   -----------------------

   VTd_Fault_Vector             : constant := 253;
   IPI_Vector                   : constant := 254;

   -----------
   -- Flags --
   -----------

   RFLAGS_CF_FLAG               : constant := 0;
   RFLAGS_ZF_FLAG               : constant := 6;
   RFLAGS_IF_FLAG               : constant := 9;
   RFLAGS_VM_FLAG               : constant := 17;

   CR0_PE_FLAG                  : constant := 0;
   CR0_PG_FLAG                  : constant := 0;

   CR4_VMXE_FLAG                : constant := 13;
   CR4_SMXE_FLAG                : constant := 14;
   CR4_XSAVE_FLAG               : constant := 18;

   XCR0_FPU_STATE_FLAG          : constant := 0;
   XCR0_SSE_STATE_FLAG          : constant := 1;
   XCR0_AVX_STATE_FLAG          : constant := 2;

   CPUID_FEATURE_VMX_FLAG       : constant := 5;
   CPUID_FEATURE_INVARIANT_TSC  : constant := 8;
   CPUID_FEATURE_LOCAL_APIC     : constant := 9;
   CPUID_FEATURE_X2APIC         : constant := 21;

   IA32_EFER_LMA_FLAG           : constant := 10;
   IA32_FCTRL_LOCKED_FLAG       : constant := 0;
   IA32_FCTRL_VMX_IN_SMX_FLAG   : constant := 1;
   IA32_FCTRL_VMX_FLAG          : constant := 2;

   ----------
   -- MSRs --
   ----------

   IA32_APIC_BASE               : constant := 16#1b#;
   IA32_FEATURE_CONTROL         : constant := 16#3a#;
   IA32_BIOS_SIGN_ID            : constant := 16#8b#;
   IA32_PMC0                    : constant := 16#c1#;
   IA32_PMC1                    : constant := 16#c2#;
   IA32_PMC2                    : constant := 16#c3#;
   IA32_PMC3                    : constant := 16#c4#;
   IA32_PMC4                    : constant := 16#c5#;
   IA32_PMC5                    : constant := 16#c6#;
   IA32_PMC6                    : constant := 16#c7#;
   IA32_PMC7                    : constant := 16#c8#;
   IA32_PERFEVTSEL0             : constant := 16#186#;
   IA32_PERFEVTSEL1             : constant := 16#187#;
   IA32_PERFEVTSEL2             : constant := 16#188#;
   IA32_PERFEVTSEL3             : constant := 16#189#;
   IA32_MISC_ENABLE             : constant := 16#1a0#;
   IA32_RTIT_CTL                : constant := 16#570#;
   IA32_EFER                    : constant := 16#c000_0080#;

   MSR_RAPL_POWER_UNIT          : constant := 16#606#;

   IA32_VMX_BASIC               : constant := 16#480#;
   IA32_VMX_PINBASED_CTLS       : constant := 16#481#;
   IA32_VMX_PROCBASED_CTLS      : constant := 16#482#;
   IA32_VMX_EXIT_CTLS           : constant := 16#483#;
   IA32_VMX_ENTRY_CTLS          : constant := 16#484#;
   IA32_VMX_CR0_FIXED0          : constant := 16#486#;
   IA32_VMX_CR0_FIXED1          : constant := 16#487#;
   IA32_VMX_CR4_FIXED0          : constant := 16#488#;
   IA32_VMX_CR4_FIXED1          : constant := 16#489#;
   IA32_VMX_PROCBASED_CTLS2     : constant := 16#48b#;
   IA32_VMX_TRUE_PINBASED_CTLS  : constant := 16#48d#;
   IA32_VMX_TRUE_PROCBASED_CTLS : constant := 16#48e#;
   IA32_VMX_TRUE_EXIT_CTLS      : constant := 16#48f#;
   IA32_VMX_TRUE_ENTRY_CTLS     : constant := 16#490#;

   ----------
   -- VMCS --
   ----------

   --  Control fields

   PIN_BASED_EXEC_CONTROL       : constant := 16#4000#;
   CPU_BASED_EXEC_CONTROL       : constant := 16#4002#;
   EXCEPTION_BITMAP             : constant := 16#4004#;
   VM_EXIT_CONTROLS             : constant := 16#400c#;
   VM_EXIT_MSR_STORE_COUNT      : constant := 16#400e#;
   VM_ENTRY_CONTROLS            : constant := 16#4012#;
   VM_ENTRY_MSR_LOAD_COUNT      : constant := 16#4014#;
   VM_ENTRY_INTERRUPT_INFO      : constant := 16#4016#;
   VM_ENTRY_EXC_ERROR_CODE      : constant := 16#4018#;
   VM_ENTRY_INSTRUCTION_LEN     : constant := 16#401a#;
   CPU_BASED_EXEC_CONTROL2      : constant := 16#401e#;
   VMX_INST_ERROR               : constant := 16#4400#;
   VMX_EXIT_REASON              : constant := 16#4402#;
   VMX_EXIT_INTR_INFO           : constant := 16#4404#;
   VMX_EXIT_INSTRUCTION_LEN     : constant := 16#440c#;
   CR0_MASK                     : constant := 16#6000#;
   CR4_MASK                     : constant := 16#6002#;
   CR0_READ_SHADOW              : constant := 16#6004#;
   CR4_READ_SHADOW              : constant := 16#6006#;
   VMX_EXIT_QUALIFICATION       : constant := 16#6400#;

   --  Host state fields

   HOST_SEL_ES                  : constant := 16#0c00#;
   HOST_SEL_CS                  : constant := 16#0c02#;
   HOST_SEL_SS                  : constant := 16#0c04#;
   HOST_SEL_DS                  : constant := 16#0c06#;
   HOST_SEL_FS                  : constant := 16#0c08#;
   HOST_SEL_GS                  : constant := 16#0c0a#;
   HOST_SEL_TR                  : constant := 16#0c0c#;
   HOST_IA32_EFER               : constant := 16#2c02#;
   HOST_CR0                     : constant := 16#6c00#;
   HOST_CR3                     : constant := 16#6c02#;
   HOST_CR4                     : constant := 16#6c04#;
   HOST_BASE_FS                 : constant := 16#6c06#;
   HOST_BASE_GS                 : constant := 16#6c08#;
   HOST_BASE_GDTR               : constant := 16#6c0c#;
   HOST_BASE_IDTR               : constant := 16#6c0e#;
   HOST_RSP                     : constant := 16#6c14#;
   HOST_RIP                     : constant := 16#6c16#;

   --  Guest state fields

   GUEST_SEL_ES                 : constant := 16#0800#;
   GUEST_SEL_CS                 : constant := 16#0802#;
   GUEST_SEL_SS                 : constant := 16#0804#;
   GUEST_SEL_DS                 : constant := 16#0806#;
   GUEST_SEL_TR                 : constant := 16#080e#;
   IO_BITMAP_A                  : constant := 16#2000#;
   IO_BITMAP_B                  : constant := 16#2002#;
   MSR_BITMAP                   : constant := 16#2004#;
   VM_EXIT_MSR_STORE_ADDRESS    : constant := 16#2006#;
   VM_ENTRY_MSR_LOAD_ADDRESS    : constant := 16#200a#;
   EPT_POINTER                  : constant := 16#201a#;
   GUEST_PHYSICAL_ADDRESS       : constant := 16#2400#;
   VMCS_LINK_POINTER            : constant := 16#2800#;
   GUEST_IA32_EFER              : constant := 16#2806#;
   GUEST_LIMIT_ES               : constant := 16#4800#;
   GUEST_LIMIT_CS               : constant := 16#4802#;
   GUEST_LIMIT_SS               : constant := 16#4804#;
   GUEST_LIMIT_DS               : constant := 16#4806#;
   GUEST_LIMIT_TR               : constant := 16#480e#;
   GUEST_LIMIT_GDTR             : constant := 16#4810#;
   GUEST_LIMIT_IDTR             : constant := 16#4812#;
   GUEST_ACCESS_RIGHTS_ES       : constant := 16#4814#;
   GUEST_ACCESS_RIGHTS_CS       : constant := 16#4816#;
   GUEST_ACCESS_RIGHTS_SS       : constant := 16#4818#;
   GUEST_ACCESS_RIGHTS_DS       : constant := 16#481a#;
   GUEST_ACCESS_RIGHTS_FS       : constant := 16#481c#;
   GUEST_ACCESS_RIGHTS_GS       : constant := 16#481e#;
   GUEST_ACCESS_RIGHTS_LDTR     : constant := 16#4820#;
   GUEST_ACCESS_RIGHTS_TR       : constant := 16#4822#;
   GUEST_INTERRUPTIBILITY       : constant := 16#4824#;
   GUEST_SYSENTER_CS            : constant := 16#482a#;
   GUEST_VMX_PREEMPT_TIMER      : constant := 16#482e#;
   GUEST_CR0                    : constant := 16#6800#;
   GUEST_CR3                    : constant := 16#6802#;
   GUEST_CR4                    : constant := 16#6804#;
   GUEST_FS_BASE                : constant := 16#680e#;
   GUEST_GS_BASE                : constant := 16#6810#;
   GUEST_BASE_GDTR              : constant := 16#6816#;
   GUEST_BASE_IDTR              : constant := 16#6818#;
   GUEST_RSP                    : constant := 16#681c#;
   GUEST_RIP                    : constant := 16#681e#;
   GUEST_RFLAGS                 : constant := 16#6820#;
   GUEST_SYSENTER_ESP           : constant := 16#6824#;
   GUEST_SYSENTER_EIP           : constant := 16#6826#;

   --  VM entry/exit interruption-information flags

   VM_INTERRUPT_INFO_VALID      : constant := 16#8000_0000#;

   --  VMX basic exit reasons

   EXIT_REASON_EXCEPTION_NMI    : constant := 0;
   EXIT_REASON_EXTERNAL_INT     : constant := 1;
   EXIT_REASON_INTERRUPT_WINDOW : constant := 7;
   EXIT_REASON_CPUID            : constant := 10;
   EXIT_REASON_INVLPG           : constant := 14;
   EXIT_REASON_RDTSC            : constant := 16;
   EXIT_REASON_VMCALL           : constant := 18;
   EXIT_REASON_CR_ACCESS        : constant := 28;
   EXIT_REASON_DR_ACCESS        : constant := 29;
   EXIT_REASON_IO_INSTRUCTION   : constant := 30;
   EXIT_REASON_RDMSR            : constant := 31;
   EXIT_REASON_WRMSR            : constant := 32;
   EXIT_REASON_EPT_VIOLATION    : constant := 48;
   EXIT_REASON_TIMER_EXPIRY     : constant := 52;

   --  VMX exit reason flags

   VM_EXIT_ENTRY_FAILURE        : constant := 31;

end SK.Constants;
