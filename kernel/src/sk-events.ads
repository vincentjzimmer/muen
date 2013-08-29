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

with Skp;

--# inherit
--#    Skp,
--#    SK;
package SK.Events
--# own
--#    State;
--# initializes
--#    State;
is

   --  Insert new event for given subject.
   procedure Insert_Event
     (Subject : Skp.Subject_Id_Type;
      Event   : SK.Byte);
   --# global
   --#    in out State;
   --# derives
   --#    State from *, Subject, Event;

   --  Return True if the subject identified by ID has events pending.
   function Has_Pending_Events (Subject : Skp.Subject_Id_Type) return Boolean;
   --# global
   --#    State;

   --  Consume an event of a subject given by ID. Returns False if no
   --  outstanding event is found.
   procedure Consume_Event
     (Subject :     Skp.Subject_Id_Type;
      Found   : out Boolean;
      Event   : out SK.Byte);
   --# global
   --#    in out State;
   --# derives
   --#    State, Found, Event from State, Subject;

end SK.Events;
