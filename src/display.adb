-------------------------------------------------------------------------------
-- Display Package Body
-- ASCII art display implementation
-------------------------------------------------------------------------------

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

package body Display is

   -------------------------
   -- Clear_Screen
   -------------------------
   procedure Clear_Screen is
   begin
      -- ANSI escape sequence works on Linux and modern Windows terminals
      Put (ASCII.ESC & "[2J" & ASCII.ESC & "[H");
   end Clear_Screen;

   -------------------------
   -- Move_To
   -------------------------
   procedure Move_To (Row, Col : Natural) is
      Row_Str : constant String := Natural'Image (Row + 1);
      Col_Str : constant String := Natural'Image (Col + 1);
   begin
      -- ANSI escape sequence for cursor positioning
      Put (ASCII.ESC & "[" &
           Row_Str (Row_Str'First + 1 .. Row_Str'Last) & ";" &
           Col_Str (Col_Str'First + 1 .. Col_Str'Last) & "H");
   end Move_To;

   -------------------------
   -- Print
   -------------------------
   procedure Print (S : String) is
   begin
      Put (S);
   end Print;

   -------------------------
   -- Print_Line
   -------------------------
   procedure Print_Line (S : String) is
   begin
      Put_Line (S);
   end Print_Line;

   -------------------------
   -- New_Line
   -------------------------
   procedure New_Line is
   begin
      Ada.Text_IO.New_Line;
   end New_Line;

   -------------------------
   -- Print_Separator
   -------------------------
   procedure Print_Separator (Width : Positive) is
   begin
      for I in 1 .. Width loop
         Put ('-');
      end loop;
      New_Line;
   end Print_Separator;

   -------------------------
   -- Wait_For_Enter
   -------------------------
   procedure Wait_For_Enter is
      Dummy : String (1 .. 80);
      Last  : Natural;
   begin
      Put ("Press Enter to continue...");
      Get_Line (Dummy, Last);
   end Wait_For_Enter;

   -------------------------
   -- Get_Suit_Char
   -------------------------
   function Get_Suit_Char (S : Suit_Type) return Character is
   begin
      case S is
         when Hearts   => return 'H';  -- Could use Unicode heart
         when Diamonds => return 'D';  -- Could use Unicode diamond
         when Clubs    => return 'C';  -- Could use Unicode club
         when Spades   => return 'S';  -- Could use Unicode spade
      end case;
   end Get_Suit_Char;

   -------------------------
   -- Get_Rank_Str
   -------------------------
   function Get_Rank_Str (R : Rank_Type) return String is
   begin
      case R is
         when Two   => return "2 ";
         when Three => return "3 ";
         when Four  => return "4 ";
         when Five  => return "5 ";
         when Six   => return "6 ";
         when Seven => return "7 ";
         when Eight => return "8 ";
         when Nine  => return "9 ";
         when Ten   => return "10";
         when Jack  => return "J ";
         when Queen => return "Q ";
         when King  => return "K ";
         when Ace   => return "A ";
      end case;
   end Get_Rank_Str;

   -------------------------
   -- Display_Card
   -------------------------
   procedure Display_Card (C : Card_Type; Row_Offset, Col_Offset : Natural) is
      Suit_Ch  : constant Character := Get_Suit_Char (C.Suit);
      Rank_Str : constant String := Get_Rank_Str (C.Rank);
   begin
      -- Card ASCII art:
      -- +-----+
      -- |A    |
      -- |  S  |
      -- |    A|
      -- +-----+

      Move_To (Row_Offset, Col_Offset);
      Put ("+-----+");

      Move_To (Row_Offset + 1, Col_Offset);
      Put ("|" & Rank_Str & "   |");

      Move_To (Row_Offset + 2, Col_Offset);
      Put ("|  " & Suit_Ch & "  |");

      Move_To (Row_Offset + 3, Col_Offset);
      Put ("|   " & Rank_Str & "|");

      Move_To (Row_Offset + 4, Col_Offset);
      Put ("+-----+");
   end Display_Card;

   -------------------------
   -- Display_Empty_Slot
   -------------------------
   procedure Display_Empty_Slot (Row_Offset, Col_Offset : Natural) is
   begin
      Move_To (Row_Offset, Col_Offset);
      Put ("+-----+");

      Move_To (Row_Offset + 1, Col_Offset);
      Put ("|     |");

      Move_To (Row_Offset + 2, Col_Offset);
      Put ("|     |");

      Move_To (Row_Offset + 3, Col_Offset);
      Put ("|     |");

      Move_To (Row_Offset + 4, Col_Offset);
      Put ("+-----+");
   end Display_Empty_Slot;

   -------------------------
   -- Display_Board
   -------------------------
   procedure Display_Board (State : Game_State) is
      Row_Start   : Natural;
      Col_Start   : Natural;
      Card_Spacing : constant := 8;  -- Width of card + 1
      Row_Spacing  : constant := 6;  -- Height of card + 1

      Row_Hands   : constant Hand_Results := Evaluate_Rows (State);
      Col_Hands   : constant Hand_Results := Evaluate_Columns (State);
      Row_Scores  : constant Score_Results := Calculate_Row_Scores (State);
      Col_Scores  : constant Score_Results := Calculate_Column_Scores (State);
   begin
      Clear_Screen;

      -- Title
      Move_To (0, 15);
      Put ("=== POKER SOLITAIRE ===");

      -- Column headers (1-5)
      Move_To (2, 5);
      Put ("    1       2       3       4       5");

      -- Draw the 5x5 grid
      for Row in Board_Index loop
         Row_Start := 3 + (Natural (Row) - 1) * Row_Spacing;

         -- Row number on the left
         Move_To (Row_Start + 2, 0);
         Put (Board_Index'Image (Row));

         for Col in Board_Index loop
            Col_Start := 4 + (Natural (Col) - 1) * Card_Spacing;

            if State.Board (Row, Col).State = Filled then
               Display_Card (State.Board (Row, Col).Card, Row_Start, Col_Start);
            else
               Display_Empty_Slot (Row_Start, Col_Start);
            end if;
         end loop;

         -- Row hand and score on the right
         Move_To (Row_Start + 2, 46);
         if Is_Complete (Get_Row (State, Row)) then
            Put ("| " & Hand_Name (Row_Hands (Row)));
            Move_To (Row_Start + 3, 46);
            Put ("| Score:" & Natural'Image (Row_Scores (Row)));
         else
            Put ("|");
         end if;
      end loop;

      -- Column scores at bottom
      Move_To (34, 4);
      Put ("Score:");
      for Col in Board_Index loop
         Col_Start := 4 + (Natural (Col) - 1) * Card_Spacing;
         Move_To (34, Col_Start);
         if Is_Complete (Get_Column (State, Col)) then
            Put (Natural'Image (Col_Scores (Col)));
         else
            Put ("  -");
         end if;
      end loop;

      -- Column hands at bottom
      Move_To (35, 4);
      Put ("Hands:");
      for Col in Board_Index loop
         Col_Start := 4 + (Natural (Col) - 1) * Card_Spacing;
         Move_To (36, Col_Start - 1);
         if Is_Complete (Get_Column (State, Col)) then
            -- Abbreviated hand name
            case Col_Hands (Col) is
               when No_Hand         => Put ("  --  ");
               when One_Pair        => Put (" Pair ");
               when Two_Pair        => Put ("2Pair ");
               when Three_Of_A_Kind => Put (" 3oK  ");
               when Straight        => Put ("Strt  ");
               when Flush           => Put ("Flush ");
               when Full_House      => Put (" FH   ");
               when Four_Of_A_Kind  => Put (" 4oK  ");
               when Straight_Flush  => Put (" SF   ");
               when Royal_Flush     => Put (" RF   ");
            end case;
         else
            Put ("      ");
         end if;
      end loop;

      -- Total score and cards remaining
      Move_To (38, 0);
      Put ("Cards placed: " & Natural'Image (State.Cards_Placed) & " / 25");
      Move_To (39, 0);
      if State.Game_Over then
         Put ("FINAL SCORE: " & Natural'Image (Calculate_Total_Score (State)));
      else
         Put ("Current Score: " & Natural'Image (Calculate_Total_Score (State)));
      end if;

   end Display_Board;

   -------------------------
   -- Display_Current_Card
   -------------------------
   procedure Display_Current_Card (C : Card_Type) is
   begin
      Move_To (41, 0);
      Put ("Current card to place:");
      Display_Card (C, 42, 0);
      Move_To (48, 0);
      Put ("Enter position (row col), or 'q' to quit: ");
   end Display_Current_Card;

   -------------------------
   -- Display_Scores
   -------------------------
   procedure Display_Scores (State : Game_State) is
      Row_Hands   : constant Hand_Results := Evaluate_Rows (State);
      Col_Hands   : constant Hand_Results := Evaluate_Columns (State);
      Row_Scores  : constant Score_Results := Calculate_Row_Scores (State);
      Col_Scores  : constant Score_Results := Calculate_Column_Scores (State);
      Total       : Natural := 0;
   begin
      Print_Line ("=== SCORE BREAKDOWN ===");
      New_Line;

      Print_Line ("ROWS:");
      for Row in Board_Index loop
         Put ("  Row " & Board_Index'Image (Row) & ": ");
         Put (Hand_Name (Row_Hands (Row)));
         Put (" = ");
         Put (Natural'Image (Row_Scores (Row)));
         New_Line;
         Total := Total + Row_Scores (Row);
      end loop;

      New_Line;
      Print_Line ("COLUMNS:");
      for Col in Board_Index loop
         Put ("  Col " & Board_Index'Image (Col) & ": ");
         Put (Hand_Name (Col_Hands (Col)));
         Put (" = ");
         Put (Natural'Image (Col_Scores (Col)));
         New_Line;
         Total := Total + Col_Scores (Col);
      end loop;

      New_Line;
      Print_Separator (40);
      Put ("TOTAL SCORE: ");
      Put (Total, Width => 0);
      New_Line;
   end Display_Scores;

   -------------------------
   -- Display_Game_Over
   -------------------------
   procedure Display_Game_Over (State : Game_State) is
   begin
      Move_To (50, 0);
      Print_Line ("========================================");
      Print_Line ("            GAME OVER!");
      Print_Line ("========================================");
      New_Line;
      Display_Scores (State);
   end Display_Game_Over;

   -------------------------
   -- Display_Title
   -------------------------
   procedure Display_Title is
   begin
      Clear_Screen;
      Print_Line ("========================================");
      Print_Line ("                                        ");
      Print_Line ("         POKER SOLITAIRE               ");
      Print_Line ("                                        ");
      Print_Line ("           Written in Ada               ");
      Print_Line ("                                        ");
      Print_Line ("========================================");
      New_Line;
      Print_Line ("Place 25 cards in a 5x5 grid to create");
      Print_Line ("the best poker hands in rows & columns!");
      New_Line;
      Print_Line ("SCORING (American System):");
      Print_Line ("  Royal Flush     = 100 points");
      Print_Line ("  Straight Flush  =  75 points");
      Print_Line ("  Four of a Kind  =  50 points");
      Print_Line ("  Full House      =  25 points");
      Print_Line ("  Flush           =  20 points");
      Print_Line ("  Straight        =  15 points");
      Print_Line ("  Three of a Kind =  10 points");
      Print_Line ("  Two Pair        =   5 points");
      Print_Line ("  One Pair        =   2 points");
      Print_Line ("  No Hand         =   0 points");
      New_Line;
      Print_Line ("Maximum possible score: 200 points");
      Print_Line ("(10 Royal Flushes - theoretically impossible)");
      New_Line;
   end Display_Title;

   -------------------------
   -- Display_Help
   -------------------------
   procedure Display_Help is
   begin
      Print_Line ("=== HOW TO PLAY ===");
      New_Line;
      Print_Line ("1. Cards are dealt one at a time from a shuffled deck.");
      Print_Line ("2. For each card, enter a position (row column) to place it.");
      Print_Line ("3. Positions are numbered 1-5 for both rows and columns.");
      Print_Line ("4. Example: '2 3' places the card in row 2, column 3.");
      Print_Line ("5. Once placed, cards cannot be moved.");
      Print_Line ("6. After all 25 cards are placed, hands are scored.");
      Print_Line ("7. Each row and column is evaluated as a poker hand.");
      Print_Line ("8. Try to maximize your total score!");
      New_Line;
      Print_Line ("Commands during game:");
      Print_Line ("  row col  - Place card at position (e.g., '2 3')");
      Print_Line ("  q        - Quit the game");
      Print_Line ("  h        - Show this help");
      New_Line;
   end Display_Help;

   -------------------------
   -- Display_High_Scores
   -------------------------
   procedure Display_High_Scores is
   begin
      Print_Line ("=== HIGH SCORES ===");
      Print_Line ("(See high_scores.txt for saved scores)");
      New_Line;
   end Display_High_Scores;

end Display;
