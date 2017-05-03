-----------------------------------------------------------------------
--  Adafr-server -- Application server
--  Copyright (C) 2017 Ada France
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-----------------------------------------------------------------------
with Ada.Exceptions;

with Util.Log.loggers;

with AWS.Config.Set;
with ASF.Server.Web;
with AWA.Setup.Applications;

with Adafr.Applications;
procedure Adafr.Server is

   procedure Configure (Config : in out AWS.Config.Object);


   Log     : constant Util.Log.Loggers.Logger := Util.Log.Loggers.Create ("Adafr.Server");
   App     : constant Adafr.Applications.Application_Access := new Adafr.Applications.Application;
   WS      : ASF.Server.Web.AWS_Container;

   procedure Setup is
     new AWA.Setup.Applications.Configure (Adafr.Applications.Application'Class,
                                           Adafr.Applications.Application_Access,
                                           Adafr.Applications.Initialize);

   procedure Configure (Config : in out AWS.Config.Object) is
   begin
      AWS.Config.Set.Input_Line_Size_Limit (1_000_000);
      AWS.Config.Set.Max_Connection (Config, 2);
      AWS.Config.Set.Accept_Queue_Size (Config, 100);
      AWS.Config.Set.Send_Buffer_Size (Config, 128 * 1024);
      AWS.Config.Set.Upload_Size_Limit (Config, 100_000_000);
   end Configure;

begin
   WS.Configure (Configure'Access);
   WS.Start;
   Log.Info ("Connect you browser to: http://localhost:8080{0}/index.html",
             Adafr.Applications.CONTEXT_PATH);
   Setup (WS, App, "adafr", Adafr.Applications.CONTEXT_PATH);
   delay 365.0 * 24.0 * 3600.0;
   App.Close;
exception
   when E: others =>
      Log.Error ("Exception in server: " &
                 Ada.Exceptions.Exception_Name (E) & ": " &
                 Ada.Exceptions.Exception_Message (E));
end Adafr.Server;