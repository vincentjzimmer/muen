--  This package is intended to set up and tear down  the test environment.
--  Once created by GNATtest, this package will never be overwritten
--  automatically. Contents of this package can be modified in any way
--  except for sections surrounded by a 'read only' marker.

with AUnit.Test_Fixtures;

with Ada.Directories;

with DOM.Core.Nodes;
with DOM.Core.Documents;

with Muxml.Utils;

with Test_Utils;

package VTd.Generator.Test_Data is

--  begin read only
   type Test is new AUnit.Test_Fixtures.Test_Fixture
--  end read only
   with null record;

   procedure Set_Up (Gnattest_T : in out Test);
   procedure Tear_Down (Gnattest_T : in out Test);

   Output_Dir : constant String := "obj";
   Root_Table : constant String := Output_Dir & "/vtd_root";
   Context_0  : constant String := Output_Dir & "/vtd_context_bus_0";
   Context_23 : constant String := Output_Dir & "/vtd_context_bus_23";
   Lnx_Dom_Pt : constant String := Output_Dir & "/vtd_lnx_domain_pt";
   Net_Dom_Pt : constant String := Output_Dir & "/vtd_net_domain_pt";
   IR_Table   : constant String := Output_Dir & "/vtd_ir";

end VTd.Generator.Test_Data;
