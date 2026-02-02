-------------------------------------------------------------------------------
-- Poker_Hands Package Specification
-- Evaluates poker hands and calculates scores
-------------------------------------------------------------------------------

with Cards; use Cards;

package Poker_Hands is

   -- Hand size for poker
   Hand_Size : constant := 5;

   -- Array of 5 cards
   type Hand_Array is array (1 .. Hand_Size) of Card_Slot;

   -- Poker hand rankings (from lowest to highest)
   type Hand_Rank is (
      No_Hand,         -- Less than a pair (bust)
      One_Pair,        -- Two cards of same rank
      Two_Pair,        -- Two different pairs
      Three_Of_A_Kind, -- Three cards of same rank
      Straight,        -- Five sequential ranks
      Flush,           -- Five cards of same suit
      Full_House,      -- Three of a kind + pair
      Four_Of_A_Kind,  -- Four cards of same rank
      Straight_Flush,  -- Straight + Flush
      Royal_Flush      -- A-K-Q-J-10 of same suit
   );

   -- Score values for each hand type (American scoring)
   type Score_Array is array (Hand_Rank) of Natural;

   American_Scores : constant Score_Array := (
      No_Hand         => 0,
      One_Pair        => 2,
      Two_Pair        => 5,
      Three_Of_A_Kind => 10,
      Straight        => 15,
      Flush           => 20,
      Full_House      => 25,
      Four_Of_A_Kind  => 50,
      Straight_Flush  => 75,
      Royal_Flush     => 100
   );

   -- British scoring (alternative)
   British_Scores : constant Score_Array := (
      No_Hand         => 0,
      One_Pair        => 1,
      Two_Pair        => 3,
      Three_Of_A_Kind => 6,
      Straight        => 12,
      Flush           => 5,
      Full_House      => 10,
      Four_Of_A_Kind  => 16,
      Straight_Flush  => 30,
      Royal_Flush     => 30
   );

   -- Evaluate a 5-card hand and return its rank
   function Evaluate_Hand (Hand : Hand_Array) return Hand_Rank;

   -- Get score for a hand rank
   function Get_Score (Rank : Hand_Rank) return Natural;

   -- Get name of hand rank
   function Hand_Name (Rank : Hand_Rank) return String;

   -- Check if hand is complete (all 5 cards placed)
   function Is_Complete (Hand : Hand_Array) return Boolean;

end Poker_Hands;
