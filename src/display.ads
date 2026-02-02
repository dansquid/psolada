-------------------------------------------------------------------------------
-- Display Package Specification
-- ASCII art display for cards and game board
-------------------------------------------------------------------------------

with Cards;       use Cards;
with Game_Board;  use Game_Board;
with Poker_Hands; use Poker_Hands;

package Display is

   -- Card display dimensions (ASCII art)
   Card_Width  : constant := 7;
   Card_Height : constant := 5;

   -- Clear the screen (works on both Windows and Linux)
   procedure Clear_Screen;

   -- Display a single card as ASCII art
   procedure Display_Card (C : Card_Type; Row_Offset, Col_Offset : Natural);

   -- Display an empty card slot
   procedure Display_Empty_Slot (Row_Offset, Col_Offset : Natural);

   -- Display the entire game board with scores
   procedure Display_Board (State : Game_State);

   -- Display the current card to place
   procedure Display_Current_Card (C : Card_Type);

   -- Display score summary
   procedure Display_Scores (State : Game_State);

   -- Display game over screen
   procedure Display_Game_Over (State : Game_State);

   -- Display welcome/title screen
   procedure Display_Title;

   -- Display help/instructions
   procedure Display_Help;

   -- Display high scores
   procedure Display_High_Scores;

   -- Set cursor position (approximate for terminal)
   procedure Move_To (Row, Col : Natural);

   -- Print a string at current position
   procedure Print (S : String);

   -- Print a line with newline
   procedure Print_Line (S : String);

   -- Print an empty line
   procedure New_Line;

   -- Print a horizontal separator line
   procedure Print_Separator (Width : Positive);

   -- Wait for user to press Enter
   procedure Wait_For_Enter;

end Display;
