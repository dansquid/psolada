-------------------------------------------------------------------------------
-- Display Package Body
-- Graphical display implementation using AdaGraph
-------------------------------------------------------------------------------

with AdaGraph;  use AdaGraph;

package body Display is

   -- Color constants (AdaGraph uses integer color codes)
   -- Standard colors: 0=Black, 1=Blue, 2=Green, 3=Cyan, 4=Red,
   --                  5=Magenta, 6=Brown, 7=Light_Gray, 8=Dark_Gray,
   --                  9=Light_Blue, 10=Light_Green, 11=Light_Cyan,
   --                  12=Light_Red, 13=Light_Magenta, 14=Yellow, 15=White

   Color_Background  : constant Integer := 2;   -- Green (card table)
   Color_Card_White  : constant Integer := 15;  -- White
   Color_Card_Border : constant Integer := 0;   -- Black
   Color_Red_Suit    : constant Integer := 4;   -- Red (hearts, diamonds)
   Color_Black_Suit  : constant Integer := 0;   -- Black (clubs, spades)
   Color_Text        : constant Integer := 15;  -- White
   Color_Title       : constant Integer := 14;  -- Yellow
   Color_Empty_Slot  : constant Integer := 8;   -- Dark gray
   Color_Highlight   : constant Integer := 11;  -- Light cyan

   -- Track if graphics initialized
   Graphics_Initialized : Boolean := False;

   -------------------------
   -- Initialize_Graphics
   -------------------------
   procedure Initialize_Graphics is
   begin
      if not Graphics_Initialized then
         Create_Graph (Window_Width, Window_Height, 0, 0);
         Graphics_Initialized := True;
         Clear_Window;
      end if;
   end Initialize_Graphics;

   -------------------------
   -- Close_Graphics
   -------------------------
   procedure Close_Graphics is
   begin
      if Graphics_Initialized then
         Destroy_Graph;
         Graphics_Initialized := False;
      end if;
   end Close_Graphics;

   -------------------------
   -- Clear_Window
   -------------------------
   procedure Clear_Window is
   begin
      Set_Color (Color_Background);
      Fill_Box (0, 0, Window_Width, Window_Height);
   end Clear_Window;

   -------------------------
   -- Get_Suit_Symbol
   -------------------------
   function Get_Suit_Symbol (S : Suit_Type) return String is
   begin
      case S is
         when Hearts   => return "H";   -- Heart symbol
         when Diamonds => return "D";   -- Diamond symbol
         when Clubs    => return "C";   -- Club symbol
         when Spades   => return "S";   -- Spade symbol
      end case;
   end Get_Suit_Symbol;

   -------------------------
   -- Get_Rank_String
   -------------------------
   function Get_Rank_String (R : Rank_Type) return String is
   begin
      case R is
         when Two   => return "2";
         when Three => return "3";
         when Four  => return "4";
         when Five  => return "5";
         when Six   => return "6";
         when Seven => return "7";
         when Eight => return "8";
         when Nine  => return "9";
         when Ten   => return "10";
         when Jack  => return "J";
         when Queen => return "Q";
         when King  => return "K";
         when Ace   => return "A";
      end case;
   end Get_Rank_String;

   -------------------------
   -- Get_Suit_Color
   -------------------------
   function Get_Suit_Color (S : Suit_Type) return Integer is
   begin
      case S is
         when Hearts | Diamonds => return Color_Red_Suit;
         when Clubs | Spades    => return Color_Black_Suit;
      end case;
   end Get_Suit_Color;

   -------------------------
   -- Draw_Suit_Symbol
   -------------------------
   procedure Draw_Suit_Symbol (S : Suit_Type; X, Y : Integer; Size : Integer) is
      Color : constant Integer := Get_Suit_Color (S);
      Half  : constant Integer := Size / 2;
   begin
      Set_Color (Color);

      case S is
         when Hearts =>
            -- Draw heart shape using circles and triangle
            Fill_Circle (X - Half / 2, Y - Half / 3, Half / 2);
            Fill_Circle (X + Half / 2, Y - Half / 3, Half / 2);
            -- Triangle bottom (approximated with filled box)
            for I in 0 .. Half loop
               Draw_Line (X - Half + I / 2, Y - Half / 3 + I,
                          X + Half - I / 2, Y - Half / 3 + I);
            end loop;

         when Diamonds =>
            -- Draw diamond shape
            for I in 0 .. Half loop
               Draw_Line (X - I, Y - Half + I, X + I, Y - Half + I);
            end loop;
            for I in 0 .. Half loop
               Draw_Line (X - Half + I, Y + I, X + Half - I, Y + I);
            end loop;

         when Clubs =>
            -- Draw club shape using three circles
            Fill_Circle (X, Y - Half / 2, Half / 2);
            Fill_Circle (X - Half / 2, Y + Half / 4, Half / 2);
            Fill_Circle (X + Half / 2, Y + Half / 4, Half / 2);
            -- Stem
            Fill_Box (X - 2, Y + Half / 4, X + 2, Y + Half);

         when Spades =>
            -- Draw spade shape (inverted heart with stem)
            for I in 0 .. Half loop
               Draw_Line (X - I / 2, Y - Half + I, X + I / 2, Y - Half + I);
            end loop;
            Fill_Circle (X - Half / 3, Y, Half / 3);
            Fill_Circle (X + Half / 3, Y, Half / 3);
            -- Stem
            Fill_Box (X - 2, Y, X + 2, Y + Half);
      end case;
   end Draw_Suit_Symbol;

   -------------------------
   -- Draw_Card
   -------------------------
   procedure Draw_Card (C : Card_Type; X, Y : Integer) is
      Suit_Color : constant Integer := Get_Suit_Color (C.Suit);
      Rank_Str   : constant String := Get_Rank_String (C.Rank);
      Suit_Str   : constant String := Get_Suit_Symbol (C.Suit);
      Corner_Offset : constant Integer := 8;
   begin
      -- Draw card background (white with black border)
      Set_Color (Color_Card_White);
      Fill_Box (X, Y, X + Card_Width, Y + Card_Height);

      Set_Color (Color_Card_Border);
      Draw_Box (X, Y, X + Card_Width, Y + Card_Height);
      Draw_Box (X + 1, Y + 1, X + Card_Width - 1, Y + Card_Height - 1);

      -- Draw rank in top-left corner
      Set_Color (Suit_Color);
      Goto_XY (X + Corner_Offset, Y + Corner_Offset);
      Put (Rank_Str);

      -- Draw suit symbol below rank in corner
      Goto_XY (X + Corner_Offset, Y + Corner_Offset + 15);
      Put (Suit_Str);

      -- Draw large suit symbol in center
      Draw_Suit_Symbol (C.Suit, X + Card_Width / 2, Y + Card_Height / 2, 20);

      -- Draw rank in bottom-right corner (upside down effect - just text)
      Goto_XY (X + Card_Width - Corner_Offset - 10, Y + Card_Height - Corner_Offset - 20);
      Put (Rank_Str);

      Goto_XY (X + Card_Width - Corner_Offset - 10, Y + Card_Height - Corner_Offset - 5);
      Put (Suit_Str);
   end Draw_Card;

   -------------------------
   -- Draw_Empty_Slot
   -------------------------
   procedure Draw_Empty_Slot (X, Y : Integer; Row, Col : Board_Index) is
      Label : constant String := Board_Index'Image (Row) & "," &
                                 Board_Index'Image (Col);
   begin
      -- Draw empty slot outline
      Set_Color (Color_Empty_Slot);
      Draw_Box (X, Y, X + Card_Width, Y + Card_Height);
      Draw_Box (X + 2, Y + 2, X + Card_Width - 2, Y + Card_Height - 2);

      -- Draw position label in center
      Set_Color (Color_Text);
      Goto_XY (X + Card_Width / 2 - 15, Y + Card_Height / 2 - 5);
      Put (Label);
   end Draw_Empty_Slot;

   -------------------------
   -- Display_Board
   -------------------------
   procedure Display_Board (State : Game_State) is
      X, Y      : Integer;
      Card_Step : constant Integer := Card_Width + Card_Margin;
   begin
      -- Draw title
      Set_Color (Color_Title);
      Goto_XY (Window_Width / 2 - 80, 20);
      Put ("POKER SOLITAIRE");

      -- Draw column headers
      Set_Color (Color_Text);
      for Col in Board_Index loop
         X := Board_X + (Integer (Col) - 1) * Card_Step + Card_Width / 2 - 5;
         Goto_XY (X, Board_Y - 20);
         Put (Board_Index'Image (Col));
      end loop;

      -- Draw the 5x5 grid
      for Row in Board_Index loop
         Y := Board_Y + (Integer (Row) - 1) * (Card_Height + Card_Margin);

         -- Draw row label
         Goto_XY (Board_X - 30, Y + Card_Height / 2 - 5);
         Put (Board_Index'Image (Row));

         for Col in Board_Index loop
            X := Board_X + (Integer (Col) - 1) * Card_Step;

            if State.Board (Row, Col).State = Filled then
               Draw_Card (State.Board (Row, Col).Card, X, Y);
            else
               Draw_Empty_Slot (X, Y, Row, Col);
            end if;
         end loop;
      end loop;

      -- Display scores on the right side
      Display_Scores (State);
   end Display_Board;

   -------------------------
   -- Display_Current_Card
   -------------------------
   procedure Display_Current_Card (C : Card_Type; Cards_Left : Natural) is
      X : constant Integer := Window_Width - 150;
      Y : constant Integer := 450;
   begin
      Set_Color (Color_Text);
      Goto_XY (X, Y - 30);
      Put ("Current Card:");

      Draw_Card (C, X, Y);

      Goto_XY (X, Y + Card_Height + 15);
      Put ("Cards left:" & Natural'Image (Cards_Left));
   end Display_Current_Card;

   -------------------------
   -- Display_Scores
   -------------------------
   procedure Display_Scores (State : Game_State) is
      Row_Hands   : constant Hand_Results := Evaluate_Rows (State);
      Col_Hands   : constant Hand_Results := Evaluate_Columns (State);
      Row_Scores  : constant Score_Results := Calculate_Row_Scores (State);
      Col_Scores  : constant Score_Results := Calculate_Column_Scores (State);
      X           : constant Integer := 480;
      Y           : Integer := Board_Y;
      Total       : Natural := 0;
   begin
      Set_Color (Color_Title);
      Goto_XY (X + 50, Y - 20);
      Put ("SCORES");

      Set_Color (Color_Text);

      -- Row scores
      Goto_XY (X, Y);
      Put ("Rows:");
      Y := Y + 20;

      for Row in Board_Index loop
         Goto_XY (X, Y);
         if Is_Complete (Get_Row (State, Row)) then
            Put ("R" & Board_Index'Image (Row) & ":" &
                 Natural'Image (Row_Scores (Row)) & " - " &
                 Hand_Name (Row_Hands (Row)));
            Total := Total + Row_Scores (Row);
         else
            Put ("R" & Board_Index'Image (Row) & ": ---");
         end if;
         Y := Y + 18;
      end loop;

      Y := Y + 10;
      Goto_XY (X, Y);
      Put ("Columns:");
      Y := Y + 20;

      -- Column scores
      for Col in Board_Index loop
         Goto_XY (X, Y);
         if Is_Complete (Get_Column (State, Col)) then
            Put ("C" & Board_Index'Image (Col) & ":" &
                 Natural'Image (Col_Scores (Col)) & " - " &
                 Hand_Name (Col_Hands (Col)));
            Total := Total + Col_Scores (Col);
         else
            Put ("C" & Board_Index'Image (Col) & ": ---");
         end if;
         Y := Y + 18;
      end loop;

      -- Total
      Y := Y + 20;
      Set_Color (Color_Title);
      Goto_XY (X, Y);
      if State.Game_Over then
         Put ("FINAL SCORE:" & Natural'Image (Total));
      else
         Put ("Current:" & Natural'Image (Total));
      end if;

      -- Cards placed
      Set_Color (Color_Text);
      Goto_XY (X, Y + 25);
      Put ("Cards:" & Natural'Image (State.Cards_Placed) & " / 25");
   end Display_Scores;

   -------------------------
   -- Display_Game_Over
   -------------------------
   procedure Display_Game_Over (State : Game_State) is
      Total : constant Natural := Calculate_Total_Score (State);
   begin
      -- Draw overlay box
      Set_Color (Color_Card_Border);
      Fill_Box (200, 250, 700, 450);
      Set_Color (Color_Card_White);
      Fill_Box (205, 255, 695, 445);

      Set_Color (Color_Card_Border);
      Goto_XY (380, 280);
      Put ("GAME OVER!");

      Goto_XY (350, 320);
      Put ("Final Score:" & Natural'Image (Total));

      Goto_XY (320, 370);
      Put ("Press any key to continue...");
   end Display_Game_Over;

   -------------------------
   -- Display_Title
   -------------------------
   procedure Display_Title is
   begin
      Clear_Window;

      -- Title
      Set_Color (Color_Title);
      Goto_XY (300, 80);
      Put ("POKER SOLITAIRE");

      Set_Color (Color_Text);
      Goto_XY (320, 120);
      Put ("Written in Ada");

      -- Instructions
      Goto_XY (250, 180);
      Put ("Place 25 cards in a 5x5 grid");
      Goto_XY (220, 200);
      Put ("to make poker hands in rows & columns!");

      -- Scoring table
      Set_Color (Color_Title);
      Goto_XY (350, 250);
      Put ("SCORING");

      Set_Color (Color_Text);
      Goto_XY (280, 280);  Put ("Royal Flush     = 100");
      Goto_XY (280, 300);  Put ("Straight Flush  =  75");
      Goto_XY (280, 320);  Put ("Four of a Kind  =  50");
      Goto_XY (280, 340);  Put ("Full House      =  25");
      Goto_XY (280, 360);  Put ("Flush           =  20");
      Goto_XY (280, 380);  Put ("Straight        =  15");
      Goto_XY (280, 400);  Put ("Three of a Kind =  10");
      Goto_XY (280, 420);  Put ("Two Pair        =   5");
      Goto_XY (280, 440);  Put ("One Pair        =   2");
      Goto_XY (280, 460);  Put ("No Hand         =   0");

      -- Menu
      Set_Color (Color_Title);
      Goto_XY (380, 520);
      Put ("MENU");

      Set_Color (Color_Text);
      Goto_XY (340, 550);  Put ("1 - New Game");
      Goto_XY (340, 570);  Put ("2 - High Scores");
      Goto_XY (340, 590);  Put ("3 - How to Play");
      Goto_XY (340, 610);  Put ("4 - Quit");

      Goto_XY (300, 650);
      Put ("Press 1, 2, 3, or 4...");
   end Display_Title;

   -------------------------
   -- Display_Help
   -------------------------
   procedure Display_Help is
   begin
      Clear_Window;

      Set_Color (Color_Title);
      Goto_XY (350, 50);
      Put ("HOW TO PLAY");

      Set_Color (Color_Text);
      Goto_XY (100, 100);
      Put ("1. Cards are dealt one at a time from a shuffled deck.");

      Goto_XY (100, 130);
      Put ("2. Click on an empty slot to place the current card.");

      Goto_XY (100, 160);
      Put ("3. Or type row and column numbers (1-5).");

      Goto_XY (100, 190);
      Put ("4. Once placed, cards cannot be moved.");

      Goto_XY (100, 220);
      Put ("5. After 25 cards are placed, your hands are scored.");

      Goto_XY (100, 250);
      Put ("6. Each row and column is evaluated as a poker hand.");

      Goto_XY (100, 280);
      Put ("7. Try to maximize your total score!");

      Set_Color (Color_Title);
      Goto_XY (350, 350);
      Put ("CONTROLS");

      Set_Color (Color_Text);
      Goto_XY (200, 390);
      Put ("Mouse Click - Place card in clicked slot");

      Goto_XY (200, 420);
      Put ("1-5, 1-5    - Type row then column number");

      Goto_XY (200, 450);
      Put ("H           - Show this help");

      Goto_XY (200, 480);
      Put ("Q           - Quit game");

      Set_Color (Color_Highlight);
      Goto_XY (280, 550);
      Put ("Press any key to return...");
   end Display_Help;

   -------------------------
   -- Display_Message
   -------------------------
   procedure Display_Message (Msg : String) is
   begin
      -- Clear message area
      Set_Color (Color_Background);
      Fill_Box (0, Window_Height - 40, Window_Width, Window_Height);

      -- Draw message
      Set_Color (Color_Text);
      Goto_XY (50, Window_Height - 30);
      Put (Msg);
   end Display_Message;

   -------------------------
   -- Display_High_Scores_Screen
   -------------------------
   procedure Display_High_Scores_Screen is
   begin
      Clear_Window;

      Set_Color (Color_Title);
      Goto_XY (350, 100);
      Put ("HIGH SCORES");

      Set_Color (Color_Text);
      Goto_XY (250, 180);
      Put ("(Scores saved in poker_solitaire_scores.dat)");

      Goto_XY (280, 550);
      Put ("Press any key to return...");
   end Display_High_Scores_Screen;

   -------------------------
   -- Get_Position_Input
   -------------------------
   function Get_Position_Input (Row : out Board_Index;
                                Col : out Board_Index) return Boolean is
      X, Y      : Integer;
      Btn       : Integer;
      Key       : Character;
      Card_Step : constant Integer := Card_Width + Card_Margin;
      Input_Row : Integer;
      Input_Col : Integer;
      Got_Row   : Boolean := False;
   begin
      Row := 1;
      Col := 1;

      loop
         -- Check for keyboard input first
         if Key_Hit then
            Key := Get_Key;

            case Key is
               when 'q' | 'Q' =>
                  return False;  -- Quit

               when 'h' | 'H' =>
                  Display_Help;
                  Wait_For_Input;
                  return False;  -- Signal to redraw

               when '1' .. '5' =>
                  if not Got_Row then
                     Input_Row := Character'Pos (Key) - Character'Pos ('0');
                     Got_Row := True;
                     Display_Message ("Row " & Key & " selected. Enter column (1-5)...");
                  else
                     Input_Col := Character'Pos (Key) - Character'Pos ('0');
                     Row := Board_Index (Input_Row);
                     Col := Board_Index (Input_Col);
                     return True;
                  end if;

               when others =>
                  null;
            end case;
         end if;

         -- Check for mouse input
         Get_Mouse (X, Y, Btn);

         if Btn > 0 then
            -- Check if click is within the board area
            Input_Col := (X - Board_X) / Card_Step + 1;
            Input_Row := (Y - Board_Y) / (Card_Height + Card_Margin) + 1;

            if Input_Row in 1 .. 5 and Input_Col in 1 .. 5 then
               Row := Board_Index (Input_Row);
               Col := Board_Index (Input_Col);
               return True;
            end if;

            -- Wait for button release
            loop
               Get_Mouse (X, Y, Btn);
               exit when Btn = 0;
            end loop;
         end if;

         delay 0.01;  -- Small delay to prevent busy-waiting
      end loop;
   end Get_Position_Input;

   -------------------------
   -- Get_Key_Press
   -------------------------
   function Get_Key_Press return Character is
   begin
      loop
         if Key_Hit then
            return Get_Key;
         end if;
         delay 0.01;
      end loop;
   end Get_Key_Press;

   -------------------------
   -- Wait_For_Input
   -------------------------
   procedure Wait_For_Input is
      X, Y, Btn : Integer;
   begin
      loop
         if Key_Hit then
            declare
               Dummy : Character;
            begin
               Dummy := Get_Key;
            end;
            exit;
         end if;

         Get_Mouse (X, Y, Btn);
         if Btn > 0 then
            -- Wait for release
            loop
               Get_Mouse (X, Y, Btn);
               exit when Btn = 0;
            end loop;
            exit;
         end if;

         delay 0.01;
      end loop;
   end Wait_For_Input;

   -------------------------
   -- Key_Available
   -------------------------
   function Key_Available return Boolean is
   begin
      return Key_Hit;
   end Key_Available;

   -------------------------
   -- Display_Input_Prompt
   -------------------------
   procedure Display_Input_Prompt is
   begin
      Display_Message ("Click a slot or type position (row col). Q=Quit, H=Help");
   end Display_Input_Prompt;

   -------------------------
   -- Refresh_Display
   -------------------------
   procedure Refresh_Display is
   begin
      -- AdaGraph typically auto-refreshes, but we can force it
      null;
   end Refresh_Display;

end Display;
