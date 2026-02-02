-------------------------------------------------------------------------------
-- Cards Package Body
-- Implementation of card operations
-------------------------------------------------------------------------------

package body Cards is

   -------------------------
   -- Empty_Slot
   -------------------------
   function Empty_Slot return Card_Slot is
   begin
      return (Card => Empty_Card, State => Empty);
   end Empty_Slot;

   -------------------------
   -- Make_Slot
   -------------------------
   function Make_Slot (C : Card_Type) return Card_Slot is
   begin
      return (Card => C, State => Filled);
   end Make_Slot;

   -------------------------
   -- Suit_Symbol
   -------------------------
   function Suit_Symbol (S : Suit_Type) return Character is
   begin
      case S is
         when Hearts   => return 'H';
         when Diamonds => return 'D';
         when Clubs    => return 'C';
         when Spades   => return 'S';
      end case;
   end Suit_Symbol;

   -------------------------
   -- Rank_Symbol
   -------------------------
   function Rank_Symbol (R : Rank_Type) return String is
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
   end Rank_Symbol;

   -------------------------
   -- Rank_Value
   -------------------------
   function Rank_Value (R : Rank_Type) return Natural is
   begin
      return Rank_Type'Pos (R) + 2;  -- Two = 2, ..., Ace = 14
   end Rank_Value;

   -------------------------
   -- Card_To_String
   -------------------------
   function Card_To_String (C : Card_Type) return String is
      Rank_Str : constant String := Rank_Symbol (C.Rank);
      Suit_Str : constant String := (1 => Suit_Symbol (C.Suit));
   begin
      return Rank_Str & Suit_Str;
   end Card_To_String;

   -------------------------
   -- Card_To_Short_String
   -------------------------
   function Card_To_Short_String (C : Card_Type) return String is
   begin
      return Card_To_String (C);
   end Card_To_Short_String;

end Cards;
