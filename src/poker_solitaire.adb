-------------------------------------------------------------------------------
-- Poker Solitaire - Main Program
-- A card game where you place cards in a 5x5 grid to make poker hands
--
-- Written in Ada with AdaGraph graphics library
-- Works on Windows and Linux
-------------------------------------------------------------------------------

with Ada.Text_IO;         use Ada.Text_IO;

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
   Input_Row    : Board_Index;
   Input_Col    : Board_Index;

   -- Game control
   Quit_Game    : Boolean := False;
   Quit_To_Menu : Boolean := False;
   Card_Dealt   : Boolean;
   Card_Placed  : Boolean;
   Valid_Input  : Boolean;

   -------------------------
   -- Show_Menu
   -------------------------
   procedure Show_Menu is
      Key : Character;
   begin
      loop
         -- Load current high scores
         declare
            Dummy : Boolean;
         begin
            Dummy := Load_Scores (Default_Filename, Scores);
         end;

         Display_Title;

         -- Wait for menu choice
         Key := Get_Key_Press;

         case Key is
            when '1' =>
               return;  -- Start new game

            when '2' =>
               Display_High_Scores_Screen;

               -- Show actual scores if we have them
               if Scores.Count > 0 then
                  declare
                     Y : Integer := 220;
                  begin
                     for I in 1 .. Scores.Count loop
                        if Scores.Scores (I).Valid then
                           -- Draw score entry (handled by AdaGraph's Goto_XY and Put)
                           null;  -- Scores displayed by Display_High_Scores_Screen
                        end if;
                     end loop;
                  end;
               end if;

               Wait_For_Input;

            when '3' =>
               Display_Help;
               Wait_For_Input;

            when '4' | 'q' | 'Q' =>
               Quit_Game := True;
               return;

            when others =>
               null;  -- Invalid choice, show menu again
         end case;
      end loop;
   end Show_Menu;

   -------------------------
   -- Play_Game
   -------------------------
   procedure Play_Game is
      Cards_Remaining : Natural;
   begin
      -- Initialize game
      Initialize_Game (Game);
      Initialize (Game_Deck);
      Shuffle (Game_Deck);
      Quit_To_Menu := False;

      -- Main game loop
      loop
         -- Deal next card
         Card_Dealt := Deck.Deal (Game_Deck, Current_Card);

         if not Card_Dealt or Game.Game_Over then
            exit;
         end if;

         Cards_Remaining := Deck.Cards_Remaining (Game_Deck);

         -- Display board and current card
         Clear_Window;
         Display_Board (Game);
         Display_Current_Card (Current_Card, Cards_Remaining + 1);
         Display_Input_Prompt;

         -- Get player input
         loop
            Valid_Input := Get_Position_Input (Input_Row, Input_Col);

            if not Valid_Input then
               -- User pressed Q or H
               if Key_Available then
                  -- Check if it was Q (quit)
                  Quit_To_Menu := True;
                  return;
               end if;

               -- It was H (help) - redraw and continue
               Clear_Window;
               Display_Board (Game);
               Display_Current_Card (Current_Card, Cards_Remaining + 1);
               Display_Input_Prompt;
            else
               -- Try to place the card
               if Is_Position_Empty (Game, Input_Row, Input_Col) then
                  Card_Placed := Place_Card (Game, Input_Row, Input_Col, Current_Card);
                  if Card_Placed then
                     exit;  -- Move to next card
                  end if;
               else
                  Display_Message ("Position occupied! Choose another slot.");
               end if;
            end if;
         end loop;
      end loop;

      -- Game over - show final board and scores
      Clear_Window;
      Display_Board (Game);
      Display_Game_Over (Game);
      Wait_For_Input;

      -- Check for high score
      declare
         Final_Score : constant Natural := Calculate_Total_Score (Game);
         Dummy       : Boolean;
         Player_Name : String (1 .. Max_Name_Length) := (others => ' ');
      begin
         -- Load current high scores
         Dummy := Load_Scores (Default_Filename, Scores);

         if Is_High_Score (Scores, Final_Score) then
            -- For graphical version, use a simple default name
            -- (A full implementation would need a text input dialog)
            Player_Name (1 .. 6) := "Player";

            Dummy := Add_Score (Scores, Player_Name, Final_Score);
            Dummy := Save_Scores (Default_Filename, Scores);

            Display_Message ("New High Score saved!");
            Wait_For_Input;
         end if;
      end;
   end Play_Game;

begin
   -- Initialize random number generator
   Initialize_Random;

   -- Initialize high scores
   Initialize (Scores);

   -- Initialize graphics
   Initialize_Graphics;

   -- Main program loop
   loop
      Show_Menu;

      exit when Quit_Game;

      Play_Game;

      exit when Quit_Game;
   end loop;

   -- Cleanup
   Close_Graphics;

exception
   when others =>
      -- Make sure graphics are closed on error
      Close_Graphics;
      raise;
end Poker_Solitaire;
