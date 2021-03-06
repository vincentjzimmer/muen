--
--  Copyright (C) 2013, 2014  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2013, 2014  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

with System.Machine_Code;

package body SK.CPU
is

   -------------------------------------------------------------------------

   procedure Cli
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "cli",
         Volatile => True);
   end Cli;

   -------------------------------------------------------------------------

   procedure CPUID
     (EAX : in out SK.Word32;
      EBX :    out SK.Word32;
      ECX : in out SK.Word32;
      EDX :    out SK.Word32)
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "cpuid",
         Inputs   => (SK.Word32'Asm_Input ("a", EAX),
                      SK.Word32'Asm_Input ("c", ECX)),
         Outputs  => (SK.Word32'Asm_Output ("=a", EAX),
                      SK.Word32'Asm_Output ("=b", EBX),
                      SK.Word32'Asm_Output ("=c", ECX),
                      SK.Word32'Asm_Output ("=d", EDX)));
   end CPUID;

   -------------------------------------------------------------------------

   procedure Fninit
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "fninit",
         Volatile => True);
   end Fninit;

   -------------------------------------------------------------------------

   function Get_CR0 return SK.Word64
   with
      SPARK_Mode => Off
   is
      Result : SK.Word64;
   begin
      System.Machine_Code.Asm
        (Template => "movq %%cr0, %0",
         Outputs  => (SK.Word64'Asm_Output ("=r", Result)),
         Volatile => True);
      return Result;
   end Get_CR0;

   -------------------------------------------------------------------------

   function Get_CR2 return SK.Word64
   with
      SPARK_Mode => Off
   is
      Result : SK.Word64;
   begin
      System.Machine_Code.Asm
        (Template => "movq %%cr2, %0",
         Outputs  => (SK.Word64'Asm_Output ("=r", Result)),
         Volatile => True);
      return Result;
   end Get_CR2;

   -------------------------------------------------------------------------

   function Get_CR3 return SK.Word64
   with
      SPARK_Mode => Off
   is
      Result : SK.Word64;
   begin
      System.Machine_Code.Asm
        (Template => "movq %%cr3, %0",
         Outputs  => (SK.Word64'Asm_Output ("=r", Result)),
         Volatile => True);
      return Result;
   end Get_CR3;

   -------------------------------------------------------------------------

   function Get_CR4 return SK.Word64
   with
      SPARK_Mode => Off
   is
      Result : SK.Word64;
   begin
      System.Machine_Code.Asm
        (Template => "movq %%cr4, %0",
         Outputs  => (SK.Word64'Asm_Output ("=r", Result)),
         Volatile => True);
      return Result;
   end Get_CR4;

   -------------------------------------------------------------------------

   procedure Get_MSR
     (Register :     SK.Word32;
      Low      : out SK.Word32;
      High     : out SK.Word32)
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "rdmsr",
         Inputs   => (SK.Word32'Asm_Input ("c", Register)),
         Outputs  => (SK.Word32'Asm_Output ("=d", High),
                      SK.Word32'Asm_Output ("=a", Low)),
         Volatile => True);
   end Get_MSR;

   -------------------------------------------------------------------------

   function Get_MSR64 (Register : SK.Word32) return SK.Word64
   with
      SPARK_Mode => Off
   is
      Low_Dword, High_Dword : SK.Word32;
   begin
      Get_MSR (Register => Register,
               Low      => Low_Dword,
               High     => High_Dword);
      return 2 ** 32 * SK.Word64 (High_Dword) + SK.Word64 (Low_Dword);
   end Get_MSR64;

   -------------------------------------------------------------------------

   function Get_RFLAGS return SK.Word64
   with
      SPARK_Mode => Off
   is
      Result : SK.Word64;
   begin
      System.Machine_Code.Asm
        (Template => "pushf; pop %0",
         Outputs  => (SK.Word64'Asm_Output ("=m", Result)),
         Volatile => True,
         Clobber  => "memory");
      return Result;
   end Get_RFLAGS;

   -------------------------------------------------------------------------

   procedure Hlt
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "hlt",
         Volatile => True);
   end Hlt;

   -------------------------------------------------------------------------

   procedure Lidt (Address : SK.Word64)
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "lidt (%0)",
         Inputs   => (SK.Word64'Asm_Input ("r", Address)),
         Volatile => True);
   end Lidt;

   -------------------------------------------------------------------------

   procedure Ltr (Address : SK.Word16)
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "ltr %%ax",
         Inputs   => (SK.Word16'Asm_Input ("a", Address)),
         Volatile => True);
   end Ltr;

   -------------------------------------------------------------------------

   procedure Panic
   with
      SPARK_Mode => Off
   is
   begin
      loop
         System.Machine_Code.Asm
           (Template => "ud2",
            Volatile => True);
      end loop;
   end Panic;

   -------------------------------------------------------------------------

   procedure Pause
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "pause",
         Volatile => True);
   end Pause;

   -------------------------------------------------------------------------

   procedure RDTSC
     (EAX : out SK.Word32;
      EDX : out SK.Word32)
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "rdtsc",
         Outputs  =>
           (SK.Word32'Asm_Output ("=a", EAX),
            SK.Word32'Asm_Output ("=d", EDX)),
         Volatile => True);
   end RDTSC;

   -------------------------------------------------------------------------

   function RDTSC64 return SK.Word64
   is
      Low_Dword, High_Dword : SK.Word32;
   begin
      RDTSC (EAX => Low_Dword,
             EDX => High_Dword);
      return 2 ** 32 * SK.Word64 (High_Dword) + SK.Word64 (Low_Dword);
   end RDTSC64;

   -------------------------------------------------------------------------

   procedure Set_CR2 (Value : SK.Word64)
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "movq %0, %%cr2",
         Inputs   => (SK.Word64'Asm_Input ("r", Value)),
         Volatile => True);
   end Set_CR2;

   -------------------------------------------------------------------------

   procedure Set_CR4 (Value : SK.Word64)
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "movq %0, %%cr4",
         Inputs   => (SK.Word64'Asm_Input ("r", Value)),
         Volatile => True);
   end Set_CR4;

   -------------------------------------------------------------------------

   procedure Set_Stack (Address : SK.Word64)
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "mov %0, %%rsp; mov %%rsp, %%rbp",
         Inputs   => (SK.Word64'Asm_Input ("g", Address)),
         Volatile => True);
   end Set_Stack;

   -------------------------------------------------------------------------

   procedure Sti
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "sti",
         Volatile => True);
   end Sti;

   -------------------------------------------------------------------------

   procedure Stop
   is
   begin
      loop
         Cli;
         Hlt;
      end loop;
   end Stop;

   -------------------------------------------------------------------------

   procedure VMCLEAR
     (Region  :     SK.Word64;
      Success : out Boolean)
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "vmclear %1; seta %0",
         Inputs   => (Word64'Asm_Input ("m", Region)),
         Outputs  => (Boolean'Asm_Output ("=q", Success)),
         Clobber  => "cc",
         Volatile => True);
   end VMCLEAR;

   -------------------------------------------------------------------------

   procedure VMPTRLD
     (Region  :     SK.Word64;
      Success : out Boolean)
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "vmptrld %1; seta %0",
         Inputs   => (Word64'Asm_Input ("m", Region)),
         Outputs  => (Boolean'Asm_Output ("=q", Success)),
         Clobber  => "cc",
         Volatile => True);
   end VMPTRLD;

   -------------------------------------------------------------------------

   procedure VMREAD
     (Field   :     SK.Word64;
      Value   : out SK.Word64;
      Success : out Boolean)
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "vmread %2, %0; seta %1",
         Inputs   => (Word64'Asm_Input ("r", Field)),
         Outputs  => (Word64'Asm_Output ("=rm", Value),
                      Boolean'Asm_Output ("=q", Success)),
         Clobber  => "cc",
         Volatile => True);
   end VMREAD;

   -------------------------------------------------------------------------

   procedure VMWRITE
     (Field   :     SK.Word64;
      Value   :     SK.Word64;
      Success : out Boolean)
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "vmwrite %1, %2; seta %0",
         Inputs   => (Word64'Asm_Input ("rm", Value),
                      Word64'Asm_Input ("r", Field)),
         Outputs  => (Boolean'Asm_Output ("=q", Success)),
         Clobber  => "cc",
         Volatile => True);
   end VMWRITE;

   -------------------------------------------------------------------------

   procedure VMXON
     (Region  :     SK.Word64;
      Success : out Boolean)
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "vmxon %1; seta %0",
         Inputs   => (Word64'Asm_Input ("m", Region)),
         Outputs  => (Boolean'Asm_Output ("=q", Success)),
         Clobber  => "cc",
         Volatile => True);
   end VMXON;

   -------------------------------------------------------------------------

   procedure Write_MSR
     (Register : SK.Word32;
      Low      : SK.Word32;
      High     : SK.Word32)
   with
      SPARK_Mode => Off
   is
   begin
      System.Machine_Code.Asm
        (Template => "wrmsr",
         Inputs   => (Word32'Asm_Input ("a", Low),
                      Word32'Asm_Input ("d", High),
                      Word32'Asm_Input ("c", Register)),
         Volatile => True);
   end Write_MSR;

   -------------------------------------------------------------------------

   procedure Write_MSR64
     (Register : SK.Word32;
      Value    : SK.Word64)
   is
      Low_Dword, High_Dword : SK.Word32;
   begin
      Low_Dword  := SK.Word32'Mod (Value);
      High_Dword := SK.Word32'Mod (Value / 2 ** 32);

      Write_MSR (Register => Register,
                 Low      => Low_Dword,
                 High     => High_Dword);
   end Write_MSR64;

   -------------------------------------------------------------------------

   procedure XRSTOR (Source : SK.XSAVE_Area_Type)
   with
      SPARK_Mode => Off
   is
   begin

      --  Restore mask in EDX:EAX specifies to restore x87, SSE and AVX
      --  registers, see Intel SDM Vol. 3A, chapter 2.6.

      System.Machine_Code.Asm
        (Template => "xrstor64 %2",
         Inputs   => (SK.Word32'Asm_Input ("a", 7),
                      SK.Word32'Asm_Input ("d", 0),
                      SK.XSAVE_Area_Type'Asm_Input ("m", Source)),
         Volatile => True);
   end XRSTOR;

   -------------------------------------------------------------------------

   procedure XSAVE (Target : out SK.XSAVE_Area_Type)
   with
      SPARK_Mode => Off
   is
   begin

      --  Save mask in EDX:EAX specifies to save x87, SSE and AVX registers,
      --  see Intel SDM Vol. 3A, chapter 2.6.

      System.Machine_Code.Asm
        (Template => "xsave64 %0",
         Inputs   => (SK.Word32'Asm_Input ("a", 7),
                      SK.Word32'Asm_Input ("d", 0)),
         Outputs  => (SK.XSAVE_Area_Type'Asm_Output ("=m", Target)),
         Volatile => True);
   end XSAVE;

   -------------------------------------------------------------------------

   procedure XSETBV
     (Register : SK.Word32;
      Value    : SK.Word64)
   with
      SPARK_Mode => Off
   is
      Low_Dword, High_Dword : SK.Word32;
   begin
      Low_Dword  := SK.Word32'Mod (Value);
      High_Dword := SK.Word32'Mod (Value / 2 ** 32);

      System.Machine_Code.Asm
        (Template => "xsetbv",
         Inputs   => (Word32'Asm_Input ("a", Low_Dword),
                      Word32'Asm_Input ("d", High_Dword),
                      Word32'Asm_Input ("c", Register)),
         Volatile => True);
   end XSETBV;

end SK.CPU;
