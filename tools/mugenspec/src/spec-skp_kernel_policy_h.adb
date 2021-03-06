--
--  Copyright (C) 2014, 2015  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2014, 2015  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;

with Interfaces;

with DOM.Core.Elements;
with DOM.Core.Nodes;

with McKae.XML.XPath.XIA;

with Mulog;
with Muxml.Utils;
with Mutools.XML_Utils;
with Mutools.Templates;

with String_Templates;

package body Spec.Skp_Kernel_Policy_H
is

   use Ada.Strings.Unbounded;
   use Interfaces;

   function U
     (Source : String)
      return Ada.Strings.Unbounded.Unbounded_String
      renames Ada.Strings.Unbounded.To_Unbounded_String;

   --  Returns the kernel PML4 addresses as string for inclusion in policy.h.
   function Get_Kernel_PML4_Addrs
     (Physical_Memory : DOM.Core.Node_List;
      CPU_Count       : Positive)
      return String;

   -------------------------------------------------------------------------

   function Get_Kernel_PML4_Addrs
     (Physical_Memory : DOM.Core.Node_List;
      CPU_Count       : Positive)
      return String
   is
      Buffer : Unbounded_String;
   begin
      for I in Natural range 0 .. CPU_Count - 1 loop
         declare
            CPU_ID    : constant String
              := Ada.Strings.Fixed.Trim
                (Source  => I'Img,
                 Side    => Ada.Strings.Left);
            PML4_Addr : constant Unsigned_64
              := Unsigned_64'Value
                (Muxml.Utils.Get_Attribute
                   (Nodes     => Physical_Memory,
                    Refs      => ((Name  => U ("type"),
                                   Value => U ("system_pt")),
                                  (Name  => U ("name"),
                                   Value => U ("kernel_" & CPU_ID & "|pt"))),
                    Attr_Name => "physicalAddress"));
         begin
            Buffer := Buffer & ASCII.LF & Indent
              (N         => 1,
               Unit_Size => 4);
            Buffer := Buffer  & ".long 0x" & Mutools.Utils.To_Hex
              (Number     => PML4_Addr,
               Normalize  => False);
         end;
      end loop;
      return To_String (Buffer);
   end Get_Kernel_PML4_Addrs;

   -------------------------------------------------------------------------

   procedure Write
     (Output_Dir : String;
      Policy     : Muxml.XML_Data_Type)
   is
      Phys_Memory : constant DOM.Core.Node_List
        := McKae.XML.XPath.XIA.XPath_Query
          (N     => Policy.Doc,
           XPath => "/system/memory/memory");
      Stack_Node  : constant DOM.Core.Node
        := Muxml.Utils.Get_Element
          (Doc   => Policy.Doc,
           XPath => "/system/kernel/memory/cpu[@id='0']/"
           & "memory[@logical='stack']");
      Stack_Ref   : constant String := DOM.Core.Elements.Get_Attribute
        (Elem => Stack_Node,
         Name => "physical");
      Stack_Size  : constant Unsigned_64 := Unsigned_64'Value
        (Muxml.Utils.Get_Attribute
           (Nodes     => Phys_Memory,
            Ref_Attr  => "name",
            Ref_Value => Stack_Ref,
            Attr_Name => "size"));
      Stack_Addr  : constant Unsigned_64 := Unsigned_64'Value
        (DOM.Core.Elements.Get_Attribute
           (Elem => Stack_Node,
            Name => "virtualAddress")) + Stack_Size;

      CPU_Store_Addr : constant Unsigned_64 := Unsigned_64'Value
        (Muxml.Utils.Get_Attribute
           (Doc   => Policy.Doc,
            XPath => "/system/kernel/memory/cpu[@id='0']/"
            & "memory[@logical='store']",
            Name  => "virtualAddress"));

      Tau0_Iface_Addr : constant Unsigned_64 := Unsigned_64'Value
        (Muxml.Utils.Get_Attribute
           (Doc   => Policy.Doc,
            XPath => "/system/kernel/memory/cpu[@id='0']/"
            & "memory[@logical='tau0_interface']",
            Name  => "virtualAddress"));

      --  Write C header for kernel to specified output directory.
      procedure Write_Kernel_Header
        (Output_Dir : String;
         Policy     : Muxml.XML_Data_Type);

      --  Write SPARK specification for kernel to specified output directory.
      procedure Write_Kernel_Spec
        (Output_Dir : String;
         Policy     : Muxml.XML_Data_Type);

      ----------------------------------------------------------------------

      procedure Write_Kernel_Header
        (Output_Dir : String;
         Policy     : Muxml.XML_Data_Type)
      is
         Subject_Count : constant Natural := DOM.Core.Nodes.Length
           (List => McKae.XML.XPath.XIA.XPath_Query
              (N     => Policy.Doc,
               XPath => "/system/subjects/subject"));
         CPU_Count     : constant Positive
           := Mutools.XML_Utils.Get_Active_CPU_Count (Data => Policy);
         VMXON_Addr    : constant Unsigned_64 := Unsigned_64'Value
           (Muxml.Utils.Get_Attribute
              (Nodes     => Phys_Memory,
               Refs      => ((Name  => U ("type"),
                              Value => U ("system_vmxon")),
                             (Name  => U ("name"),
                              Value => U ("kernel_0|vmxon"))),
               Attr_Name => "physicalAddress"));
         VMCS_Addr     : constant Unsigned_64 := Unsigned_64'Value
           (Muxml.Utils.Get_Attribute
              (Nodes     => Phys_Memory,
               Refs      => ((Name  => U ("type"),
                              Value => U ("system_vmcs")),
                             (Name  => U ("name"),
                              Value => U ("tau0|vmcs"))),
               Attr_Name => "physicalAddress"));

         Tmpl : Mutools.Templates.Template_Type;
      begin
         Mulog.Log (Msg => "Writing kernel header file to '"
                    & Output_Dir & "/policy.h'");

         Tmpl := Mutools.Templates.Create
           (Content => String_Templates.policy_h);
         Mutools.Templates.Replace
           (Template => Tmpl,
            Pattern  => "__subj_count__",
            Content  => Ada.Strings.Fixed.Trim
              (Source => Subject_Count'Img,
               Side   => Ada.Strings.Left));
         Mutools.Templates.Replace
           (Template => Tmpl,
            Pattern  => "__stack_addr__",
            Content  => Mutools.Utils.To_Hex
              (Number    => Stack_Addr,
               Normalize => False));
         Mutools.Templates.Replace
           (Template => Tmpl,
            Pattern  => "__cpu_store_addr__",
            Content  => Mutools.Utils.To_Hex
              (Number    => CPU_Store_Addr,
               Normalize => False));
         Mutools.Templates.Replace
           (Template => Tmpl,
            Pattern  => "__cpu_count__",
            Content  => Ada.Strings.Fixed.Trim
              (Source => CPU_Count'Img,
               Side   => Ada.Strings.Left));
         Mutools.Templates.Replace
           (Template => Tmpl,
            Pattern  => "__vmxon_addr__",
            Content  => Mutools.Utils.To_Hex
              (Number    => VMXON_Addr,
               Normalize => False));
         Mutools.Templates.Replace
           (Template => Tmpl,
            Pattern  => "__vmcs_addr__",
            Content  => Mutools.Utils.To_Hex
              (Number    => VMCS_Addr,
               Normalize => False));
         Mutools.Templates.Replace
           (Template => Tmpl,
            Pattern  => "__kernel_pml4_addrs__",
            Content  => Get_Kernel_PML4_Addrs
              (Physical_Memory => Phys_Memory,
               CPU_Count       => CPU_Count));

         Mutools. Templates.Write
           (Template => Tmpl,
            Filename => Output_Dir & "/policy.h");
      end Write_Kernel_Header;

      ----------------------------------------------------------------------

      procedure Write_Kernel_Spec
        (Output_Dir : String;
         Policy     : Muxml.XML_Data_Type)
      is
         Subj_States_Addr : constant Unsigned_64 := Unsigned_64'Value
           (Muxml.Utils.Get_Attribute
              (Doc   => Policy.Doc,
               XPath => "/system/kernel/memory/cpu/"
               & "memory[@logical='tau0|state']",
               Name  => "virtualAddress"));
         Subj_Timers_Addr : constant Unsigned_64 := Unsigned_64'Value
           (Muxml.Utils.Get_Attribute
              (Doc   => Policy.Doc,
               XPath => "/system/kernel/memory/cpu/"
               & "memory[@logical='tau0|timer']",
               Name  => "virtualAddress"));
         Subj_Sinfo_Addr  : constant Unsigned_64 := Unsigned_64'Value
           (Muxml.Utils.Get_Attribute
              (Doc   => Policy.Doc,
               XPath => "/system/kernel/memory/cpu/"
               & "memory[@logical='tau0|sinfo']",
               Name  => "virtualAddress"));
         Subj_Sinfo_Size  : constant Unsigned_64 := Unsigned_64'Value
           (Muxml.Utils.Get_Attribute
              (Doc   => Policy.Doc,
               XPath => "/system/memory/memory[@name='tau0|sinfo']",
               Name  => "size"));
         IO_Apic_Addr     : constant Unsigned_64 := Unsigned_64'Value
           (Muxml.Utils.Get_Attribute
              (Doc   => Policy.Doc,
               XPath => "/system/kernel/devices/device[@logical='ioapic']"
               & "/memory",
               Name  => "virtualAddress"));

         Tmpl : Mutools.Templates.Template_Type;
      begin
         Mulog.Log (Msg => "Writing kernel spec to '"
                    & Output_Dir & "/skp-kernel.ads'");

         Tmpl := Mutools.Templates.Create
           (Content => String_Templates.skp_kernel_ads);
         Mutools.Templates.Replace
           (Template => Tmpl,
            Pattern  => "__stack_addr__",
            Content  => Mutools.Utils.To_Hex (Number => Stack_Addr));
         Mutools.Templates.Replace
           (Template => Tmpl,
            Pattern  => "__cpu_store_addr__",
            Content  => Mutools.Utils.To_Hex (Number => CPU_Store_Addr));
         Mutools.Templates.Replace
           (Template => Tmpl,
            Pattern  => "__tau0_iface_addr__",
            Content  => Mutools.Utils.To_Hex (Number => Tau0_Iface_Addr));
         Mutools.Templates.Replace
           (Template => Tmpl,
            Pattern  => "__subj_states_addr__",
            Content  => Mutools.Utils.To_Hex (Number => Subj_States_Addr));
         Mutools.Templates.Replace
           (Template => Tmpl,
            Pattern  => "__subj_timers_addr__",
            Content  => Mutools.Utils.To_Hex (Number => Subj_Timers_Addr));
         Mutools.Templates.Replace
           (Template => Tmpl,
            Pattern  => "__subj_sinfo_addr__",
            Content  => Mutools.Utils.To_Hex (Number => Subj_Sinfo_Addr));
         Mutools.Templates.Replace
           (Template => Tmpl,
            Pattern  => "__subj_sinfo_size__",
            Content  => Mutools.Utils.To_Hex (Number => Subj_Sinfo_Size));
         Mutools.Templates.Replace
           (Template => Tmpl,
            Pattern  => "__ioapic_addr__",
            Content  => Mutools.Utils.To_Hex (Number => IO_Apic_Addr));

         Mutools.Templates.Write
           (Template => Tmpl,
            Filename => Output_Dir & "/skp-kernel.ads");
      end Write_Kernel_Spec;
   begin
      Write_Kernel_Spec (Output_Dir => Output_Dir,
                         Policy     => Policy);
      Write_Kernel_Header (Output_Dir => Output_Dir,
                           Policy     => Policy);
   end Write;

end Spec.Skp_Kernel_Policy_H;
