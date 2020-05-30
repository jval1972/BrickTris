unit bt_consts;

interface

uses
  Types;

type
  TShapeType = (
    st3005,
    stFeat1,
    stFeat2,
    stBox,
    stLine,
    stZed1,
    stZed2,
    st3004,
    stTree,
    st2357,
    st3622,
    st3002,
    stNumShapes
  );

const
  BRICKSIZE = 25;
  MAXBRICKCOUNT = 6; // Total number of bricks per shape.

  BOARDXSIZE = 10;
  BOARDYSIZE = 20;
  BOARDSHAPETIPMAX = 10;

  TAG_INITSTART = 1000;
  TAG_RESTART = 100;
  TAG_ENDGAME = 0;

  VK_H = 72;
  VK_P = 80;
  VK_Q = 81;

  ShapesStruct: array[0..Ord(stNumShapes) - 1, 0..MAXBRICKCOUNT - 1] of TPoint = (
    ((X:1;Y:1), (X:0;Y:0), (X:0;Y:0), (X:0;Y:0), (X:0;Y:0), (X:0;Y:0)), // Brick 1 x 1
    ((X:1;Y:1), (X:2;Y:1), (X:3;Y:1), (X:3;Y:2), (X:0;Y:0), (X:0;Y:0)), // F 1
    ((X:3;Y:1), (X:2;Y:1), (X:1;Y:1), (X:1;Y:2), (X:0;Y:0), (X:0;Y:0)), // F 2
    ((X:1;Y:1), (X:1;Y:2), (X:2;Y:1), (X:2;Y:2), (X:0;Y:0), (X:0;Y:0)), // Brick 2 x 2
    ((X:1;Y:1), (X:2;Y:1), (X:3;Y:1), (X:4;Y:1), (X:0;Y:0), (X:0;Y:0)), // Brick 1 x 4
    ((X:1;Y:1), (X:2;Y:1), (X:2;Y:2), (X:3;Y:2), (X:0;Y:0), (X:0;Y:0)), // Z 1
    ((X:3;Y:1), (X:2;Y:1), (X:2;Y:2), (X:1;Y:2), (X:0;Y:0), (X:0;Y:0)), // Z 2
    ((X:1;Y:1), (X:2;Y:1), (X:0;Y:0), (X:0;Y:0), (X:0;Y:0), (X:0;Y:0)), // Brick 1 x 2
    ((X:1;Y:1), (X:2;Y:1), (X:3;Y:1), (X:2;Y:2), (X:0;Y:0), (X:0;Y:0)), // T
    ((X:1;Y:1), (X:2;Y:1), (X:2;Y:2), (X:0;Y:0), (X:0;Y:0), (X:0;Y:0)), // Brick 2 x 2 Corner
    ((X:1;Y:1), (X:2;Y:1), (X:3;Y:1), (X:0;Y:0), (X:0;Y:0), (X:0;Y:0)), // Brick 1 x 3
    ((X:1;Y:1), (X:2;Y:1), (X:3;Y:1), (X:1;Y:2), (X:2;Y:2), (X:3;Y:2))  // Brick 2 x 3
 );


implementation

end.
