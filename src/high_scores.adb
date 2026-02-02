-------------------------------------------------------------------------------
-- High_Scores Package Body
-- Implementation of high score management
-------------------------------------------------------------------------------

with Ada.Text_IO;            use Ada.Text_IO;
with Ada.Integer_Text_IO;    use Ada.Integer_Text_IO;
with Ada.Strings.Fixed;      use Ada.Strings.Fixed;

package body High_Scores is

   -- File signature for validation
   File_Signature : constant String := "PKSOL10";

   -------------------------
   -- Initialize
   -------------------------
   procedure Initialize (Data : out High_Score_Data) is
   begin
      Data.Count := 0;
      for I in Data.Scores'Range loop
         Data.Scores (I).Name := (others => ' ');
         Data.Scores (I).Score := 0;
         Data.Scores (I).Valid := False;
      end loop;
   end Initialize;

   -------------------------
   -- Format_Name
   -------------------------
   function Format_Name (Name : String) return String is
      Result : String (1 .. Max_Name_Length) := (others => ' ');
      Len    : constant Natural := Natural'Min (Name'Length, Max_Name_Length);
   begin
      Result (1 .. Len) := Name (Name'First .. Name'First + Len - 1);
      return Result;
   end Format_Name;

   -------------------------
   -- Load_Scores
   -------------------------
   function Load_Scores (Filename : String;
                         Data     : out High_Score_Data) return Boolean is
      File       : File_Type;
      Line       : String (1 .. 100);
      Last       : Natural;
      Score      : Natural;
      Name_Start : Natural;
   begin
      Initialize (Data);

      begin
         Open (File, In_File, Filename);
      exception
         when Name_Error | Use_Error =>
            return False;
      end;

      -- Read and verify signature
      begin
         Get_Line (File, Line, Last);
         if Last < File_Signature'Length or else
            Line (1 .. File_Signature'Length) /= File_Signature
         then
            Close (File);
            return False;
         end if;
      exception
         when others =>
            Close (File);
            return False;
      end;

      -- Read scores
      while not End_Of_File (File) and Data.Count < Max_Scores loop
         begin
            Get_Line (File, Line, Last);

            if Last > 0 then
               -- Parse: "SCORE NAME"
               -- Find the first space after score
               Name_Start := 1;
               while Name_Start <= Last and then Line (Name_Start) /= ' ' loop
                  Name_Start := Name_Start + 1;
               end loop;

               if Name_Start > 1 then
                  Score := Natural'Value (Line (1 .. Name_Start - 1));
                  Name_Start := Name_Start + 1;

                  Data.Count := Data.Count + 1;
                  Data.Scores (Data.Count).Score := Score;
                  Data.Scores (Data.Count).Valid := True;

                  if Name_Start <= Last then
                     Data.Scores (Data.Count).Name :=
                       Format_Name (Line (Name_Start .. Last));
                  else
                     Data.Scores (Data.Count).Name := Format_Name ("Unknown");
                  end if;
               end if;
            end if;
         exception
            when others =>
               null;  -- Skip malformed lines
         end;
      end loop;

      Close (File);
      return True;

   exception
      when others =>
         if Is_Open (File) then
            Close (File);
         end if;
         Initialize (Data);
         return False;
   end Load_Scores;

   -------------------------
   -- Save_Scores
   -------------------------
   function Save_Scores (Filename : String;
                         Data     : High_Score_Data) return Boolean is
      File : File_Type;
   begin
      begin
         Create (File, Out_File, Filename);
      exception
         when others =>
            return False;
      end;

      -- Write signature
      Put_Line (File, File_Signature);

      -- Write scores
      for I in 1 .. Data.Count loop
         if Data.Scores (I).Valid then
            Put (File, Data.Scores (I).Score, Width => 0);
            Put (File, " ");
            Put_Line (File, Trim (Data.Scores (I).Name, Ada.Strings.Both));
         end if;
      end loop;

      Close (File);
      return True;

   exception
      when others =>
         if Is_Open (File) then
            Close (File);
         end if;
         return False;
   end Save_Scores;

   -------------------------
   -- Is_High_Score
   -------------------------
   function Is_High_Score (Data  : High_Score_Data;
                           Score : Natural) return Boolean is
   begin
      -- Always a high score if list isn't full
      if Data.Count < Max_Scores then
         return True;
      end if;

      -- Check if better than worst score
      return Score > Data.Scores (Data.Count).Score;
   end Is_High_Score;

   -------------------------
   -- Add_Score
   -------------------------
   function Add_Score (Data  : in out High_Score_Data;
                       Name  : String;
                       Score : Natural) return Boolean is
      New_Entry : Score_Entry;
      Position  : Natural := Data.Count + 1;
   begin
      -- Check if qualifies
      if not Is_High_Score (Data, Score) then
         return False;
      end if;

      -- Create new entry
      New_Entry.Name := Format_Name (Name);
      New_Entry.Score := Score;
      New_Entry.Valid := True;

      -- Find position (sorted descending by score)
      for I in 1 .. Data.Count loop
         if Score > Data.Scores (I).Score then
            Position := I;
            exit;
         end if;
      end loop;

      -- Shift lower scores down
      if Position <= Max_Scores then
         for I in reverse Position .. Natural'Min (Data.Count, Max_Scores - 1) loop
            Data.Scores (I + 1) := Data.Scores (I);
         end loop;

         -- Insert new score
         Data.Scores (Position) := New_Entry;

         -- Update count
         if Data.Count < Max_Scores then
            Data.Count := Data.Count + 1;
         end if;
      end if;

      return True;
   end Add_Score;

   -------------------------
   -- Get_Top_Score
   -------------------------
   function Get_Top_Score (Data : High_Score_Data) return Natural is
   begin
      if Data.Count = 0 then
         return 0;
      else
         return Data.Scores (1).Score;
      end if;
   end Get_Top_Score;

   -------------------------
   -- Display_Scores
   -------------------------
   procedure Display_Scores (Data : High_Score_Data) is
   begin
      Put_Line ("========================================");
      Put_Line ("           HIGH SCORES                  ");
      Put_Line ("========================================");
      New_Line;

      if Data.Count = 0 then
         Put_Line ("  No high scores yet!");
         Put_Line ("  Be the first to set a record!");
      else
         Put_Line ("  Rank  Score  Name");
         Put_Line ("  ----  -----  --------------------");

         for I in 1 .. Data.Count loop
            if Data.Scores (I).Valid then
               Put ("  ");
               Put (I, Width => 2);
               Put (".   ");
               Put (Data.Scores (I).Score, Width => 3);
               Put ("   ");
               Put_Line (Trim (Data.Scores (I).Name, Ada.Strings.Both));
            end if;
         end loop;
      end if;

      New_Line;
      Put_Line ("========================================");
   end Display_Scores;

end High_Scores;
