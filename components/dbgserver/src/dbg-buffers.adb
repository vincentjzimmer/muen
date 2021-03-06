--
--  Copyright (C) 2014  secunet Security Networks AG
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

with System;

with Interfaces;

with Dbg.Config;
with Dbg.Byte_Arrays;
with Dbg.Byte_Queue.Format;

package body Dbg.Buffers
is

   use type Interfaces.Unsigned_64;
   use type Debuglog.Stream.Reader.Result_Type;

   --  Log channels for subjects defined in the active system policy. The
   --  dbgserver subject is excluded and it's assumed to be the last (ID wise)
   --  subject in the policy.
   type Log_Context_Type is array (Subject_Buffer_Range)
     of Debuglog.Stream.Channel_Type
       with
         Component_Size => 8 * Config.Channel_Size,
         Size           => 8 * Config.Channel_Size
           * (Subject_Buffer_Range'Last + 1);

   Log_Context : Log_Context_Type
     with
       Address => System'To_Address (Config.Channels_Base_Addr);

   Timestamp_Invalid : constant Interfaces.Unsigned_64
     := Interfaces.Unsigned_64'Last;

   --  Check if a message is present in the given subject buffer.
   function Is_Message_Present
     (Subject_Buffer : Subject_Buffer_Type)
      return Boolean;

   --  Mark given subject buffer as logged.
   procedure Mark_As_Logged (Subject_Buffer : in out Subject_Buffer_Type);

   --  Check all subject buffers for new messages.
   procedure Update_Message_Buffers (Buffer : in out Buffer_Type);

   --  Find subject with oldest message.
   procedure Find_Oldest_Message
     (Buffer         :     Buffer_Type;
      Oldest_Subject : out Subject_Buffer_Range;
      Found          : out Boolean);

   --  Add log line prefix for given subject to output queue.
   procedure Add_Line_Prefix
     (Subject      :        Subject_Buffer_Range;
      Overrun      :        Boolean;
      New_Epoch    :        Boolean;
      Continuation :        Boolean;
      Output_Queue : in out Byte_Queue.Queue_Type);

   --  Add message in subject buffer to output queue.
   procedure Add_Message
     (Subject_Buffer : in out Subject_Buffer_Type;
      Output_Queue   : in out Byte_Queue.Queue_Type);

   --  Move message of given subject to output queue.
   procedure Log_Message
     (Buffer       : in out Buffer_Type;
      Subject      :        Subject_Buffer_Range;
      Output_Queue : in out Byte_Queue.Queue_Type);

   --  Find oldest message and log it.
   procedure Log_Oldest_Message
     (Buffer       : in out Buffer_Type;
      Output_Queue : in out Byte_Queue.Queue_Type);

   --  Append idle mark to output queue.
   procedure Idle_Mark
     (Buffer       : in out Buffer_Type;
      Output_Queue : in out Byte_Queue.Queue_Type);

   --  Echo content of input queue into output queue.
   procedure Echo (Input, Output : in out Byte_Queue.Queue_Type);

   -------------------------------------------------------------------------

   procedure Add_Line_Prefix
     (Subject      :        Subject_Buffer_Range;
      Overrun      :        Boolean;
      New_Epoch    :        Boolean;
      Continuation :        Boolean;
      Output_Queue : in out Byte_Queue.Queue_Type)
   is
   begin
      Byte_Queue.Format.Append_New_Line (Queue => Output_Queue);

      Byte_Queue.Format.Append_Number
        (Queue => Output_Queue,
         Item  => Interfaces.Unsigned_64 (Subject),
         Len   => 4);

      if New_Epoch then
         Byte_Queue.Format.Append_Character
           (Queue => Output_Queue,
            Item  => '%');
      elsif Overrun then
         Byte_Queue.Format.Append_Character
           (Queue => Output_Queue,
            Item  => '#');
      elsif Continuation then
         Byte_Queue.Format.Append_Character
           (Queue => Output_Queue,
            Item  => '>');
      else
         Byte_Queue.Format.Append_Character
           (Queue => Output_Queue,
            Item  => '|');
      end if;
   end Add_Line_Prefix;

   -------------------------------------------------------------------------

   procedure Add_Message
     (Subject_Buffer : in out Subject_Buffer_Type;
      Output_Queue   : in out Byte_Queue.Queue_Type)
   is
      Char : Character;
   begin
      for Index in Debuglog.Types.Message_Index loop
         Char := Subject_Buffer.Cache.Message (Index);

         exit when Char = ASCII.LF or Char = ASCII.NUL;

         Byte_Queue.Format.Append_Character
           (Queue => Output_Queue,
            Item  => Char);
      end loop;

      Subject_Buffer.Message_Incomplete := Char /= ASCII.LF;
   end Add_Message;

   ----------------------------------------------------------------------

   procedure Echo (Input, Output : in out Byte_Queue.Queue_Type)
   is
      subtype Echo_Buffer_Range is Positive range 1 .. 64;
      subtype Echo_Buffer_Type is Byte_Arrays.Byte_Array
        (Echo_Buffer_Range);

      Echo_Buffer : Echo_Buffer_Type;
      Length      : Natural;
   begin
      if Byte_Queue.Bytes_Free (Queue => Output) >= Echo_Buffer'Length
        and Byte_Queue.Bytes_Used (Queue => Input) > 0
      then
         Byte_Queue.Peek
           (Queue  => Input,
            Buffer => Echo_Buffer,
            Length => Length);
         Byte_Queue.Drop_Bytes
           (Queue  => Input,
            Length => Length);
         Byte_Queue.Append
           (Queue  => Output,
            Buffer => Echo_Buffer,
            Length => Length);
      end if;
   end Echo;

   -------------------------------------------------------------------------

   procedure Find_Oldest_Message
     (Buffer         :     Buffer_Type;
      Oldest_Subject : out Subject_Buffer_Range;
      Found          : out Boolean)
   is
      Candidate_Timestamp : Interfaces.Unsigned_64 := Timestamp_Invalid;
   begin
      Oldest_Subject := Subject_Buffer_Range'First;
      Found          := False;

      for Subject in Subject_Buffer_Range loop
         if Buffer.Subjects (Subject).Cache.Timestamp < Candidate_Timestamp
         then
            Candidate_Timestamp := Buffer.Subjects (Subject).Cache.Timestamp;
            Oldest_Subject      := Subject;
            Found               := True;
         end if;
      end loop;
   end Find_Oldest_Message;

   -------------------------------------------------------------------------

   procedure Idle_Mark
     (Buffer       : in out Buffer_Type;
      Output_Queue : in out Byte_Queue.Queue_Type)
   is
   begin
      if not Buffer.Is_Idle and then
        Byte_Queue.Bytes_Free (Queue => Output_Queue) >= 5
      then
         Byte_Queue.Format.Append_New_Line (Queue => Output_Queue);
         Byte_Queue.Format.Append_String (Queue => Output_Queue,
                                          Item  => "---");
         Buffer.Is_Idle := True;
      end if;
   end Idle_Mark;

   -------------------------------------------------------------------------

   procedure Initialize (Buffer : out Buffer_Type)
   is
      --  Initialize given subject buffer.
      procedure Initialize_Subject (Subject_Buffer : out Subject_Buffer_Type);

      ----------------------------------------------------------------------

      procedure Initialize_Subject (Subject_Buffer : out Subject_Buffer_Type)
      is
      begin
         Subject_Buffer.State := Debuglog.Stream.Reader.Null_Reader;
         Subject_Buffer.Cache := Debuglog.Types.Data_Type'
           (Timestamp => Timestamp_Invalid,
            Message   => Debuglog.Types.Null_Message);

         Subject_Buffer.Message_Incomplete := False;
         Subject_Buffer.Overrun_Occurred   := False;
         Subject_Buffer.New_Epoch_Occurred := False;
         Subject_Buffer.Enabled            := True;
      end Initialize_Subject;
   begin
      for Subject in Subject_Buffer_Range loop
         Initialize_Subject (Subject_Buffer => Buffer.Subjects (Subject));
      end loop;

      Buffer.Is_Idle      := False;
      Buffer.Last_Subject := Subject_Buffer_Range'First;
   end Initialize;

   -------------------------------------------------------------------------

   function Is_Message_Present
     (Subject_Buffer : Subject_Buffer_Type)
      return Boolean
   is
   begin
      return Subject_Buffer.Cache.Timestamp /= Timestamp_Invalid;
   end Is_Message_Present;

   -------------------------------------------------------------------------

   procedure Log_Message
     (Buffer       : in out Buffer_Type;
      Subject      :        Subject_Buffer_Range;
      Output_Queue : in out Byte_Queue.Queue_Type)
   is
   begin
      if Byte_Queue.Bytes_Free (Queue => Output_Queue) >= 64 then
         if not Buffer.Subjects (Subject).Message_Incomplete
           or Buffer.Last_Subject /= Subject
           or Buffer.Subjects (Subject).Overrun_Occurred
           or Buffer.Subjects (Subject).New_Epoch_Occurred
           or Buffer.Is_Idle
         then
            Add_Line_Prefix
              (Subject      => Subject,
               Overrun      => Buffer.Subjects (Subject).Overrun_Occurred,
               New_Epoch    => Buffer.Subjects (Subject).New_Epoch_Occurred,
               Continuation => Buffer.Subjects (Subject).Message_Incomplete,
               Output_Queue => Output_Queue);
         end if;

         Add_Message (Subject_Buffer => Buffer.Subjects (Subject),
                      Output_Queue   => Output_Queue);
         Mark_As_Logged (Subject_Buffer => Buffer.Subjects (Subject));
         Buffer.Last_Subject := Subject;

         Buffer.Subjects (Subject).Overrun_Occurred   := False;
         Buffer.Subjects (Subject).New_Epoch_Occurred := False;
         Buffer.Is_Idle := False;
      end if;
   end Log_Message;

   -------------------------------------------------------------------------

   procedure Log_Oldest_Message
     (Buffer       : in out Buffer_Type;
      Output_Queue : in out Byte_Queue.Queue_Type)
   is
      Subject         : Subject_Buffer_Range;
      Message_Present : Boolean;
   begin
      Find_Oldest_Message (Buffer         => Buffer,
                           Oldest_Subject => Subject,
                           Found          => Message_Present);

      if Message_Present then
         Log_Message (Buffer       => Buffer,
                      Subject      => Subject,
                      Output_Queue => Output_Queue);
      else
         Idle_Mark (Buffer       => Buffer,
                    Output_Queue => Output_Queue);
      end if;
   end Log_Oldest_Message;

   -------------------------------------------------------------------------

   procedure Mark_As_Logged (Subject_Buffer : in out Subject_Buffer_Type)
   is
   begin
      Subject_Buffer.Cache.Timestamp := Timestamp_Invalid;
   end Mark_As_Logged;

   -------------------------------------------------------------------------

   procedure Run
     (Buffer       : in out Buffer_Type;
      Input_Queue  : in out Byte_Queue.Queue_Type;
      Output_Queue : in out Byte_Queue.Queue_Type)
   is
   begin
      Update_Message_Buffers
        (Buffer => Buffer);
      Log_Oldest_Message
        (Buffer       => Buffer,
         Output_Queue => Output_Queue);
      Echo (Input  => Input_Queue,
            Output => Output_Queue);
   end Run;

   -------------------------------------------------------------------------

   procedure Update_Message_Buffers (Buffer : in out Buffer_Type)
   is
      --  Check given subject buffer for new message.
      procedure Update_Message_Buffer
        (Subject        :        Subject_Buffer_Range;
         Subject_Buffer : in out Subject_Buffer_Type);

      ----------------------------------------------------------------------

      procedure Update_Message_Buffer
        (Subject        :        Subject_Buffer_Range;
         Subject_Buffer : in out Subject_Buffer_Type)
      is
         Read_Result : Debuglog.Stream.Reader.Result_Type;
      begin
         if not Is_Message_Present (Subject_Buffer => Subject_Buffer) then
            Debuglog.Stream.Reader.Read
              (Channel => Log_Context (Subject),
               Reader  => Subject_Buffer.State,
               Element => Subject_Buffer.Cache,
               Result  => Read_Result);

            if Read_Result = Debuglog.Stream.Reader.Epoch_Changed then
               Subject_Buffer.New_Epoch_Occurred := True;
            elsif Read_Result = Debuglog.Stream.Reader.Overrun_Detected then
               Subject_Buffer.Overrun_Occurred := True;
            end if;

            if Read_Result /= Debuglog.Stream.Reader.Success then

               --  Mark cache as empty

               Subject_Buffer.Cache := Debuglog.Types.Data_Type'
                 (Timestamp => Timestamp_Invalid,
                  Message   => Debuglog.Types.Null_Message);
            end if;
         end if;
      end Update_Message_Buffer;
   begin
      for Subject in Subject_Buffer_Range loop
         if Buffer.Subjects (Subject).Enabled then
            Update_Message_Buffer
              (Subject        => Subject,
               Subject_Buffer => Buffer.Subjects (Subject));
         end if;
      end loop;
   end Update_Message_Buffers;

end Dbg.Buffers;
