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

with Expanders.Subjects;
with Expanders.Components;
with Expanders.Platform;
with Expanders.Features;

package body Stage1.Expansion
is

   -------------------------------------------------------------------------

   procedure Clear
   is
   begin
      Procs.Clear;
   end Clear;

   -------------------------------------------------------------------------

   function Get_Count return Natural renames Procs.Get_Count;

   -------------------------------------------------------------------------

   procedure Register_All
   is
      use Expanders;
   begin

      --  Create optional subject elements such as memory first.

      Procs.Register (Process => Subjects.Add_Missing_Elements'Access);

      Procs.Register (Process => Features.Add_Default_Features'Access);
      Procs.Register (Process => Components.Add_Binaries'Access);
      Procs.Register (Process => Components.Add_Channels'Access);
      Procs.Register (Process => Components.Remove_Components'Access);
      Procs.Register (Process => Components.Remove_Component_Reference'Access);
      Procs.Register (Process => Platform.Add_IOMMU_Default_Caps'Access);
   end Register_All;

   -------------------------------------------------------------------------

   procedure Run (Data : in out Muxml.XML_Data_Type) renames Procs.Run;

end Stage1.Expansion;
