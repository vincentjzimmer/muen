--  This package has been generated automatically by GNATtest.
--  You are allowed to add your code to the bodies of test routines.
--  Such changes will be kept during further regeneration of this file.
--  All code placed outside of test routine bodies will be lost. The
--  code intended to set up and tear down the test environment should be
--  placed into Mucfgcheck.Kernel.Test_Data.

with AUnit.Assertions; use AUnit.Assertions;

package body Mucfgcheck.Kernel.Test_Data.Tests is


--  begin read only
   procedure Test_CPU_Store_Address_Equality (Gnattest_T : in out Test);
   procedure Test_CPU_Store_Address_Equality_d15328 (Gnattest_T : in out Test) renames Test_CPU_Store_Address_Equality;
--  id:2.2/d1532861b18cecda/CPU_Store_Address_Equality/1/0/
   procedure Test_CPU_Store_Address_Equality (Gnattest_T : in out Test) is
   --  mucfgcheck-kernel.ads:25:4:CPU_Store_Address_Equality
--  end read only

      pragma Unreferenced (Gnattest_T);

      Data : Muxml.XML_Data_Type;
   begin
      Muxml.Parse (Data => Data,
                   Kind => Muxml.Format_B,
                   File => "data/test_policy.xml");
      Muxml.Utils.Set_Attribute
        (Doc   => Data.Doc,
         XPath => "/system/kernel/memory/cpu/memory"
         & "[@physical='kernel_store_1']",
         Name  => "virtualAddress",
         Value => "16#0021_0000#");

      begin
         CPU_Store_Address_Equality (XML_Data => Data);
         Assert (Condition => False,
                 Message   => "Exception expected");

      exception
         when E : Validation_Error =>
            Assert (Condition => Ada.Exceptions.Exception_Message (X => E)
                    = "Attribute 'virtualAddress => 16#0021_0000#' of "
                    & "'kernel_store_1' CPU Store memory element differs",
                    Message   => "Exception mismatch");
      end;
--  begin read only
   end Test_CPU_Store_Address_Equality;
--  end read only


--  begin read only
   procedure Test_Stack_Address_Equality (Gnattest_T : in out Test);
   procedure Test_Stack_Address_Equality_61fb48 (Gnattest_T : in out Test) renames Test_Stack_Address_Equality;
--  id:2.2/61fb4824388cbd39/Stack_Address_Equality/1/0/
   procedure Test_Stack_Address_Equality (Gnattest_T : in out Test) is
   --  mucfgcheck-kernel.ads:28:4:Stack_Address_Equality
--  end read only

      pragma Unreferenced (Gnattest_T);

      Data : Muxml.XML_Data_Type;
   begin
      Muxml.Parse (Data => Data,
                   Kind => Muxml.Format_B,
                   File => "data/test_policy.xml");
      Muxml.Utils.Set_Attribute
        (Doc   => Data.Doc,
         XPath => "/system/kernel/memory/cpu/memory"
         & "[@physical='kernel_stack_1']",
         Name  => "virtualAddress",
         Value => "16#0031_0000#");

      begin
         Stack_Address_Equality (XML_Data => Data);
         Assert (Condition => False,
                 Message   => "Exception expected");

      exception
         when E : Validation_Error =>
            Assert (Condition => Ada.Exceptions.Exception_Message (X => E)
                    = "Attribute 'virtualAddress => 16#0031_0000#' of "
                    & "'kernel_stack_1' kernel stack memory element differs",
                    Message   => "Exception mismatch");
      end;
--  begin read only
   end Test_Stack_Address_Equality;
--  end read only


--  begin read only
   procedure Test_IOMMU_Consecutiveness (Gnattest_T : in out Test);
   procedure Test_IOMMU_Consecutiveness_fc88d4 (Gnattest_T : in out Test) renames Test_IOMMU_Consecutiveness;
--  id:2.2/fc88d4365ce63af7/IOMMU_Consecutiveness/1/0/
   procedure Test_IOMMU_Consecutiveness (Gnattest_T : in out Test) is
   --  mucfgcheck-kernel.ads:31:4:IOMMU_Consecutiveness
--  end read only

      pragma Unreferenced (Gnattest_T);

      Data : Muxml.XML_Data_Type;
   begin
      Muxml.Parse (Data => Data,
                   Kind => Muxml.Format_B,
                   File => "data/test_policy.xml");
      Muxml.Utils.Set_Attribute
        (Doc   => Data.Doc,
         XPath => "/system/kernel/devices/device[@physical='iommu_2']/memory",
         Name  => "virtualAddress",
         Value => "16#0021_0000#");

      begin
         IOMMU_Consecutiveness (XML_Data => Data);
         Assert (Condition => False,
                 Message   => "Exception expected");

      exception
         when E : Validation_Error =>
            Assert (Condition => Ada.Exceptions.Exception_Message (X => E)
                    = "Mapping of MMIO region of IOMMU 'iommu_1' not adjacent "
                    & "to other IOMMU regions",
                    Message   => "Exception mismatch");
      end;
--  begin read only
   end Test_IOMMU_Consecutiveness;
--  end read only


--  begin read only
   procedure Test_CPU_Memory_Section_Count (Gnattest_T : in out Test);
   procedure Test_CPU_Memory_Section_Count_14dd51 (Gnattest_T : in out Test) renames Test_CPU_Memory_Section_Count;
--  id:2.2/14dd51df8988d4a1/CPU_Memory_Section_Count/1/0/
   procedure Test_CPU_Memory_Section_Count (Gnattest_T : in out Test) is
   --  mucfgcheck-kernel.ads:34:4:CPU_Memory_Section_Count
--  end read only

      pragma Unreferenced (Gnattest_T);

      Data : Muxml.XML_Data_Type;
   begin
      Muxml.Parse (Data => Data,
                   Kind => Muxml.Format_B,
                   File => "data/test_policy.xml");

      declare
         Mem_Node : constant DOM.Core.Node := Muxml.Utils.Get_Element
           (Doc   => Data.Doc,
            XPath => "/system/kernel/memory");
      begin
         Muxml.Utils.Remove_Child (Node       => Mem_Node,
                                   Child_Name => "cpu");

         CPU_Memory_Section_Count (XML_Data => Data);
         Assert (Condition => False,
                 Message   => "Exception expected");

      exception
         when E : Validation_Error =>
            Assert (Condition => Ada.Exceptions.Exception_Message (X => E)
                    = "Invalid number of kernel memory CPU section(s), 3 "
                    & "present but 4 required",
                    Message   => "Exception mismatch");
      end;
--  begin read only
   end Test_CPU_Memory_Section_Count;
--  end read only

end Mucfgcheck.Kernel.Test_Data.Tests;
