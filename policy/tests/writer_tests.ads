with Ahven.Framework;

package Writer_Tests
is

   type Testcase is new Ahven.Framework.Test_Case with null record;

   --  Initialize testcase.
   procedure Initialize (T : in out Testcase);

   --  Write subject specs to file.
   procedure Write_Subjects;

   --  Write pagetables to files.
   procedure Write_Pagetables;

end Writer_Tests;
