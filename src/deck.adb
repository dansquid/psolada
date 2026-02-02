-------------------------------------------------------------------------------
-- Deck Package Body
-- Implementation of deck operations with custom RNG
-------------------------------------------------------------------------------

with Ada.Calendar;

package body Deck is

   -- Linear Congruential Generator state
   LCG_State : Long_Long_Integer := 1;

   -- LCG parameters (same as glibc)
   LCG_A : constant Long_Long_Integer := 1103515245;
   LCG_C : constant Long_Long_Integer := 12345;
   LCG_M : constant Long_Long_Integer := 2 ** 31;

   -------------------------
   -- Initialize_Random
   -------------------------
   procedure Initialize_Random is
      use Ada.Calendar;
      Now     : constant Time := Clock;
      Seconds : constant Day_Duration := Ada.Calendar.Seconds (Now);
   begin
      -- Seed based on current time (seconds and day)
      LCG_State := Long_Long_Integer (Seconds * 1000.0) +
                   Long_Long_Integer (Day (Now)) * 86400 +
                   Long_Long_Integer (Month (Now)) * 2678400 +
                   Long_Long_Integer (Year (Now) mod 100) * 32140800;
      if LCG_State <= 0 then
         LCG_State := 1;
      end if;
   end Initialize_Random;

   -------------------------
   -- Random_Range
   -------------------------
   function Random_Range (Min, Max : Positive) return Positive is
      Range_Size : constant Long_Long_Integer :=
        Long_Long_Integer (Max - Min + 1);
      Result     : Long_Long_Integer;
   begin
      -- LCG step
      LCG_State := (LCG_A * LCG_State + LCG_C) mod LCG_M;

      -- Map to range
      Result := (LCG_State mod Range_Size) + Long_Long_Integer (Min);

      return Positive (Result);
   end Random_Range;

   -------------------------
   -- Initialize
   -------------------------
   procedure Initialize (D : out Deck_Type) is
      Index : Natural := 0;
   begin
      -- Create ordered deck
      for S in Suit_Type loop
         for R in Rank_Type loop
            Index := Index + 1;
            D.Cards (Index) := (Suit => S, Rank => R);
         end loop;
      end loop;

      D.Position := 1;
   end Initialize;

   -------------------------
   -- Shuffle
   -------------------------
   procedure Shuffle (D : in out Deck_Type) is
      J    : Positive;
      Temp : Card_Type;
   begin
      -- Fisher-Yates shuffle
      for I in reverse 2 .. Deck_Size loop
         J := Random_Range (1, I);

         -- Swap cards at positions I and J
         Temp := D.Cards (I);
         D.Cards (I) := D.Cards (J);
         D.Cards (J) := Temp;
      end loop;

      D.Position := 1;
   end Shuffle;

   -------------------------
   -- Deal
   -------------------------
   function Deal (D : in out Deck_Type; C : out Card_Type) return Boolean is
   begin
      if D.Position > Deck_Size then
         return False;
      end if;

      C := D.Cards (D.Position);
      D.Position := D.Position + 1;
      return True;
   end Deal;

   -------------------------
   -- Peek
   -------------------------
   function Peek (D : Deck_Type; C : out Card_Type) return Boolean is
   begin
      if D.Position > Deck_Size then
         return False;
      end if;

      C := D.Cards (D.Position);
      return True;
   end Peek;

   -------------------------
   -- Cards_Remaining
   -------------------------
   function Cards_Remaining (D : Deck_Type) return Natural is
   begin
      if D.Position > Deck_Size then
         return 0;
      else
         return Deck_Size - D.Position + 1;
      end if;
   end Cards_Remaining;

   -------------------------
   -- Reset_Position
   -------------------------
   procedure Reset_Position (D : in out Deck_Type) is
   begin
      D.Position := 1;
   end Reset_Position;

end Deck;
