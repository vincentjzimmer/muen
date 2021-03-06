--  This package has been generated automatically by GNATtest.
--  You are allowed to add your code to the bodies of test routines.
--  Such changes will be kept during further regeneration of this file.
--  All code placed outside of test routine bodies will be lost. The
--  code intended to set up and tear down the test environment should be
--  placed into Elfcheck.Test_Data.

with AUnit.Assertions; use AUnit.Assertions;

package body Elfcheck.Test_Data.Tests is


--  begin read only
   procedure Test_Run (Gnattest_T : in out Test);
   procedure Test_Run_fe87e3 (Gnattest_T : in out Test) renames Test_Run;
--  id:2.2/fe87e30211bf9f21/Run/1/0/
   procedure Test_Run (Gnattest_T : in out Test) is
   --  elfcheck.ads:23:4:Run
--  end read only

      pragma Unreferenced (Gnattest_T);

   begin
      Run (Policy_File => "data/test_policy.xml",
           ELF_Binary  => "data/binary");
--  begin read only
   end Test_Run;
--  end read only

end Elfcheck.Test_Data.Tests;
