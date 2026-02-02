-------------------------------------------------------------------------------
-- Deck Package Specification
-- Manages a deck of 52 cards with shuffling capability
-------------------------------------------------------------------------------

with Cards; use Cards;

package Deck is

   -- Standard deck size
   Deck_Size : constant := 52;

   -- Array of cards
   type Card_Array is array (1 .. Deck_Size) of Card_Type;

   -- Deck type with current position
   type Deck_Type is record
      Cards    : Card_Array;
      Position : Natural;  -- Next card to deal (1-52, 53 = empty)
   end record;

   -- Initialize a new ordered deck
   procedure Initialize (D : out Deck_Type);

   -- Shuffle the deck using Fisher-Yates algorithm
   procedure Shuffle (D : in out Deck_Type);

   -- Deal the next card from the deck
   -- Returns True if successful, False if deck is empty
   function Deal (D : in out Deck_Type; C : out Card_Type) return Boolean;

   -- Peek at the next card without dealing
   function Peek (D : Deck_Type; C : out Card_Type) return Boolean;

   -- Get number of cards remaining
   function Cards_Remaining (D : Deck_Type) return Natural;

   -- Reset deck position to start (keeping current order)
   procedure Reset_Position (D : in out Deck_Type);

   -- Simple random number generator (Linear Congruential Generator)
   -- Seed with system time for randomness
   procedure Initialize_Random;

   -- Get random number in range [Min, Max]
   function Random_Range (Min, Max : Positive) return Positive;

end Deck;
