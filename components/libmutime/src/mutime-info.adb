--
--  Copyright (C) 2015  Reto Buerki <reet@codelabs.ch>
--  Copyright (C) 2015  Adrian-Ken Rueegsegger <ken@codelabs.ch>
--  All rights reserved.
--
--  Redistribution and use in source and binary forms, with or without
--  modification, are permitted provided that the following conditions are met:
--
--    * Redistributions of source code must retain the above copyright notice,
--      this list of conditions and the following disclaimer.
--
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--
--  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
--  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
--  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
--  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
--  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
--  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
--  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
--  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
--  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
--  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
--  POSSIBILITY OF SUCH DAMAGE.
--

package body Mutime.Info
is

   -------------------------------------------------------------------------

   procedure Get_Current_Time
     (Time_Info      :     Time_Info_Type;
      Schedule_Ticks :     Integer_62;
      Correction     : out Integer_63;
      Timestamp      : out Timestamp_Type)
   is
      use type Interfaces.Unsigned_64;

      --  TSC tick rate in MHz from 1 Mhz to 100 Ghz.
      subtype TSC_Tick_Rate_Mhz_Type is Integer_62 range 1 .. 100000;

      TSC_Tick_Rate_Mhz : constant TSC_Tick_Rate_Mhz_Type
        := TSC_Tick_Rate_Mhz_Type (Time_Info.TSC_Tick_Rate_Hz / 10 ** 6);
   begin
      Timestamp := Time_Info.TSC_Time_Base;

      Correction := Time_Info.Timezone_Microsecs + Integer_62
        (Schedule_Ticks / TSC_Tick_Rate_Mhz);

      Timestamp := Timestamp + Correction;
   end Get_Current_Time;

end Mutime.Info;
