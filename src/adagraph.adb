-------------------------------------------------------------------------------
-- AdaGraph - Implementation
-- Cross-platform graphics using X11 (Linux) or Windows GDI
-------------------------------------------------------------------------------

with Interfaces.C;         use Interfaces.C;
with Interfaces.C.Strings; use Interfaces.C.Strings;
with System;

package body AdaGraph is

   -- Platform detection
   type Platform_Type is (Linux_X11, Windows_GDI, Unsupported);

   function Get_Platform return Platform_Type is
   begin
      -- Compile-time platform detection based on what's available
      -- This implementation targets X11 for Unix-like systems
      return Linux_X11;
   end Get_Platform;

   -- X11 types and bindings (for Linux)
   type Display_Ptr is new System.Address;
   type Window_Id is new unsigned_long;
   type GC_Ptr is new System.Address;
   type Colormap_Id is new unsigned_long;
   type Atom_Id is new unsigned_long;
   type XEvent_Data is array (1 .. 48) of unsigned_long;

   Null_Display : constant Display_Ptr := Display_Ptr (System.Null_Address);
   Null_GC      : constant GC_Ptr := GC_Ptr (System.Null_Address);

   -- X11 constants
   ExposureMask        : constant unsigned_long := 16#8000#;
   KeyPressMask        : constant unsigned_long := 16#1#;
   ButtonPressMask     : constant unsigned_long := 16#4#;
   ButtonReleaseMask   : constant unsigned_long := 16#8#;
   PointerMotionMask   : constant unsigned_long := 16#40#;
   StructureNotifyMask : constant unsigned_long := 16#20000#;

   KeyPress     : constant := 2;
   ButtonPress  : constant := 4;
   Expose       : constant := 12;

   -- X11 function imports
   pragma Linker_Options ("-lX11");

   function XOpenDisplay (Name : chars_ptr) return Display_Ptr;
   pragma Import (C, XOpenDisplay, "XOpenDisplay");

   procedure XCloseDisplay (Disp : Display_Ptr);
   pragma Import (C, XCloseDisplay, "XCloseDisplay");

   function XDefaultScreen (Disp : Display_Ptr) return int;
   pragma Import (C, XDefaultScreen, "XDefaultScreen");

   function XRootWindow (Disp : Display_Ptr; Screen : int) return Window_Id;
   pragma Import (C, XRootWindow, "XRootWindow");

   function XBlackPixel (Disp : Display_Ptr; Screen : int) return unsigned_long;
   pragma Import (C, XBlackPixel, "XBlackPixel");

   function XWhitePixel (Disp : Display_Ptr; Screen : int) return unsigned_long;
   pragma Import (C, XWhitePixel, "XWhitePixel");

   function XDefaultColormap (Disp : Display_Ptr; Screen : int) return Colormap_Id;
   pragma Import (C, XDefaultColormap, "XDefaultColormap");

   function XCreateSimpleWindow (Disp : Display_Ptr;
                                  Parent : Window_Id;
                                  X, Y : int;
                                  Width, Height : unsigned;
                                  Border_Width : unsigned;
                                  Border, Background : unsigned_long)
                                  return Window_Id;
   pragma Import (C, XCreateSimpleWindow, "XCreateSimpleWindow");

   procedure XMapWindow (Disp : Display_Ptr; Win : Window_Id);
   pragma Import (C, XMapWindow, "XMapWindow");

   procedure XDestroyWindow (Disp : Display_Ptr; Win : Window_Id);
   pragma Import (C, XDestroyWindow, "XDestroyWindow");

   function XCreateGC (Disp : Display_Ptr;
                       Win  : Window_Id;
                       Mask : unsigned_long;
                       Values : System.Address) return GC_Ptr;
   pragma Import (C, XCreateGC, "XCreateGC");

   procedure XFreeGC (Disp : Display_Ptr; Gc : GC_Ptr);
   pragma Import (C, XFreeGC, "XFreeGC");

   procedure XSetForeground (Disp : Display_Ptr; Gc : GC_Ptr; Pixel : unsigned_long);
   pragma Import (C, XSetForeground, "XSetForeground");

   procedure XDrawPoint (Disp : Display_Ptr; Win : Window_Id; Gc : GC_Ptr;
                         X, Y : int);
   pragma Import (C, XDrawPoint, "XDrawPoint");

   procedure XDrawLine (Disp : Display_Ptr; Win : Window_Id; Gc : GC_Ptr;
                        X1, Y1, X2, Y2 : int);
   pragma Import (C, XDrawLine, "XDrawLine");

   procedure XDrawRectangle (Disp : Display_Ptr; Win : Window_Id; Gc : GC_Ptr;
                             X, Y : int; Width, Height : unsigned);
   pragma Import (C, XDrawRectangle, "XDrawRectangle");

   procedure XFillRectangle (Disp : Display_Ptr; Win : Window_Id; Gc : GC_Ptr;
                             X, Y : int; Width, Height : unsigned);
   pragma Import (C, XFillRectangle, "XFillRectangle");

   procedure XDrawArc (Disp : Display_Ptr; Win : Window_Id; Gc : GC_Ptr;
                       X, Y : int; Width, Height : unsigned;
                       Angle1, Angle2 : int);
   pragma Import (C, XDrawArc, "XDrawArc");

   procedure XFillArc (Disp : Display_Ptr; Win : Window_Id; Gc : GC_Ptr;
                       X, Y : int; Width, Height : unsigned;
                       Angle1, Angle2 : int);
   pragma Import (C, XFillArc, "XFillArc");

   procedure XDrawString (Disp : Display_Ptr; Win : Window_Id; Gc : GC_Ptr;
                          X, Y : int; Str : chars_ptr; Len : int);
   pragma Import (C, XDrawString, "XDrawString");

   procedure XSelectInput (Disp : Display_Ptr; Win : Window_Id;
                           Event_Mask : unsigned_long);
   pragma Import (C, XSelectInput, "XSelectInput");

   procedure XNextEvent (Disp : Display_Ptr; Event : out XEvent_Data);
   pragma Import (C, XNextEvent, "XNextEvent");

   function XPending (Disp : Display_Ptr) return int;
   pragma Import (C, XPending, "XPending");

   procedure XFlush (Disp : Display_Ptr);
   pragma Import (C, XFlush, "XFlush");

   procedure XStoreName (Disp : Display_Ptr; Win : Window_Id; Name : chars_ptr);
   pragma Import (C, XStoreName, "XStoreName");

   function XLookupKeysym (Event : System.Address; Index : int) return unsigned_long;
   pragma Import (C, XLookupKeysym, "XLookupKeysym");

   -- Color type for X11
   type XColor is record
      Pixel : unsigned_long;
      Red   : unsigned_short;
      Green : unsigned_short;
      Blue  : unsigned_short;
      Flags : unsigned_char;
      Pad   : unsigned_char;
   end record;
   pragma Convention (C, XColor);

   function XAllocColor (Disp : Display_Ptr; Cmap : Colormap_Id;
                         Color : access XColor) return int;
   pragma Import (C, XAllocColor, "XAllocColor");

   -- Internal state
   Display    : Display_Ptr := Null_Display;
   Window     : Window_Id := 0;
   GC         : GC_Ptr := Null_GC;
   Screen_Num : int := 0;
   Colormap   : Colormap_Id := 0;

   -- Color palette (standard 16 colors)
   type Color_RGB is record
      R, G, B : unsigned_short;
   end record;

   Color_Palette : constant array (0 .. 15) of Color_RGB := (
      0  => (0,      0,      0),       -- Black
      1  => (0,      0,      16#AAAA#),-- Blue
      2  => (0,      16#AAAA#, 0),     -- Green
      3  => (0,      16#AAAA#, 16#AAAA#), -- Cyan
      4  => (16#AAAA#, 0,      0),     -- Red
      5  => (16#AAAA#, 0,      16#AAAA#), -- Magenta
      6  => (16#AAAA#, 16#5555#, 0),   -- Brown
      7  => (16#AAAA#, 16#AAAA#, 16#AAAA#), -- Light Gray
      8  => (16#5555#, 16#5555#, 16#5555#), -- Dark Gray
      9  => (16#5555#, 16#5555#, 16#FFFF#), -- Light Blue
      10 => (16#5555#, 16#FFFF#, 16#5555#), -- Light Green
      11 => (16#5555#, 16#FFFF#, 16#FFFF#), -- Light Cyan
      12 => (16#FFFF#, 16#5555#, 16#5555#), -- Light Red
      13 => (16#FFFF#, 16#5555#, 16#FFFF#), -- Light Magenta
      14 => (16#FFFF#, 16#FFFF#, 16#5555#), -- Yellow
      15 => (16#FFFF#, 16#FFFF#, 16#FFFF#)  -- White
   );

   Pixel_Colors : array (0 .. 15) of unsigned_long;

   -- Last key pressed
   Last_Key       : Character := ASCII.NUL;
   Key_Available  : Boolean := False;

   -- Mouse state
   Mouse_X   : Integer := 0;
   Mouse_Y   : Integer := 0;
   Mouse_Btn : Integer := 0;

   -------------------------
   -- Initialize_Colors
   -------------------------
   procedure Initialize_Colors is
      Color : aliased XColor;
      Res   : int;
   begin
      for I in 0 .. 15 loop
         Color.Red := Color_Palette (I).R;
         Color.Green := Color_Palette (I).G;
         Color.Blue := Color_Palette (I).B;
         Res := XAllocColor (Display, Colormap, Color'Access);
         Pixel_Colors (I) := Color.Pixel;
      end loop;
   end Initialize_Colors;

   -------------------------
   -- Process_Events
   -------------------------
   procedure Process_Events is
      Event     : XEvent_Data;
      Event_Type : int;
   begin
      while XPending (Display) > 0 loop
         XNextEvent (Display, Event);
         Event_Type := int (Event (1) and 16#FF#);

         case Event_Type is
            when KeyPress =>
               -- Extract key code from event
               declare
                  Keysym : unsigned_long;
               begin
                  Keysym := XLookupKeysym (Event'Address, 0);
                  if Keysym < 256 then
                     Last_Key := Character'Val (Integer (Keysym));
                     Key_Available := True;
                  elsif Keysym >= 16#FF00# and Keysym <= 16#FFFF# then
                     -- Special keys - map some common ones
                     case Keysym is
                        when 16#FF0D# => Last_Key := ASCII.CR;    -- Return
                        when 16#FF1B# => Last_Key := ASCII.ESC;   -- Escape
                        when 16#FF08# => Last_Key := ASCII.BS;    -- Backspace
                        when others => null;
                     end case;
                     Key_Available := True;
                  end if;
               end;

            when ButtonPress =>
               -- Extract button and position
               Mouse_X := Integer (Event (8) and 16#FFFF#);
               Mouse_Y := Integer ((Event (8) / 65536) and 16#FFFF#);
               Mouse_Btn := Integer (Event (10) and 16#FF#);

            when others =>
               null;
         end case;
      end loop;
   end Process_Events;

   -------------------------
   -- Create_Graph
   -------------------------
   procedure Create_Graph (X_Size, Y_Size : Integer;
                           X_Pos, Y_Pos   : Integer := 0) is
      Title : chars_ptr;
   begin
      if Is_Open then
         return;
      end if;

      Window_Width := X_Size;
      Window_Height := Y_Size;

      -- Open connection to X server
      Display := XOpenDisplay (Null_Ptr);
      if Display = Null_Display then
         raise Program_Error with "Cannot open X display";
      end if;

      Screen_Num := XDefaultScreen (Display);
      Colormap := XDefaultColormap (Display, Screen_Num);

      -- Create window
      Window := XCreateSimpleWindow (
         Display,
         XRootWindow (Display, Screen_Num),
         int (X_Pos),
         int (Y_Pos),
         unsigned (X_Size),
         unsigned (Y_Size),
         1,
         XBlackPixel (Display, Screen_Num),
         XWhitePixel (Display, Screen_Num)
      );

      -- Set window title
      Title := New_String ("Poker Solitaire");
      XStoreName (Display, Window, Title);
      Free (Title);

      -- Select input events
      XSelectInput (Display, Window,
                    ExposureMask or KeyPressMask or
                    ButtonPressMask or ButtonReleaseMask or
                    PointerMotionMask or StructureNotifyMask);

      -- Create graphics context
      GC := XCreateGC (Display, Window, 0, System.Null_Address);

      -- Initialize color palette
      Initialize_Colors;

      -- Map (show) window
      XMapWindow (Display, Window);
      XFlush (Display);

      Is_Open := True;

      -- Wait for window to be mapped (handle initial expose event)
      declare
         Event : XEvent_Data;
      begin
         loop
            XNextEvent (Display, Event);
            exit when int (Event (1) and 16#FF#) = Expose;
         end loop;
      end;
   end Create_Graph;

   -------------------------
   -- Destroy_Graph
   -------------------------
   procedure Destroy_Graph is
   begin
      if not Is_Open then
         return;
      end if;

      XFreeGC (Display, GC);
      XDestroyWindow (Display, Window);
      XCloseDisplay (Display);

      Display := Null_Display;
      GC := Null_GC;
      Is_Open := False;
   end Destroy_Graph;

   -------------------------
   -- Set_Color
   -------------------------
   procedure Set_Color (Color : Integer) is
      Index : Integer := Color;
   begin
      if not Is_Open then
         return;
      end if;

      if Index < 0 then Index := 0; end if;
      if Index > 15 then Index := 15; end if;

      Current_Color := Index;
      XSetForeground (Display, GC, Pixel_Colors (Index));
   end Set_Color;

   -------------------------
   -- Draw_Point
   -------------------------
   procedure Draw_Point (X, Y : Integer) is
   begin
      if not Is_Open then
         return;
      end if;
      XDrawPoint (Display, Window, GC, int (X), int (Y));
      XFlush (Display);
   end Draw_Point;

   -------------------------
   -- Draw_Line
   -------------------------
   procedure Draw_Line (X1, Y1, X2, Y2 : Integer) is
   begin
      if not Is_Open then
         return;
      end if;
      XDrawLine (Display, Window, GC, int (X1), int (Y1), int (X2), int (Y2));
      XFlush (Display);
   end Draw_Line;

   -------------------------
   -- Draw_Box
   -------------------------
   procedure Draw_Box (X1, Y1, X2, Y2 : Integer) is
      X, Y : int;
      W, H : unsigned;
   begin
      if not Is_Open then
         return;
      end if;

      X := int (Integer'Min (X1, X2));
      Y := int (Integer'Min (Y1, Y2));
      W := unsigned (abs (X2 - X1));
      H := unsigned (abs (Y2 - Y1));

      XDrawRectangle (Display, Window, GC, X, Y, W, H);
      XFlush (Display);
   end Draw_Box;

   -------------------------
   -- Fill_Box
   -------------------------
   procedure Fill_Box (X1, Y1, X2, Y2 : Integer) is
      X, Y : int;
      W, H : unsigned;
   begin
      if not Is_Open then
         return;
      end if;

      X := int (Integer'Min (X1, X2));
      Y := int (Integer'Min (Y1, Y2));
      W := unsigned (abs (X2 - X1));
      H := unsigned (abs (Y2 - Y1));

      XFillRectangle (Display, Window, GC, X, Y, W, H);
      XFlush (Display);
   end Fill_Box;

   -------------------------
   -- Draw_Circle
   -------------------------
   procedure Draw_Circle (X, Y, Radius : Integer) is
   begin
      if not Is_Open then
         return;
      end if;
      XDrawArc (Display, Window, GC,
                int (X - Radius), int (Y - Radius),
                unsigned (Radius * 2), unsigned (Radius * 2),
                0, 360 * 64);
      XFlush (Display);
   end Draw_Circle;

   -------------------------
   -- Fill_Circle
   -------------------------
   procedure Fill_Circle (X, Y, Radius : Integer) is
   begin
      if not Is_Open then
         return;
      end if;
      XFillArc (Display, Window, GC,
                int (X - Radius), int (Y - Radius),
                unsigned (Radius * 2), unsigned (Radius * 2),
                0, 360 * 64);
      XFlush (Display);
   end Fill_Circle;

   -------------------------
   -- Draw_Ellipse
   -------------------------
   procedure Draw_Ellipse (X, Y, X_Radius, Y_Radius : Integer) is
   begin
      if not Is_Open then
         return;
      end if;
      XDrawArc (Display, Window, GC,
                int (X - X_Radius), int (Y - Y_Radius),
                unsigned (X_Radius * 2), unsigned (Y_Radius * 2),
                0, 360 * 64);
      XFlush (Display);
   end Draw_Ellipse;

   -------------------------
   -- Fill_Ellipse
   -------------------------
   procedure Fill_Ellipse (X, Y, X_Radius, Y_Radius : Integer) is
   begin
      if not Is_Open then
         return;
      end if;
      XFillArc (Display, Window, GC,
                int (X - X_Radius), int (Y - Y_Radius),
                unsigned (X_Radius * 2), unsigned (Y_Radius * 2),
                0, 360 * 64);
      XFlush (Display);
   end Fill_Ellipse;

   -------------------------
   -- Goto_XY
   -------------------------
   procedure Goto_XY (X, Y : Integer) is
   begin
      Cursor_X := X;
      Cursor_Y := Y;
   end Goto_XY;

   -------------------------
   -- Put (String)
   -------------------------
   procedure Put (S : String) is
      C_Str : chars_ptr;
   begin
      if not Is_Open then
         return;
      end if;

      C_Str := New_String (S);
      XDrawString (Display, Window, GC,
                   int (Cursor_X), int (Cursor_Y + 12),
                   C_Str, int (S'Length));
      Free (C_Str);
      Cursor_X := Cursor_X + S'Length * 8;
      XFlush (Display);
   end Put;

   -------------------------
   -- Put (Character)
   -------------------------
   procedure Put (C : Character) is
   begin
      Put (String'(1 => C));
   end Put;

   -------------------------
   -- Key_Hit
   -------------------------
   function Key_Hit return Boolean is
   begin
      if not Is_Open then
         return False;
      end if;

      Process_Events;
      return Key_Available;
   end Key_Hit;

   -------------------------
   -- Get_Key
   -------------------------
   function Get_Key return Character is
      Result : Character;
   begin
      if not Is_Open then
         return ASCII.NUL;
      end if;

      -- Wait for a key
      loop
         Process_Events;
         exit when Key_Available;
         Delay_Ms (10);
      end loop;

      Result := Last_Key;
      Key_Available := False;
      return Result;
   end Get_Key;

   -------------------------
   -- Get_Mouse
   -------------------------
   procedure Get_Mouse (X, Y : out Integer; Btn : out Integer) is
   begin
      if not Is_Open then
         X := 0;
         Y := 0;
         Btn := 0;
         return;
      end if;

      Process_Events;
      X := Mouse_X;
      Y := Mouse_Y;
      Btn := Mouse_Btn;

      -- Clear button state after reading
      Mouse_Btn := 0;
   end Get_Mouse;

   -------------------------
   -- Flood_Fill
   -------------------------
   procedure Flood_Fill (X, Y : Integer) is
   begin
      -- Flood fill is complex to implement without additional X11 support
      -- For now, this is a placeholder
      null;
   end Flood_Fill;

   -------------------------
   -- Clear_Window
   -------------------------
   procedure Clear_Window is
   begin
      Fill_Box (0, 0, Window_Width, Window_Height);
   end Clear_Window;

   -------------------------
   -- Get_Max_X
   -------------------------
   function Get_Max_X return Integer is
   begin
      return Window_Width - 1;
   end Get_Max_X;

   -------------------------
   -- Get_Max_Y
   -------------------------
   function Get_Max_Y return Integer is
   begin
      return Window_Height - 1;
   end Get_Max_Y;

   -------------------------
   -- Delay_Ms
   -------------------------
   procedure Delay_Ms (Ms : Integer) is
   begin
      delay Duration (Ms) / 1000.0;
   end Delay_Ms;

end AdaGraph;
