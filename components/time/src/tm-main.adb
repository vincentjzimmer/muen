--
--  Copyright (C) 2015  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2015  Adrian-Ken Rueegsegger <ken@codelabs.ch>
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

with SK.CPU;

pragma $Release_Warnings (Off, "unit * is not referenced");
with Debuglog.Client;
pragma $Release_Warnings (On, "unit * is not referenced");

with Mutime.Info;
with Musinfo;

with Tm.Rtc;
with Tm.Utils;

package body Tm.Main
with
   Refined_State => (State => Sinfo)
is

   Sinfo : Musinfo.Subject_Info_Type
     with
       Volatile,
       Async_Writers,
       Effective_Reads,
       Address => System'To_Address (Subject_Info_Virtual_Addr);

   Subject_Info_Virtual_Addr : constant := 16#000e_0000_0000#;

   -------------------------------------------------------------------------

   procedure Run
   is
      use type Interfaces.Unsigned_8;

      Rtc_Time  : Rtc.Time_Type;
      Date_Time : Mutime.Date_Time_Type;
      TSC_Value : Interfaces.Unsigned_64;
      Success   : Boolean;
   begin
      pragma Debug (Debuglog.Client.Put_Line (Item => "Time subject running"));

      Rtc.Read_Time (T => Rtc_Time);
      TSC_Value := Interfaces.Unsigned_64 (SK.CPU.RDTSC64);

      pragma Debug (Debuglog.Client.Put      (Item => "RTC date/time: "));
      pragma Debug (Debuglog.Client.Put_Byte (Item => Rtc_Time.Century));
      pragma Debug (Debuglog.Client.Put_Byte (Item => Rtc_Time.Year));
      pragma Debug (Debuglog.Client.Put      (Item => "-"));
      pragma Debug (Debuglog.Client.Put_Byte (Item => Rtc_Time.Month));
      pragma Debug (Debuglog.Client.Put      (Item => "-"));
      pragma Debug (Debuglog.Client.Put_Byte (Item => Rtc_Time.Day));
      pragma Debug (Debuglog.Client.Put      (Item => "T"));
      pragma Debug (Debuglog.Client.Put_Byte (Item => Rtc_Time.Hour));
      pragma Debug (Debuglog.Client.Put      (Item => ":"));
      pragma Debug (Debuglog.Client.Put_Byte (Item => Rtc_Time.Minute));
      pragma Debug (Debuglog.Client.Put      (Item => ":"));
      pragma Debug (Debuglog.Client.Put_Byte (Item => Rtc_Time.Second));
      pragma Debug (Debuglog.Client.New_Line);

      pragma Debug (Debuglog.Client.Put_Reg8 (Name  => "RTC status B",
                                              Value => Rtc_Time.Status_B));

      Utils.To_Mutime (Rtc_Time  => Rtc_Time,
                       Date_Time => Date_Time,
                       Success   => Success);
      if Success then
         declare
            use type Interfaces.Unsigned_64;
            use type Mutime.Timestamp_Type;

            Timestamp : Mutime.Timestamp_Type;
            TSC_Khz   : constant Musinfo.TSC_Tick_Rate_Khz_Type
              := Sinfo.TSC_Khz;
            TSC_Hz    : constant Mutime.Info.TSC_Tick_Rate_Hz_Type
              := TSC_Khz * 1000;
            TSC_Mhz   : constant Interfaces.Unsigned_64
              := TSC_Khz / 1000;

            Microsecs_Boot : Interfaces.Unsigned_64;
         begin
            Timestamp := Mutime.Time_Of (Date_Time => Date_Time);
            Microsecs_Boot := TSC_Value / TSC_Mhz;

            Timestamp := Timestamp - Microsecs_Boot;

            pragma Debug
              (Debuglog.Client.Put_Reg64
                 (Name  => "Microseconds since boot",
                  Value => Microsecs_Boot));
            pragma Debug
              (Debuglog.Client.Put_Reg64
                 (Name  => "Mutime timestamp",
                  Value => Mutime.Get_Value (Timestamp => Timestamp)));
            pragma Debug
              (Debuglog.Client.Put_Line
                 (Item => "Exporting time information to clients"));

            Publish.Update (TSC_Time_Base => Timestamp,
                            TSC_Tick_Rate => TSC_Hz,
                            Timezone      => 0);
         end;
      end if;

      pragma Debug (not Success, Debuglog.Client.Put_Line
                    (Item => "Error: Unable to convert RTC date/time"));
      loop
         SK.CPU.Hlt;
      end loop;
   end Run;

end Tm.Main;
