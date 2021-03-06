--
--  Copyright (C) 2014  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2014  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

with Muxml;

package Mucfgcheck.Kernel
is

   --  Validate that all CPU store virtual addresses are equal.
   procedure CPU_Store_Address_Equality (XML_Data : Muxml.XML_Data_Type);

   --  Validate that all stack virtual addresses are equal.
   procedure Stack_Address_Equality (XML_Data : Muxml.XML_Data_Type);

   --  Validate that all IOMMU memory-mapped IO regions are consecutive.
   procedure IOMMU_Consecutiveness (XML_Data : Muxml.XML_Data_Type);

   --  Validate that each active CPU has a memory section.
   procedure CPU_Memory_Section_Count (XML_Data : Muxml.XML_Data_Type);

end Mucfgcheck.Kernel;
