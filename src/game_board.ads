-------------------------------------------------------------------------------
-- Game_Board Package Specification
-- Manages the 5x5 poker solitaire grid
-------------------------------------------------------------------------------

with Cards;       use Cards;
with Poker_Hands; use Poker_Hands;

package Game_Board is

   -- Board dimensions
   Board_Size : constant := 5;

   -- Board index types
   subtype Board_Index is Positive range 1 .. Board_Size;

   -- The 5x5 game board
   type Board_Type is array (Board_Index, Board_Index) of Card_Slot;

   -- Game state record
   type Game_State is record
      Board        : Board_Type;
      Cards_Placed : Natural;
      Total_Score  : Natural;
      Game_Over    : Boolean;
   end record;

   -- Row/Column hand results
   type Hand_Results is array (Board_Index) of Hand_Rank;
   type Score_Results is array (Board_Index) of Natural;

   -- Initialize a new game
   procedure Initialize_Game (State : out Game_State);

   -- Place a card at the specified position
   -- Returns True if successful, False if position is occupied
   function Place_Card (State : in out Game_State;
                        Row   : Board_Index;
                        Col   : Board_Index;
                        Card  : Card_Type) return Boolean;

   -- Check if a position is empty
   function Is_Position_Empty (State : Game_State;
                               Row   : Board_Index;
                               Col   : Board_Index) return Boolean;

   -- Check if game is complete (25 cards placed)
   function Is_Game_Complete (State : Game_State) return Boolean;

   -- Get a row as a hand array
   function Get_Row (State : Game_State; Row : Board_Index) return Hand_Array;

   -- Get a column as a hand array
   function Get_Column (State : Game_State; Col : Board_Index) return Hand_Array;

   -- Evaluate all rows and return results
   function Evaluate_Rows (State : Game_State) return Hand_Results;

   -- Evaluate all columns and return results
   function Evaluate_Columns (State : Game_State) return Hand_Results;

   -- Calculate row scores
   function Calculate_Row_Scores (State : Game_State) return Score_Results;

   -- Calculate column scores
   function Calculate_Column_Scores (State : Game_State) return Score_Results;

   -- Calculate total score (all rows + all columns)
   function Calculate_Total_Score (State : Game_State) return Natural;

   -- Get number of cards placed
   function Get_Cards_Placed (State : Game_State) return Natural;

end Game_Board;
