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

with Skp.Scheduling;

with SK.CPU_Global;

package SK.MP
with
   Abstract_State =>
    (Barrier with External => (Async_Writers, Async_Readers)),
   Initializes    => Barrier
is

   --  Blocks until all logical processors are waiting on barrier.
   procedure Wait_For_All
   with
      Global  => (In_Out => Barrier),
      Depends => (Barrier =>+ null);

   --  Blocks until minor frame barrier with given index is released.
   procedure Wait_On_Minor_Frame_Barrier
     (Index : Skp.Scheduling.Barrier_Index_Range)
   with
      Global  => (In_Out => Barrier),
      Depends => (Barrier =>+ Index);

   --  Set minor frame barrier sizes to values specified by given config.
   procedure Set_Minor_Frame_Barrier_Config
     (Config : Skp.Scheduling.Barrier_Config_Array)
   with
      Global  => (In_Out => Barrier),
      Depends => (Barrier =>+ Config),
      Pre     => CPU_Global.Is_BSP;

end SK.MP;
