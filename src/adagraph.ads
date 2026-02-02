-------------------------------------------------------------------------------
-- AdaGraph - Simple Graphics Library for Ada
-- A portable graphics library for educational purposes
--
-- This implementation provides basic 2D graphics primitives
-- Works on Linux (X11) and Windows (GDI)
-------------------------------------------------------------------------------

package AdaGraph is

   -- Initialize the graphics system and create a window
   -- X_Size, Y_Size: window dimensions in pixels
   -- X_Pos, Y_Pos: window position (0,0 for default)
   procedure Create_Graph (X_Size, Y_Size : Integer;
                           X_Pos, Y_Pos   : Integer := 0);

   -- Close the graphics window and cleanup
   procedure Destroy_Graph;

   -- Set the current drawing color (0-15 standard colors)
   -- 0=Black, 1=Blue, 2=Green, 3=Cyan, 4=Red, 5=Magenta,
   -- 6=Brown, 7=Light_Gray, 8=Dark_Gray, 9=Light_Blue,
   -- 10=Light_Green, 11=Light_Cyan, 12=Light_Red,
   -- 13=Light_Magenta, 14=Yellow, 15=White
   procedure Set_Color (Color : Integer);

   -- Draw a single pixel
   procedure Draw_Point (X, Y : Integer);

   -- Draw a line from (X1,Y1) to (X2,Y2)
   procedure Draw_Line (X1, Y1, X2, Y2 : Integer);

   -- Draw a rectangle outline
   procedure Draw_Box (X1, Y1, X2, Y2 : Integer);

   -- Draw a filled rectangle
   procedure Fill_Box (X1, Y1, X2, Y2 : Integer);

   -- Draw a circle outline
   procedure Draw_Circle (X, Y, Radius : Integer);

   -- Draw a filled circle
   procedure Fill_Circle (X, Y, Radius : Integer);

   -- Draw an ellipse outline
   procedure Draw_Ellipse (X, Y, X_Radius, Y_Radius : Integer);

   -- Draw a filled ellipse
   procedure Fill_Ellipse (X, Y, X_Radius, Y_Radius : Integer);

   -- Move text cursor to position
   procedure Goto_XY (X, Y : Integer);

   -- Output text at current cursor position
   procedure Put (S : String);

   -- Output a single character
   procedure Put (C : Character);

   -- Check if a key has been pressed (non-blocking)
   function Key_Hit return Boolean;

   -- Get the last key pressed (blocking)
   function Get_Key return Character;

   -- Get mouse position and button state
   -- Btn: 0=no button, 1=left, 2=middle, 3=right
   procedure Get_Mouse (X, Y : out Integer; Btn : out Integer);

   -- Flood fill from a point
   procedure Flood_Fill (X, Y : Integer);

   -- Clear the entire window with current color
   procedure Clear_Window;

   -- Get window dimensions
   function Get_Max_X return Integer;
   function Get_Max_Y return Integer;

   -- Delay for specified milliseconds
   procedure Delay_Ms (Ms : Integer);

private
   -- Internal state
   Window_Width  : Integer := 640;
   Window_Height : Integer := 480;
   Current_Color : Integer := 15;  -- White
   Cursor_X      : Integer := 0;
   Cursor_Y      : Integer := 0;
   Is_Open       : Boolean := False;

end AdaGraph;
