--  This package has been generated automatically by GNATtest.
--  You are allowed to add your code to the bodies of test routines.
--  Such changes will be kept during further regeneration of this file.
--  All code placed outside of test routine bodies will be lost. The
--  code intended to set up and tear down the test environment should be
--  placed into Pack.Manifest.Test_Data.

with AUnit.Assertions; use AUnit.Assertions;

package body Pack.Manifest.Test_Data.Tests is


--  begin read only
   procedure Test_Add_Entry (Gnattest_T : in out Test);
   procedure Test_Add_Entry_a5a36f (Gnattest_T : in out Test) renames Test_Add_Entry;
--  id:2.2/a5a36f31266c59ba/Add_Entry/1/0/
   procedure Test_Add_Entry (Gnattest_T : in out Test) is
   --  pack-manifest.ads:30:4:Add_Entry
--  end read only

      pragma Unreferenced (Gnattest_T);

   begin
      Assert (Condition => True,
              Message   => "Tested in Write");
--  begin read only
   end Test_Add_Entry;
--  end read only


--  begin read only
   procedure Test_Write (Gnattest_T : in out Test);
   procedure Test_Write_afa96b (Gnattest_T : in out Test) renames Test_Write;
--  id:2.2/afa96b009f0d8d47/Write/1/0/
   procedure Test_Write (Gnattest_T : in out Test) is
   --  pack-manifest.ads:40:4:Write
--  end read only

      pragma Unreferenced (Gnattest_T);

      Fname : constant String := "obj/add_entries.manifest";
      Mf    : Manifest_Type;
   begin
      Add_Entry (Manifest => Mf,
                 Mem_Name => "some_name",
                 Mem_Type => "some_format",
                 Content  => "testfile",
                 Address  => 16#100000#,
                 Size     => 16#1000#,
                 Offset   => 0);
      Add_Entry (Manifest => Mf,
                 Mem_Name => "linux|acpi_rsdp",
                 Mem_Type => "acpi_rsdp",
                 Content  => "data/sections.ref",
                 Address  => 16#101000#,
                 Size     => 16#13000#,
                 Offset   => 0);

      Write (Manifest => Mf,
             Filename => Fname);

      Assert (Condition => Test_Utils.Equal_Files
              (Filename1 => Fname,
               Filename2 => "data/add_entries.manifest"),
              Message   => "Manifest mismatch");

      Ada.Directories.Delete_File (Name => Fname);
--  begin read only
   end Test_Write;
--  end read only

end Pack.Manifest.Test_Data.Tests;
