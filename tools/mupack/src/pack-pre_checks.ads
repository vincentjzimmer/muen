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

with Ada.Strings.Unbounded;

with Muxml;
with Mutools.Immutable_Processors;

package Pack.Pre_Checks
is

   --  Check existence of files referenced in XML policy.
   procedure Files_Exist (Data : Muxml.XML_Data_Type);

   --  Check if files fit into corresponding memory region.
   procedure Files_Size (Data : Muxml.XML_Data_Type);

   --  Register all pre-checks.
   procedure Register_All;

   --  Set input directory.
   procedure Set_Input_Directory (Dir : String);

   --  Run registered pre-checks.
   procedure Run (Data : Muxml.XML_Data_Type);

   --  Return number of registered pre-checks.
   function Get_Count return Natural;

   --  Clear registered pre-checks.
   procedure Clear;

   Check_Error : exception;

private

   Input_Dir : Ada.Strings.Unbounded.Unbounded_String;

   package Check_Procs is new
     Mutools.Immutable_Processors (Param_Type => Muxml.XML_Data_Type);

end Pack.Pre_Checks;
