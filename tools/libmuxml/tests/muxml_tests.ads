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

with Ahven.Framework;

package Muxml_Tests
is

   type Testcase is new Ahven.Framework.Test_Case with null record;

   --  Initialize testcase.
   procedure Initialize (T : in out Testcase);

   --  Try to load nonexistent XSD file.
   procedure Load_Nonexistent_Xsd;

   --  Try to load an invalid XSD file.
   procedure Load_Invalid_Xsd;

   --  Try to load nonexistent XML file.
   procedure Load_Nonexistent_Xml;

   --  Try to load a file which is not XML.
   procedure Load_Non_Xml_File;

   --  Try to load an invalid XML file.
   procedure Load_Invalid_Xml;

   --  Load policy from XML file.
   procedure Load_Policy_Xml;

end Muxml_Tests;