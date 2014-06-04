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

with Interfaces;

with DOM.Core.Nodes;
with DOM.Core.Elements;

with McKae.XML.XPath.XIA;

with Mulog;
with Muxml.Utils;
with Mutools.Utils;
with Mutools.XML_Utils;

package body Expanders.Platform
is

   -------------------------------------------------------------------------

   procedure Add_PCI_Config_Space (Data : in out Muxml.XML_Data_Type)
   is
      Cfg_Start_Addr : constant Interfaces.Unsigned_64
        := Interfaces.Unsigned_64'Value
          (Muxml.Utils.Get_Attribute
             (Doc   => Data.Doc,
              XPath => "/system/platform/devices",
              Name  => "pciConfigAddress"));
      PCI_Devices : constant DOM.Core.Node_List
        := McKae.XML.XPath.XIA.XPath_Query
          (N     => Data.Doc,
           XPath => "/system/platform/devices/device[pci]");
   begin
      for I in 0 .. DOM.Core.Nodes.Length (List => PCI_Devices) - 1 loop
         declare
            use type Interfaces.Unsigned_64;

            Device    : constant DOM.Core.Node := DOM.Core.Nodes.Item
              (List  => PCI_Devices,
               Index => I);
            Dev_Name  : constant String
              := DOM.Core.Elements.Get_Attribute
                (Elem => Device,
                 Name => "name");
            BFD_Node  : constant DOM.Core.Node := Muxml.Utils.Get_Element
              (Doc   => Device,
               XPath => "pci");
            Bus_Nr    : constant Interfaces.Unsigned_64
              := Interfaces.Unsigned_64'Value
                (DOM.Core.Elements.Get_Attribute
                   (Elem => BFD_Node,
                    Name => "bus"));
            Device_Nr : constant Interfaces.Unsigned_64
              := Interfaces.Unsigned_64'Value
                (DOM.Core.Elements.Get_Attribute
                   (Elem => BFD_Node,
                    Name => "device"));
            Func_Nr   : constant Interfaces.Unsigned_64
              := Interfaces.Unsigned_64'Value
                (DOM.Core.Elements.Get_Attribute
                   (Elem => BFD_Node,
                    Name => "function"));
            PCI_Cfg_Addr : constant Interfaces.Unsigned_64 := Cfg_Start_Addr +
              (Bus_Nr * 2 ** 20 + Device_Nr * 2 ** 15 + Func_Nr * 2 ** 12);
            PCI_Cfg_Addr_Str : constant String
              := Mutools.Utils.To_Hex (Number => PCI_Cfg_Addr);
         begin
            Mulog.Log (Msg => "Adding PCI config space region to device '"
                       & Dev_Name & "' at physical address "
                       & PCI_Cfg_Addr_Str);
            Muxml.Utils.Append_Child
              (Node      => Device,
               New_Child => Mutools.XML_Utils.Create_Memory_Node
              (Policy      => Data,
               Name        => "mmconf",
               Address     => PCI_Cfg_Addr_Str,
               Size        => "16#1000#",
               Caching     => "UC",
               Alignment   => "",
               Memory_Type => ""));
         end;
      end loop;
   end Add_PCI_Config_Space;

end Expanders.Platform;
