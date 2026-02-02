-------------------------------------------------------------------------------
-- High_Scores Package Specification
-- Manages local high score file for Poker Solitaire
-------------------------------------------------------------------------------

package High_Scores is

   -- Maximum number of high scores to track
   Max_Scores : constant := 10;

   -- Maximum name length
   Max_Name_Length : constant := 20;

   -- High score entry
   type Score_Entry is record
      Name  : String (1 .. Max_Name_Length);
      Score : Natural;
      Valid : Boolean;
   end record;

   -- Array of high scores
   type Score_Array is array (1 .. Max_Scores) of Score_Entry;

   -- High scores data
   type High_Score_Data is record
      Scores : Score_Array;
      Count  : Natural;
   end record;

   -- Default filename for high scores
   Default_Filename : constant String := "poker_solitaire_scores.dat";

   -- Initialize empty high score data
   procedure Initialize (Data : out High_Score_Data);

   -- Load high scores from file
   -- Returns True if successful, False if file not found or error
   function Load_Scores (Filename : String;
                         Data     : out High_Score_Data) return Boolean;

   -- Save high scores to file
   -- Returns True if successful
   function Save_Scores (Filename : String;
                         Data     : High_Score_Data) return Boolean;

   -- Check if a score qualifies for high score list
   function Is_High_Score (Data  : High_Score_Data;
                           Score : Natural) return Boolean;

   -- Add a new high score
   -- Returns True if added (score was high enough)
   function Add_Score (Data  : in out High_Score_Data;
                       Name  : String;
                       Score : Natural) return Boolean;

   -- Get the highest score
   function Get_Top_Score (Data : High_Score_Data) return Natural;

   -- Display all high scores
   procedure Display_Scores (Data : High_Score_Data);

   -- Pad or truncate name to fixed length
   function Format_Name (Name : String) return String;

end High_Scores;
