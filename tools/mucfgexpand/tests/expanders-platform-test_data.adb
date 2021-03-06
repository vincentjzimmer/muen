--  This package is intended to set up and tear down  the test environment.
--  Once created by GNATtest, this package will never be overwritten
--  automatically. Contents of this package can be modified in any way
--  except for sections surrounded by a 'read only' marker.

with DOM.Core.Documents;

with Muxml.Utils;

package body Expanders.Platform.Test_Data is

   -------------------------------------------------------------------------

   procedure Adjust_Subj_Device_Alias_Resources
     (Data : in out Muxml.XML_Data_Type)
   is
      Alias   : constant DOM.Core.Node
        := Muxml.Utils.Get_Element
          (Doc   => Data.Doc,
           XPath => "/system/platform/mappings/aliases/"
           & "alias[@name='wireless']");
      Log_Dev : constant DOM.Core.Node
        := Muxml.Utils.Get_Element
          (Doc   => Data.Doc,
           XPath => "/system/subjects/subject[@name='lnx']/devices/"
           & "device[@logical='wlan']");
   begin
      Muxml.Utils.Remove_Child (Node       => Alias,
                                Child_Name => "resource");
      Muxml.Utils.Remove_Child (Node       => Log_Dev,
                                Child_Name => "irq");
      Muxml.Utils.Remove_Child (Node       => Log_Dev,
                                Child_Name => "memory");
   end Adjust_Subj_Device_Alias_Resources;

   -------------------------------------------------------------------------

   procedure Set_Up (Gnattest_T : in out Test) is
      pragma Unreferenced (Gnattest_T);
   begin
      null;
   end Set_Up;

   -------------------------------------------------------------------------

   procedure Tear_Down (Gnattest_T : in out Test) is
      pragma Unreferenced (Gnattest_T);
   begin
      null;
   end Tear_Down;

   -------------------------------------------------------------------------

   procedure Remove_Platform_Section (Data : in out Muxml.XML_Data_Type)
   is
   begin
      Muxml.Utils.Remove_Child
        (Node       => DOM.Core.Documents.Get_Element (Doc => Data.Doc),
         Child_Name => "platform");
   end Remove_Platform_Section;

end Expanders.Platform.Test_Data;
