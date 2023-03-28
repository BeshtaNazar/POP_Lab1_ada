with Ada.Text_IO;

procedure Main is
   Num_Tasks: Integer := 3;
   Can_stop: Array(1..Num_Tasks) of Boolean;
   Delays: Array(1..Num_Tasks) of Duration;
   IdArray: Array(1..Num_Tasks) of Integer;
   Dur : Duration := 5.0;
   Step : Long_Long_Integer:=1;
   Num_Tasks_Temp_1 : Integer:=Num_Tasks-1;
   Num_Tasks_Temp_2 : Integer:= Num_Tasks-1;
   Id_Temp : Integer;
   Delay_Temp: Duration;


   task type break_thread;
   task type main_thread is
      entry Start(Id : Integer; Step : Long_Long_Integer);
   end main_thread;

   task body break_thread is
      time : Duration:=0.0;
   begin
      delay 3.0;
      for I in 1..Num_Tasks_Temp_1 loop
         for J in 1..Num_Tasks_Temp_2 loop
            if Delays(J)>Delays(J+1) then
               Delay_Temp:=Delays(J);
               Id_Temp:=IdArray(J);
               Delays(J):=Delays(J+1);
               IdArray(J):=IdArray(J+1);
               Delays(J+1):=Delay_Temp;
               IdArray(J+1):=Id_Temp;
            end if;
         end loop;
         Num_Tasks_Temp_2:=Num_Tasks_Temp_1-I;
      end loop;
      for I in 1..Num_Tasks loop
         delay Delays(I)-time;
         Can_stop(IdArray(I)):=True;
         time:= time+(Delays(I)-time);
      end loop;
   end break_thread;

   task body main_thread is
      sum : Long_Long_Integer := 0;
      Amount: Long_Long_Integer:=0;
      Id : Integer;
      Step : Long_Long_Integer;
   begin
      accept Start (Id : in Integer; Step : in Long_Long_Integer) do
         main_thread.Id:=Id;
         main_thread.Step:=Step;
      end Start;
      loop
         sum := sum + Step;
         Amount:=Amount+1;
         exit when Can_stop(Id);
      end loop;
      Ada.Text_IO.Put_Line(Id'Img&sum'Img&Amount'Img);
   end main_thread;

   b: break_thread;
begin
   for I in 1..Num_Tasks loop
      IdArray(I):=I;
      Delays(I):=Dur;
      Dur:=Dur-1.0;
      Can_stop(I):=False;
   end loop;
   declare
      Tasks: Array(1..Num_Tasks) of main_thread;
   begin
      for I in 1..Num_Tasks loop
         Tasks(I).Start(IdArray(I), Step);
         Step:=Step+1;
      end loop;
   end;
end Main;
