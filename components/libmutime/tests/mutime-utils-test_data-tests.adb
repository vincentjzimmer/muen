--  This package has been generated automatically by GNATtest.
--  You are allowed to add your code to the bodies of test routines.
--  Such changes will be kept during further regeneration of this file.
--  All code placed outside of test routine bodies will be lost. The
--  code intended to set up and tear down the test environment should be
--  placed into Mutime.Utils.Test_Data.

with AUnit.Assertions; use AUnit.Assertions;

package body Mutime.Utils.Test_Data.Tests is


--  begin read only
   procedure Test_To_BCD (Gnattest_T : in out Test);
   procedure Test_To_BCD_561e95 (Gnattest_T : in out Test) renames Test_To_BCD;
--  id:2.2/561e95eda3cdb2e0/To_BCD/1/0/
   procedure Test_To_BCD (Gnattest_T : in out Test) is
   --  mutime-utils.ads:37:4:To_BCD
--  end read only

      pragma Unreferenced (Gnattest_T);

      use type Interfaces.Unsigned_8;
   begin
      Assert (Condition => To_BCD (Value => 0) = 0,
              Message   => "BCD mismatch (1)");
      Assert (Condition => To_BCD (Value => 26) = 16#26#,
              Message   => "BCD mismatch (2)");
      Assert (Condition => To_BCD (Value => 99) = 16#99#,
              Message   => "BCD mismatch (3)");
--  begin read only
   end Test_To_BCD;
--  end read only

end Mutime.Utils.Test_Data.Tests;
