-------------------------------------------------------------------------------
-- Display Package Specification
-- Graphical display for cards and game board using AdaGraph
-------------------------------------------------------------------------------

with Cards;       use Cards;
with Game_Board;  use Game_Board;
with Poker_Hands; use Poker_Hands;

package Display is

   -- Window dimensions
   Window_Width  : constant := 900;
   Window_Height : constant := 700;

   -- Card display dimensions
   Card_Width  : constant := 70;
   Card_Height : constant := 100;
   Card_Margin : constant := 10;

   -- Board position
   Board_X : constant := 50;
   Board_Y : constant := 80;

   -- Initialize the graphics window
   procedure Initialize_Graphics;

   -- Close the graphics window
   procedure Close_Graphics;

   -- Clear the window
   procedure Clear_Window;

   -- Display a single card graphically
   procedure Draw_Card (C : Card_Type; X, Y : Integer);

   -- Display an empty card slot
   procedure Draw_Empty_Slot (X, Y : Integer; Row, Col : Board_Index);

   -- Display the entire game board
   procedure Display_Board (State : Game_State);

   -- Display the current card to place
   procedure Display_Current_Card (C : Card_Type; Cards_Left : Natural);

   -- Display score summary on the side
   procedure Display_Scores (State : Game_State);

   -- Display game over screen
   procedure Display_Game_Over (State : Game_State);

   -- Display welcome/title screen
   procedure Display_Title;

   -- Display help/instructions
   procedure Display_Help;

   -- Display a message at the bottom
   procedure Display_Message (Msg : String);

   -- Display high scores
   procedure Display_High_Scores_Screen;

   -- Get user input for position (returns row, col via mouse click)
   -- Returns False if user wants to quit
   function Get_Position_Input (Row : out Board_Index;
                                Col : out Board_Index) return Boolean;

   -- Get a single key press
   function Get_Key_Press return Character;

   -- Wait for user to click or press a key
   procedure Wait_For_Input;

   -- Check if a key was pressed
   function Key_Available return Boolean;

   -- Display input prompt
   procedure Display_Input_Prompt;

   -- Refresh/update the display
   procedure Refresh_Display;

end Display;
