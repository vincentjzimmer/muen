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

with Interfaces;

with Ada.Containers.Ordered_Sets;

with DOM.Core;

with Muxml;

package Mutools.XML_Utils
is

   --  Add physical device resource designated by Physical_Resource node to
   --  specified logical device with given logical resource name. If no name is
   --  specified, the logical name is set to the physical resource name.
   procedure Add_Resource
     (Logical_Device        : DOM.Core.Node;
      Physical_Resource     : DOM.Core.Node;
      Logical_Resource_Name : String := "");

   --  Add physical memory region element with given parameters to policy.
   procedure Add_Memory_Region
     (Policy      : in out Muxml.XML_Data_Type;
      Name        :        String;
      Address     :        String;
      Size        :        String;
      Caching     :        String;
      Alignment   :        String;
      Memory_Type :        String);

   --  Add file-backed physical memory region element with given parameters to
   --  policy.
   procedure Add_Memory_Region
     (Policy      : in out Muxml.XML_Data_Type;
      Name        :        String;
      Address     :        String;
      Size        :        String;
      Caching     :        String;
      Alignment   :        String;
      Memory_Type :        String;
      File_Name   :        String;
      File_Offset :        String);

   --  Add pattern-filled physical memory region element with given parameters
   --  to policy.
   procedure Add_Memory_Region
     (Policy       : in out Muxml.XML_Data_Type;
      Name         :        String;
      Address      :        String;
      Size         :        String;
      Caching      :        String;
      Alignment    :        String;
      Memory_Type  :        String;
      Fill_Pattern :        String);

   --  Create memory node element with given parameters.
   function Create_Memory_Node
     (Policy      : in out Muxml.XML_Data_Type;
      Name        :        String;
      Address     :        String;
      Size        :        String;
      Caching     :        String;
      Alignment   :        String;
      Memory_Type :        String)
      return DOM.Core.Node;

   --  Create virtual memory node with given parameters.
   function Create_Virtual_Memory_Node
     (Policy        : in out Muxml.XML_Data_Type;
      Logical_Name  :        String;
      Physical_Name :        String;
      Address       :        String;
      Writable      :        Boolean;
      Executable    :        Boolean)
      return DOM.Core.Node;

   --  Returns True if the given VMX controls specify that the DEBUGCTL MSR is
   --  saved/loaded automatically on VM-exits and entries.
   function Has_Managed_DEBUGCTL (Controls : DOM.Core.Node) return Boolean;

   --  Returns True if the given VMX controls specify that the
   --  PERFGLOBALCTRL MSR is loaded automatically on VM-entries.
   function Has_Managed_PERFGLOBALCTRL
     (Controls : DOM.Core.Node)
      return Boolean;

   --  Returns True if the given VMX controls specify that the PAT MSR is
   --  saved/loaded automatically on VM-exits and entries.
   function Has_Managed_PAT (Controls : DOM.Core.Node) return Boolean;

   --  Returns True if the given VMX controls specify that the EFER MSR is
   --  saved/loaded automatically on VM-exits and entries.
   function Has_Managed_EFER (Controls : DOM.Core.Node) return Boolean;

   --  Returns the number of Model-Specific registers that must be managed by
   --  the MSR store mechanism given the list of MSR nodes and considering the
   --  specified control flags.
   function Calculate_MSR_Count
     (MSRs                   : DOM.Core.Node_List;
      DEBUGCTL_Control       : Boolean;
      PAT_Control            : Boolean;
      PERFGLOBALCTRL_Control : Boolean;
      EFER_Control           : Boolean)
      return Natural;

   type PCI_Bus_Range is range 0 .. 255;

   package PCI_Bus_Set is new Ada.Containers.Ordered_Sets
     (Element_Type => PCI_Bus_Range);

   --  Return set of occupied PCI bus numbers for given system policy.
   function Get_Occupied_PCI_Buses
     (Data : Muxml.XML_Data_Type)
      return PCI_Bus_Set.Set;

   --  Return the list of subjects that can trigger a switch to the given
   --  target subject.
   function Get_Switch_Sources
     (Data   : Muxml.XML_Data_Type;
      Target : DOM.Core.Node)
      return DOM.Core.Node_List;

   --  Returns the number of CPUs that are active in a given system policy.
   function Get_Active_CPU_Count (Data : Muxml.XML_Data_Type) return Positive;

   --  Returns the ID of the CPU that can execute the specified subject of a
   --  given XML policy. If no CPU can execute the given subject -1 is
   --  returned.
   function Get_Executing_CPU
     (Data    : Muxml.XML_Data_Type;
      Subject : DOM.Core.Node)
      return Integer;

   --  Returns True if the given node references a PCI device.
   function Is_PCI_Device_Reference
     (Data       : Muxml.XML_Data_Type;
      Device_Ref : DOM.Core.Node)
      return Boolean;

   --  Minor frame and its exit time in ticks measured from the start of the
   --  corresponding major frame.
   type Deadline_Type is record
      Exit_Time   : Interfaces.Unsigned_64;
      Minor_Frame : DOM.Core.Node;
   end record;

   type Deadline_Array is array (Positive range <>) of Deadline_Type;

   --  Returns the minor frame deadlines for the given major frame.
   function Get_Minor_Frame_Deadlines
     (Major : DOM.Core.Node)
      return Deadline_Array;

   subtype IOMMU_Paging_Level is Positive range 3 .. 4;

   --  Return supported paging-levels of IOMMUs. Since all IOMMUs must have the
   --  same AGAW capability, the paging-levels of the first IOMMU is returned.
   --  For an explanation of the IOMMU AGAW support and levels of page-table
   --  walks see the Intel VT-d specification, section 10.4.2, figure 10-45.
   function Get_IOMMU_Paging_Levels
     (Data : Muxml.XML_Data_Type)
      return IOMMU_Paging_Level;

   type Features_Type is
     (Feature_IOMMU);

   --  Returns True if the given system policy has the specified feature
   --  enabled.
   function Has_Feature_Enabled
     (Data : Muxml.XML_Data_Type;
      F    : Features_Type)
      return Boolean;

   --  Legacy IRQ range (PIC cascade IRQ 2 excluded).
   type Legacy_IRQ_Range is range 0 .. 23
     with Static_Predicate => Legacy_IRQ_Range /= 2;

   --  I/O APIC RTE index.
   type IOAPIC_RTE_Range is range 1 .. 23;

   --  Return I/O APIC RTE index for given legacy IRQ. See Intel 82093AA I/O
   --  Advanced Programmable Interrupt Controller (IOAPIC) specification,
   --  section 2.4 for more details.
   function Get_IOAPIC_RTE_Idx
     (IRQ : Legacy_IRQ_Range)
      return IOAPIC_RTE_Range;

   --  Supported IRQ types.
   type IRQ_Kind is
     (IRQ_ISA,
      IRQ_PCI_LSI,
      IRQ_PCI_MSI);

   --  Return IRQ kind supported by device given as node.
   function Get_IRQ_Kind (Dev : DOM.Core.Node) return IRQ_Kind;

end Mutools.XML_Utils;
