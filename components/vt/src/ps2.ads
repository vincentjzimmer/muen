--
--  Copyright (C) 2015  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2015  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

private with SK;

package PS2
is

   --  Handle PS/2 interrupt.
   procedure Handle_Interrupt;

private

   --  Read data from PS/2 device.
   procedure Read (Data : out SK.Byte);

   --  Write given command to PS/2 command register.
   procedure Write_Command (Cmd : SK.Byte);

   --  Write given data to PS/2 data register.
   procedure Write_Data (Data : SK.Byte);

   --  Write data to auxiliary PS/2 device.
   procedure Write_Aux (Data : SK.Byte);

   --  Wait until the PS/2 controller sends an acknowledge or the specified
   --  number of busy loops iterations is reached. Timeout is set to True if
   --  the ack was not received in time.
   procedure Wait_For_Ack
     (Loops    :     Natural := 1000;
      Timeout  : out Boolean);

end PS2;
