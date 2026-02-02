-------------------------------------------------------------------------------
-- Game_Board Package Body
-- Implementation of the 5x5 game board
-------------------------------------------------------------------------------

package body Game_Board is

   -------------------------
   -- Initialize_Game
   -------------------------
   procedure Initialize_Game (State : out Game_State) is
   begin
      -- Initialize all positions as empty
      for Row in Board_Index loop
         for Col in Board_Index loop
            State.Board (Row, Col) := Empty_Slot;
         end loop;
      end loop;

      State.Cards_Placed := 0;
      State.Total_Score := 0;
      State.Game_Over := False;
   end Initialize_Game;

   -------------------------
   -- Is_Position_Empty
   -------------------------
   function Is_Position_Empty (State : Game_State;
                               Row   : Board_Index;
                               Col   : Board_Index) return Boolean is
   begin
      return State.Board (Row, Col).State = Empty;
   end Is_Position_Empty;

   -------------------------
   -- Place_Card
   -------------------------
   function Place_Card (State : in out Game_State;
                        Row   : Board_Index;
                        Col   : Board_Index;
                        Card  : Card_Type) return Boolean is
   begin
      -- Check if position is already occupied
      if not Is_Position_Empty (State, Row, Col) then
         return False;
      end if;

      -- Place the card
      State.Board (Row, Col) := Make_Slot (Card);
      State.Cards_Placed := State.Cards_Placed + 1;

      -- Check if game is complete
      if State.Cards_Placed = Board_Size * Board_Size then
         State.Game_Over := True;
         State.Total_Score := Calculate_Total_Score (State);
      end if;

      return True;
   end Place_Card;

   -------------------------
   -- Is_Game_Complete
   -------------------------
   function Is_Game_Complete (State : Game_State) return Boolean is
   begin
      return State.Cards_Placed = Board_Size * Board_Size;
   end Is_Game_Complete;

   -------------------------
   -- Get_Row
   -------------------------
   function Get_Row (State : Game_State; Row : Board_Index) return Hand_Array is
      Hand : Hand_Array;
   begin
      for Col in Board_Index loop
         Hand (Col) := State.Board (Row, Col);
      end loop;
      return Hand;
   end Get_Row;

   -------------------------
   -- Get_Column
   -------------------------
   function Get_Column (State : Game_State; Col : Board_Index) return Hand_Array is
      Hand : Hand_Array;
   begin
      for Row in Board_Index loop
         Hand (Row) := State.Board (Row, Col);
      end loop;
      return Hand;
   end Get_Column;

   -------------------------
   -- Evaluate_Rows
   -------------------------
   function Evaluate_Rows (State : Game_State) return Hand_Results is
      Results : Hand_Results;
   begin
      for Row in Board_Index loop
         Results (Row) := Evaluate_Hand (Get_Row (State, Row));
      end loop;
      return Results;
   end Evaluate_Rows;

   -------------------------
   -- Evaluate_Columns
   -------------------------
   function Evaluate_Columns (State : Game_State) return Hand_Results is
      Results : Hand_Results;
   begin
      for Col in Board_Index loop
         Results (Col) := Evaluate_Hand (Get_Column (State, Col));
      end loop;
      return Results;
   end Evaluate_Columns;

   -------------------------
   -- Calculate_Row_Scores
   -------------------------
   function Calculate_Row_Scores (State : Game_State) return Score_Results is
      Results : Score_Results;
      Hands   : constant Hand_Results := Evaluate_Rows (State);
   begin
      for Row in Board_Index loop
         Results (Row) := Get_Score (Hands (Row));
      end loop;
      return Results;
   end Calculate_Row_Scores;

   -------------------------
   -- Calculate_Column_Scores
   -------------------------
   function Calculate_Column_Scores (State : Game_State) return Score_Results is
      Results : Score_Results;
      Hands   : constant Hand_Results := Evaluate_Columns (State);
   begin
      for Col in Board_Index loop
         Results (Col) := Get_Score (Hands (Col));
      end loop;
      return Results;
   end Calculate_Column_Scores;

   -------------------------
   -- Calculate_Total_Score
   -------------------------
   function Calculate_Total_Score (State : Game_State) return Natural is
      Total       : Natural := 0;
      Row_Scores  : constant Score_Results := Calculate_Row_Scores (State);
      Col_Scores  : constant Score_Results := Calculate_Column_Scores (State);
   begin
      -- Sum row scores
      for Row in Board_Index loop
         Total := Total + Row_Scores (Row);
      end loop;

      -- Sum column scores
      for Col in Board_Index loop
         Total := Total + Col_Scores (Col);
      end loop;

      return Total;
   end Calculate_Total_Score;

   -------------------------
   -- Get_Cards_Placed
   -------------------------
   function Get_Cards_Placed (State : Game_State) return Natural is
   begin
      return State.Cards_Placed;
   end Get_Cards_Placed;

end Game_Board;
