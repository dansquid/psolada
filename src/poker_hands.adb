-------------------------------------------------------------------------------
-- Poker_Hands Package Body
-- Implementation of poker hand evaluation
-------------------------------------------------------------------------------

package body Poker_Hands is

   -- Rank count array for analysis
   type Rank_Count_Array is array (Rank_Type) of Natural;

   -- Suit count array
   type Suit_Count_Array is array (Suit_Type) of Natural;

   -------------------------
   -- Is_Complete
   -------------------------
   function Is_Complete (Hand : Hand_Array) return Boolean is
   begin
      for I in Hand'Range loop
         if Hand (I).State = Empty then
            return False;
         end if;
      end loop;
      return True;
   end Is_Complete;

   -------------------------
   -- Count_Ranks
   -------------------------
   procedure Count_Ranks (Hand : Hand_Array; Counts : out Rank_Count_Array) is
   begin
      -- Initialize all counts to 0
      for R in Rank_Type loop
         Counts (R) := 0;
      end loop;

      -- Count each rank
      for I in Hand'Range loop
         if Hand (I).State = Filled then
            Counts (Hand (I).Card.Rank) := Counts (Hand (I).Card.Rank) + 1;
         end if;
      end loop;
   end Count_Ranks;

   -------------------------
   -- Count_Suits
   -------------------------
   procedure Count_Suits (Hand : Hand_Array; Counts : out Suit_Count_Array) is
   begin
      -- Initialize all counts to 0
      for S in Suit_Type loop
         Counts (S) := 0;
      end loop;

      -- Count each suit
      for I in Hand'Range loop
         if Hand (I).State = Filled then
            Counts (Hand (I).Card.Suit) := Counts (Hand (I).Card.Suit) + 1;
         end if;
      end loop;
   end Count_Suits;

   -------------------------
   -- Is_Flush
   -------------------------
   function Is_Flush (Hand : Hand_Array) return Boolean is
      Suit_Counts : Suit_Count_Array;
   begin
      Count_Suits (Hand, Suit_Counts);

      for S in Suit_Type loop
         if Suit_Counts (S) = 5 then
            return True;
         end if;
      end loop;

      return False;
   end Is_Flush;

   -------------------------
   -- Is_Straight
   -------------------------
   function Is_Straight (Hand : Hand_Array) return Boolean is
      Rank_Counts : Rank_Count_Array;
      Start_Found : Boolean := False;
      Consecutive : Natural := 0;
      Has_Ace     : Boolean := False;
      Has_Two     : Boolean := False;
   begin
      Count_Ranks (Hand, Rank_Counts);

      -- Check for regular straight (5 consecutive ranks)
      for R in Rank_Type loop
         if Rank_Counts (R) = 1 then
            if not Start_Found then
               Start_Found := True;
               Consecutive := 1;
            else
               Consecutive := Consecutive + 1;
            end if;
         elsif Rank_Counts (R) = 0 and Start_Found then
            -- Gap found, check if we had 5 consecutive
            if Consecutive = 5 then
               return True;
            end if;
            Start_Found := False;
            Consecutive := 0;
         elsif Rank_Counts (R) > 1 then
            -- Duplicate rank, not a straight
            return False;
         end if;
      end loop;

      -- Check if final count is 5
      if Consecutive = 5 then
         return True;
      end if;

      -- Check for A-2-3-4-5 (wheel straight)
      Has_Ace := Rank_Counts (Ace) = 1;
      Has_Two := Rank_Counts (Two) = 1;

      if Has_Ace and Has_Two and
         Rank_Counts (Three) = 1 and
         Rank_Counts (Four) = 1 and
         Rank_Counts (Five) = 1
      then
         return True;
      end if;

      return False;
   end Is_Straight;

   -------------------------
   -- Is_Royal
   -------------------------
   function Is_Royal (Hand : Hand_Array) return Boolean is
      Rank_Counts : Rank_Count_Array;
   begin
      Count_Ranks (Hand, Rank_Counts);

      return Rank_Counts (Ten) = 1 and
             Rank_Counts (Jack) = 1 and
             Rank_Counts (Queen) = 1 and
             Rank_Counts (King) = 1 and
             Rank_Counts (Ace) = 1;
   end Is_Royal;

   -------------------------
   -- Count_Pairs_And_Sets
   -------------------------
   procedure Count_Pairs_And_Sets (Hand        : Hand_Array;
                                   Pairs       : out Natural;
                                   Threes      : out Natural;
                                   Fours       : out Natural) is
      Rank_Counts : Rank_Count_Array;
   begin
      Count_Ranks (Hand, Rank_Counts);

      Pairs := 0;
      Threes := 0;
      Fours := 0;

      for R in Rank_Type loop
         case Rank_Counts (R) is
            when 2 => Pairs := Pairs + 1;
            when 3 => Threes := Threes + 1;
            when 4 => Fours := Fours + 1;
            when others => null;
         end case;
      end loop;
   end Count_Pairs_And_Sets;

   -------------------------
   -- Evaluate_Hand
   -------------------------
   function Evaluate_Hand (Hand : Hand_Array) return Hand_Rank is
      Flush_Found    : Boolean;
      Straight_Found : Boolean;
      Pairs          : Natural;
      Threes         : Natural;
      Fours          : Natural;
   begin
      -- Must have all 5 cards
      if not Is_Complete (Hand) then
         return No_Hand;
      end if;

      Flush_Found := Is_Flush (Hand);
      Straight_Found := Is_Straight (Hand);
      Count_Pairs_And_Sets (Hand, Pairs, Threes, Fours);

      -- Check from highest to lowest

      -- Royal Flush: A-K-Q-J-10 of same suit
      if Flush_Found and Straight_Found and Is_Royal (Hand) then
         return Royal_Flush;
      end if;

      -- Straight Flush: Any straight in same suit
      if Flush_Found and Straight_Found then
         return Straight_Flush;
      end if;

      -- Four of a Kind
      if Fours = 1 then
         return Four_Of_A_Kind;
      end if;

      -- Full House: Three of a kind + a pair
      if Threes = 1 and Pairs = 1 then
         return Full_House;
      end if;

      -- Flush: All same suit
      if Flush_Found then
         return Flush;
      end if;

      -- Straight: 5 sequential ranks
      if Straight_Found then
         return Straight;
      end if;

      -- Three of a Kind
      if Threes = 1 then
         return Three_Of_A_Kind;
      end if;

      -- Two Pair
      if Pairs = 2 then
         return Two_Pair;
      end if;

      -- One Pair
      if Pairs = 1 then
         return One_Pair;
      end if;

      -- No hand (high card / bust)
      return No_Hand;
   end Evaluate_Hand;

   -------------------------
   -- Get_Score
   -------------------------
   function Get_Score (Rank : Hand_Rank) return Natural is
   begin
      return American_Scores (Rank);
   end Get_Score;

   -------------------------
   -- Hand_Name
   -------------------------
   function Hand_Name (Rank : Hand_Rank) return String is
   begin
      case Rank is
         when No_Hand         => return "No Hand";
         when One_Pair        => return "One Pair";
         when Two_Pair        => return "Two Pair";
         when Three_Of_A_Kind => return "Three of a Kind";
         when Straight        => return "Straight";
         when Flush           => return "Flush";
         when Full_House      => return "Full House";
         when Four_Of_A_Kind  => return "Four of a Kind";
         when Straight_Flush  => return "Straight Flush";
         when Royal_Flush     => return "Royal Flush";
      end case;
   end Hand_Name;

end Poker_Hands;
