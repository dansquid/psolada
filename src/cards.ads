-------------------------------------------------------------------------------
-- Cards Package Specification
-- Defines card types, suits, ranks for Poker Solitaire
-------------------------------------------------------------------------------

package Cards is

   -- Card suit enumeration
   type Suit_Type is (Hearts, Diamonds, Clubs, Spades);

   -- Card rank enumeration (Ace high)
   type Rank_Type is (Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten,
                      Jack, Queen, King, Ace);

   -- A playing card record
   type Card_Type is record
      Suit : Suit_Type;
      Rank : Rank_Type;
   end record;

   -- Empty card constant (for unplaced positions)
   Empty_Card : constant Card_Type := (Hearts, Two);

   -- Card validity tracking
   type Card_State is (Empty, Filled);

   -- Card with state
   type Card_Slot is record
      Card  : Card_Type;
      State : Card_State;
   end record;

   -- Initialize an empty slot
   function Empty_Slot return Card_Slot;

   -- Create a filled slot
   function Make_Slot (C : Card_Type) return Card_Slot;

   -- Get string representation of a card
   function Card_To_String (C : Card_Type) return String;

   -- Get short string (e.g., "AS" for Ace of Spades)
   function Card_To_Short_String (C : Card_Type) return String;

   -- Get suit symbol
   function Suit_Symbol (S : Suit_Type) return Character;

   -- Get rank symbol
   function Rank_Symbol (R : Rank_Type) return String;

   -- Get numeric value of rank (for comparison)
   function Rank_Value (R : Rank_Type) return Natural;

end Cards;
