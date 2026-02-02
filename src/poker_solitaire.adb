-------------------------------------------------------------------------------
-- Poker Solitaire - Main Program
-- A card game where you place cards in a 5x5 grid to make poker hands
--
-- Written entirely in Ada with no external dependencies
-- Works on Windows and Linux terminals
-------------------------------------------------------------------------------

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Strings.Fixed;   use Ada.Strings.Fixed;

with Cards;       use Cards;
with Deck;        use Deck;
with Game_Board;  use Game_Board;
with Poker_Hands; use Poker_Hands;
with Display;     use Display;
with High_Scores; use High_Scores;

procedure Poker_Solitaire is

   -- Game state variables
   Game         : Game_State;
   Game_Deck    : Deck_Type;
   Current_Card : Card_Type;
   Scores       : High_Score_Data;

   -- Input handling
   Input_Line   : String (1 .. 80);
   Input_Last   : Natural;
   Input_Row    : Natural;
   Input_Col    : Natural;

   -- Game control
   Quit_Game    : Boolean := False;
   Card_Dealt   : Boolean;
   Card_Placed  : Boolean;

   -- Name input for high scores
   Player_Name  : String (1 .. Max_Name_Length);
   Name_Last    : Natural;

   -------------------------
   -- Parse_Input
   -------------------------
   -- Parse "row col" input, returns True if valid
   function Parse_Input (Line : String;
                         Last : Natural;
                         Row  : out Natural;
                         Col  : out Natural) return Boolean is
      Space_Pos : Natural := 0;
      First_Num : Natural := 0;
      Second_Start : Natural := 0;
   begin
      Row := 0;
      Col := 0;

      if Last = 0 then
         return False;
      end if;

      -- Find first number
      for I in 1 .. Last loop
         if Line (I) in '1' .. '5' then
            if First_Num = 0 then
               First_Num := I;
               Row := Character'Pos (Line (I)) - Character'Pos ('0');
            elsif Second_Start = 0 then
               Second_Start := I;
               Col := Character'Pos (Line (I)) - Character'Pos ('0');
               return True;
            end if;
         elsif Line (I) = ' ' or Line (I) = ',' or Line (I) = '-' then
            -- Separator, continue looking
            null;
         elsif First_Num > 0 and then Line (I) not in '0' .. '9' then
            -- Non-digit after first number found
            null;
         end if;
      end loop;

      return Row > 0 and Col > 0;
   end Parse_Input;

   -------------------------
   -- Show_Menu
   -------------------------
   procedure Show_Menu is
      Choice : String (1 .. 10);
      Last   : Natural;
   begin
      loop
         Clear_Screen;
         Display_Title;

         -- Load and show current high score
         if Load_Scores (Default_Filename, Scores) then
            Put ("Current High Score: " & Natural'Image (Get_Top_Score (Scores)));
         else
            Put ("No high scores yet - be the first!");
         end if;
         New_Line;
         New_Line;

         Print_Line ("MENU:");
         Print_Line ("  1. New Game");
         Print_Line ("  2. View High Scores");
         Print_Line ("  3. How to Play");
         Print_Line ("  4. Quit");
         New_Line;
         Put ("Enter choice (1-4): ");

         Get_Line (Choice, Last);

         if Last >= 1 then
            case Choice (1) is
               when '1' =>
                  return;  -- Start new game

               when '2' =>
                  Clear_Screen;
                  if Load_Scores (Default_Filename, Scores) then
                     Display_Scores (Scores);
                  else
                     Initialize (Scores);
                     Display_Scores (Scores);
                  end if;
                  Wait_For_Enter;

               when '3' =>
                  Clear_Screen;
                  Display_Help;
                  Wait_For_Enter;

               when '4' =>
                  Quit_Game := True;
                  return;

               when others =>
                  null;  -- Invalid choice, show menu again
            end case;
         end if;
      end loop;
   end Show_Menu;

   -------------------------
   -- Play_Game
   -------------------------
   procedure Play_Game is
   begin
      -- Initialize game
      Initialize_Game (Game);
      Initialize (Game_Deck);
      Shuffle (Game_Deck);

      -- Main game loop
      loop
         -- Deal next card
         Card_Dealt := Deck.Deal (Game_Deck, Current_Card);

         if not Card_Dealt or Game.Game_Over then
            exit;
         end if;

         -- Display board and current card
         Display_Board (Game);
         Display_Current_Card (Current_Card);

         -- Get player input
         loop
            Get_Line (Input_Line, Input_Last);

            -- Check for commands
            if Input_Last >= 1 then
               declare
                  First_Char : constant Character :=
                    Input_Line (1);
               begin
                  case First_Char is
                     when 'q' | 'Q' =>
                        Quit_Game := True;
                        return;

                     when 'h' | 'H' =>
                        Clear_Screen;
                        Display_Help;
                        Wait_For_Enter;
                        Display_Board (Game);
                        Display_Current_Card (Current_Card);

                     when '1' .. '5' =>
                        -- Try to parse as position
                        if Parse_Input (Input_Line, Input_Last,
                                        Input_Row, Input_Col) then
                           -- Attempt to place card
                           Card_Placed := Place_Card (Game,
                                                      Board_Index (Input_Row),
                                                      Board_Index (Input_Col),
                                                      Current_Card);
                           if Card_Placed then
                              exit;  -- Move to next card
                           else
                              Move_To (49, 0);
                              Put ("Position occupied! Choose another: ");
                           end if;
                        else
                           Move_To (49, 0);
                           Put ("Invalid input. Enter row col (1-5): ");
                        end if;

                     when others =>
                        Move_To (49, 0);
                        Put ("Invalid input. Enter row col (1-5): ");
                  end case;
               end;
            else
               Move_To (49, 0);
               Put ("Please enter position (row col): ");
            end if;
         end loop;
      end loop;

      -- Game over
      Display_Board (Game);
      Display_Game_Over (Game);

      -- Check for high score
      declare
         Final_Score : constant Natural := Calculate_Total_Score (Game);
         Dummy       : Boolean;
      begin
         -- Load current high scores
         Dummy := Load_Scores (Default_Filename, Scores);

         if Is_High_Score (Scores, Final_Score) then
            New_Line;
            Print_Line ("*** NEW HIGH SCORE! ***");
            Put ("Enter your name: ");
            Get_Line (Player_Name, Name_Last);

            if Name_Last > 0 then
               Dummy := Add_Score (Scores,
                                   Player_Name (1 .. Name_Last),
                                   Final_Score);
               Dummy := Save_Scores (Default_Filename, Scores);
               Print_Line ("Score saved!");
            end if;
         end if;
      end;

      New_Line;
      Wait_For_Enter;
   end Play_Game;

begin
   -- Initialize random number generator
   Initialize_Random;

   -- Initialize high scores
   Initialize (Scores);

   -- Main program loop
   loop
      Show_Menu;

      exit when Quit_Game;

      Play_Game;

      exit when Quit_Game;
   end loop;

   Clear_Screen;
   Print_Line ("Thank you for playing Poker Solitaire!");
   Print_Line ("Written in Ada - no external libraries used.");
   New_Line;

end Poker_Solitaire;
