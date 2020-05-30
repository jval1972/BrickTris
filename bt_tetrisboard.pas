unit bt_tetrisboard;

interface

uses
  Classes, Windows, Graphics, Controls, Contnrs, ExtCtrls,
  Messages, Forms, SysUtils, Dialogs,
  bt_consts, bt_messages, bt_hiscores;

type
  TTetrisBrick = class(TObject)
  private
    fPosition: TPoint;
    fShapeOffset: integer;
  public
    constructor Create(const P: TPoint; const Offs: integer); virtual;
    procedure DrawBrick(const Canvas: TCanvas; const T: TRect); virtual;
    procedure DrawBrickShadow(const Canvas: TCanvas; const T: TRect; const val: integer); virtual;
  published
    property Position: TPoint read fPosition write fPosition;
  end;

type
  TFindType = (ftXMin, ftYMin, ftMaxAll, ftXMax, ftYMax);

type
  TTetrisShape = class(TObject)
  private
    BrickList: TObjectList;
    FBoardPoint: TPoint;
    FBoardPointInEnd: TPoint;
    function GetBricks(index: integer): TTetrisBrick;
    procedure SetBricks(index: integer; const Value: TTetrisBrick);
    function GetBrickCount: integer;
    procedure SetBoardPoint(const Value: TPoint);
    procedure SetBoardPointInEnd(const Value: TPoint);
  public
    ShapeType: TShapeType;
    constructor Create(st: TShapeType); virtual;
    destructor Destroy; override;
    procedure Rotate(Dir: Byte);
    function FindBricksMax(FindType: TFindType): integer;
    procedure IncreaseBoardX(IncBy: integer);
    procedure IncreaseBoardY(IncBy: integer);
    property Bricks[index: integer]:TTetrisBrick read GetBricks write SetBricks;
    property BoardPoint: TPoint read FBoardPoint write SetBoardPoint;
    property BoardPointInEnd: TPoint read FBoardPointInEnd write SetBoardPointInEnd;
    property BricksCount: integer read GetBrickCount;
  end;

type
  TBoardLastEmptyRec = record
    EndPoint: TPoint;
    Res: boolean;
    Distance: integer;
  end;

type
  TTetrisBoard = class(TGraphicControl)
  private
    fBoard: TBitmap;
    fHighScores: THighScoreTable;
    Msg: TBoardMessage;
    ShapeList: TObjectList;
    BrickList: TObjectList;

    GameTimer: TTimer;

    Positions: array[0..BOARDYSIZE - 1] of string[BOARDXSIZE];

    GameLines: integer;
    GameLevel: integer;
    GameScore: integer;

    DrawShapeEndPoint: boolean;
    TipShapeDistance: integer;
    ShowMessageFlag: boolean;
    procedure OnMyTimer(Sender: TObject);
    function GetShapes(index: integer): TTetrisShape;
    function GetBoardShapes(x, y: integer): TTetrisBrick;
    function GetBricks(index: integer): TTetrisBrick;
  protected
    procedure Paint; override;
    function ActiveShape: TTetrisShape;
    function WaitingShape: TTetrisShape;
    function ShapeCanMoveDown: boolean;
    function ShapeCanMoveLeft: boolean;
    function ShapeCanMoveRight: boolean;
    function BoardGetLastEmpty: TBoardLastEmptyRec;
    procedure PlaceShapeAtBoard;
    procedure SwitchNewShape;
    procedure AddRandomShape;
    procedure FindLinesAndDelete;
    procedure PlaceinBottom;
    procedure InitOptions;
    procedure DrawWaitingShape;
    procedure DrawOptions;
    procedure BoardShowMessage(const s: string);
    function CalcShapeEndPoint: boolean;
 public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure HandleKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure StartGame;
    procedure RestartGame;
    property Shapes[index: integer]: TTetrisShape read GetShapes;
    property Bricks[index: integer]: TTetrisBrick read GetBricks;
    property BoardShapes[x, y: integer]: TTetrisBrick read GetBoardShapes;
    property HighScores: THighScoreTable read fHighScores;
 end;

implementation

uses
  frm_main, frm_EnterName, frm_hiscores, frm_help, bt_defs;

function MaxI(const x, y: integer): integer;
begin
  if x < y then
    Result := y
  else
    Result := x;
end;

//
// TTetrisBrick
//
constructor TTetrisBrick.Create(const P: TPoint; const Offs: integer);
begin
  inherited Create;
  fPosition := P;
  fShapeOffset := Offs;
end;

procedure TTetrisBrick.DrawBrick(const Canvas: TCanvas; const T: TRect);
var
  R: TRect;
begin
  R := T;
  BitBlt(Canvas.Handle, R.Left, R.Top, BRICKSIZE, BRICKSIZE,
         MainForm.BrickBM.Canvas.Handle, fShapeOffset * BRICKSIZE, MainForm.ThemeIndex * BRICKSIZE, SRCCOPY);
end;

procedure TTetrisBrick.DrawBrickShadow(const Canvas: TCanvas; const T: TRect; const val: integer);
var
  R: TRect;
begin
  R:= T;
  with Canvas do
  begin
    brush.Color := RGB(105 - val * 2, 105 - val * 2, 105 - val * 2);
    Rectangle(T.Left, T.Top, T.Right, T.Bottom);
  end;
end;

//
// TTetrisShape
//
constructor TTetrisShape.Create(st: TShapeType);
var
  i: integer;
begin
  ShapeType := ST;
  BrickList := TObjectList.Create;
  for i := 0 to MAXBRICKCOUNT - 1 do
  begin
    if (ShapesStruct[Ord(st), i].X <> 0) and
       (ShapesStruct[Ord(st), i].Y <> 0) then
        BrickList.Add(TTetrisBrick.Create(ShapesStruct[Ord(st), i], Ord(st)));
  end;
  BoardPoint := Point((BOARDXSIZE div 2) - (FindBricksMax(ftMaxAll) div 2), 0);
end;

destructor TTetrisShape.Destroy;
begin
  inherited;

  while BrickList.Count > 0 do
    BrickList.Remove(BrickList.Items[0]);

  BrickList.Free;
end;

function TTetrisShape.GetBrickCount: integer;
begin
  Result := BrickList.Count;
end;

function TTetrisShape.GetBricks(index: integer): TTetrisBrick;
begin
 Result := TTetrisBrick(BrickList.Items[index]);
end;

procedure TTetrisShape.IncreaseBoardX(IncBy: integer);
begin
  BoarDPoint := Point(BoardPoint.X + IncBy, BoardPoint.Y);
end;

procedure TTetrisShape.IncreaseBoardY(IncBy: integer);
begin
  BoarDPoint := Point(BoardPoint.X, BoardPoint.Y + IncBy);
end;

procedure TTetrisShape.SetBoardPoint(const Value: TPoint);
begin
  FBoardPoint := Value;
end;

procedure TTetrisShape.SetBoardPointInEnd(const Value: TPoint);
begin
  FBoardPointInEnd := Value;
end;

procedure TTetrisShape.SetBricks(index: integer; const Value: TTetrisBrick);
begin
  BrickList.Items[index] := Value;
end;

function TTetrisShape.FindBricksMax(FindType: TFindType): integer;
var
  i: integer;
begin
  Result := 0;
  if FindType in [ftXMin, ftYMin] then
    Result := FindBricksMax(ftMaxAll);

  for i := 0 to BrickList.Count - 1 do
    case FindType of
      ftMaxAll:
        if (Bricks[i].Position.X > Result) or
           (Bricks[i].Position.Y > Result) then
           Result := MaxI(Bricks[i].Position.X, Bricks[i].Position.Y);
      ftXMin:
        if Bricks[i].Position.X < Result then
          Result := Bricks[i].Position.X;
      ftYMin:
        if Bricks[i].Position.Y < Result then
          Result := Bricks[i].Position.Y;
      ftXMax:
        if Bricks[i].Position.X > Result then
          Result := Bricks[i].Position.X;
      ftYMax:
        if Bricks[i].Position.Y > Result then
          Result := Bricks[i].Position.Y;
    end;
end;

procedure TTetrisShape.Rotate(Dir: Byte);

  procedure UpdateBricksPosition;
  var
    ii: integer;
  begin
    if FindBricksMax(ftXMin) > 1 then
    begin
      for ii := 0 to BrickList.Count - 1 do
        Bricks[ii].Position := Point(Bricks[ii].Position.X - 1, Bricks[ii].Position.Y);
      UpdateBricksPosition;
    end;
    if FindBricksMax(ftYMin) > 1 then
    begin
      for ii := 0 to BrickList.Count - 1 do
        Bricks[ii].Position := Point(Bricks[ii].Position.X, Bricks[ii].Position.Y - 1);
      UpdateBricksPosition;
    end;
  end;

var
  i, mx: integer;
begin
  inherited;
  mx := FindBricksMax(ftMaxAll);
  for i := 0 to BrickList.Count - 1 do
  begin
    Bricks[i].Position := Point(
            mx + 1 - Bricks[i].Position.Y,
                     Bricks[i].Position.X);
  end;
  UpdateBricksPosition;
end;

//
// TTetrisBoard
//
constructor TTetrisBoard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Randomize;

  ControlStyle := ControlStyle + [csOpaque];
  ShapeList := TObjectList.Create;
  BrickList := TObjectList.Create;
  Msg := TBoardMessage.Create(self);

  Parent := TWinControl(AOwner);

  Width := BOARDXSIZE * BRICKSIZE + 1;
  Height := BOARDYSIZE * BRICKSIZE + 1;

  Width := Width + Width div 2 + Width div 8;

  fBoard := TBitmap.Create;
  fBoard.Width := Width;
  fBoard.Height := Height;

  GameTimer := TTimer.Create(nil);
  GameTimer.Interval := 1000;
  GameTimer.Enabled := False;
  GameTimer.OnTimer := OnMyTimer;
  GameTimer.Tag := 1000;

  InitOptions;

  fHighScores := THighScoreTable.Create(ChangeFileExt(ParamStr(0), '.hi'));

  ShowMessageFlag := True;
end;

destructor TTetrisBoard.Destroy;
begin
  BrickList.Free;
  ShapeList.Free;
  Msg.Free;
  fBoard.Free;
  GameTimer.Free;
  fHighScores.Free;
  inherited;
end;

function TTetrisBoard.ActiveShape: TTetrisShape;
begin
  Result := Shapes[0];
end;

procedure TTetrisBoard.AddRandomShape;
begin
  ShapeList.Add(TTetrisShape.Create(TShapeType(Random(Ord(stNumShapes)))));
end;

function TTetrisBoard.BoardGetLastEmpty: TBoardLastEmptyRec;
var
  i, Cnt: integer;
  yBrick, xBrick: integer;
begin
  Result.Res := False;
  Cnt := 1;
  yBrick := 0;
  repeat
    for i := 0 to ActiveShape.BricksCount - 1 do
    begin
      yBrick := (ActiveShape.Bricks[i].Position.Y - 1) + (ActiveShape.BoardPoint.Y);
      xBrick := (ActiveShape.Bricks[i].Position.X - 1) + (ActiveShape.BoardPoint.X);

      if BoardShapes[xBrick, yBrick + Cnt] <> nil then
      begin
        Result.EndPoint:= Point(ActiveShape.BoardPoint.X,
                                yBrick+Cnt- ActiveShape.Bricks[i].Position.Y) ;

        if Result.EndPoint.Y + ActiveShape.FindBricksMax(ftYMax) > BOARDYSIZE - 1 then
          Result.EndPoint := Point(Result.EndPoint.X,
                                   Result.EndPoint.Y - (ActiveShape.FindBricksMax(ftYMax) + Result.EndPoint.Y - BOARDYSIZE));
        Result.Distance := yBrick + Cnt;
        Result.Res := True;
        Exit;
      end;

    end;//end for

    Inc(Cnt);
  until (Cnt + yBrick > BOARDYSIZE - 1);

  if (yBrick + Cnt = BOARDYSIZE) then
  begin
    Result.EndPoint := Point(ActiveShape.BoardPoint.X,
                            (yBrick + Cnt) - ActiveShape.FindBricksMax(ftYMax));
    Result.Distance := yBrick + Cnt;
    Result.Res := True;
  end;
end;

procedure TTetrisBoard.BoardShowMessage(const s: String);
begin
  Msg.Show(s);
  ShowMessageFlag := True;
end;

function TTetrisBoard.CalcShapeEndPoint: boolean;
var
  Rec: TBoardLastEmptyRec;
begin
  Rec := BoardGetLastEmpty;

  // Flag to show or hide the Shape Tips...
  // When ditance between current y, and minimum
  // empty point is less, hide.
  Result := (Rec.Distance - ActiveShape.BoardPoint.Y) > BOARDSHAPETIPMAX;

  ActiveShape.BoardPointInEnd := Rec.EndPoint;
  TipShapeDistance := Rec.Distance - ActiveShape.BoardPoint.Y;
end;

procedure TTetrisBoard.DrawOptions;
begin
  with fBoard.Canvas do
  begin
   Font.Name := 'Arial';
   Font.Size := 20;
   Font.Color := clBlue;

   TextOut(BOARDXSIZE * BRICKSIZE + 80, 218, IntToStr(GameLines));
   TextOut(BOARDXSIZE * BRICKSIZE + 80, 266, IntToStr(GameLevel));
   TextOut(BOARDXSIZE * BRICKSIZE + 80, 313, IntToStr(GameScore));
  end;
end;

procedure TTetrisBoard.DrawWaitingShape;
var
  T: TRect;
  i: integer;
  ActiveDiv: integer;
begin
  InitOptions;

  ActiveDiv := ((4 * BRICKSIZE) - (WaitingShape.FindBricksMax(ftXMax) * BRICKSIZE)) div 2;

  for i := 0 to WaitingShape.BricksCount - 1 do
  begin
    T:= Rect(ActiveDiv +  BOARDXSIZE * BRICKSIZE + 2 +  WaitingShape.Bricks[i].Position.X * BRICKSIZE,
             60 + WaitingShape.Bricks[i].Position.Y * BRICKSIZE,
             ActiveDiv + BOARDXSIZE * BRICKSIZE + 2 + WaitingShape.Bricks[i].Position.X * BRICKSIZE + BRICKSIZE + 1,
             60 + WaitingShape.Bricks[i].Position.Y * BRICKSIZE + BRICKSIZE + 1);
    WaitingShape.Bricks[i].DrawBrick(fBoard.Canvas, T);
  end;
  DrawOptions;
end;

const
  NUM_INTERVALS = 32;

  INTERVALS: array[1..NUM_INTERVALS] of integer = (
    1000, 900, 810, 729, 656, 590, 531, 478,
     430, 387, 348, 313, 282, 254, 228, 205,
     185, 166, 150, 135, 121, 109,  98,  88,
      79,  71,  64,  58,  52,  47,  42,  38
  );

procedure TTetrisBoard.FindLinesAndDelete;
var
  i, j: integer;
  startlevel: integer;
  lines: integer;
begin
  startlevel := GameLevel;
  lines := 0;
  for i := 0 to BOARDYSIZE - 1 do
    if Pos('0', Positions[i]) = 0 then
    begin //remove line i
      for j := 0 to BOARDXSIZE - 1 do //remove line
        BrickList.Remove(BoardShapes[j, i]);

      for j := 0 to BrickList.Count - 1 do
        if Bricks[j].Position.Y < i then
          Bricks[j].Position := Point(Bricks[j].Position.X, Bricks[j].Position.Y + 1);

      for j := i downto 1 do // update strings
        Positions[j] := Positions[j - 1];

      inc(GameLines);
      inc(lines);
      inc(GameScore, startlevel * lines);
      GameLevel := 1 + (GameLines div 5);
      if GameLevel >= NUM_INTERVALS then
        GameTimer.Interval := INTERVALS[NUM_INTERVALS]
      else
        GameTimer.Interval := INTERVALS[GameLevel];
    end;
end;

function TTetrisBoard.GetBoardShapes(x, y: integer): TTetrisBrick;
var
  i: integer;
begin
  for i := 0 to BrickList.Count - 1 do
  begin
    if (Bricks[i].Position.X = X) and
       (Bricks[i].Position.Y = Y) then
    begin
      Result := Bricks[i];
      Exit;
    end;
  end;
  Result := nil;
end;

function TTetrisBoard.GetBricks(index: integer): TTetrisBrick;
begin
  Result := TTetrisBrick(BrickList.Items[index]);
end;

function TTetrisBoard.GetShapes(index: integer): TTetrisShape;
begin
  Result := TTetrisShape(ShapeList.Items[index]);
end;

procedure TTetrisBoard.InitOptions;
begin
  MainForm.Cursor := crNone;

  with fBoard.Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := clSilver;
    FillRect(ClientRect);
  end;

  fBoard.Canvas.Draw(BOARDXSIZE * BRICKSIZE + 2, 0, MainForm.OptionsImage.Picture.Graphic);
end;

procedure TTetrisBoard.HandleKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  gte: boolean;
begin
  if Key in [49..51] then
  begin
    Repaint;
    DrawWaitingShape;
  end;

  if Key = VK_H then
  begin
    gte := GameTimer.Enabled;
    GameTimer.Enabled := False;
    ShowHighScores;
    GameTimer.Enabled := gte;
  end
  else if Key = VK_F1 then
  begin
    gte := GameTimer.Enabled;
    GameTimer.Enabled := False;
    ShowHelp;
    GameTimer.Enabled := gte;
  end;

  if GameTimer.Enabled then
  begin
    case key of
      VK_RIGHT:
        if ShapeCanMoveRight then
          ActiveShape.IncreaseBoardX(1);
      VK_LEFT:
        if ShapeCanMoveLeft then
          ActiveShape.IncreaseBoardX(-1);
    end;
    if ShapeCanMoveDown then
    begin
      case key of
        VK_UP:
          if ActiveShape.BoardPoint.X + ActiveShape.FindBricksMax(ftYMax) <= BOARDXSIZE then
            ActiveShape.Rotate(1);
        VK_DOWN:
          ActiveShape.IncreaseBoardY(1);
        VK_SPACE:
          PlaceinBottom;
        VK_ESCAPE, VK_Q:
          begin
            GameTimer.Tag := Key;
            BoardShowMessage('Game Over');
            GameTimer.Enabled := False;
          end;
        VK_P:
          begin
            GameTimer.Tag := Key;
            BoardShowMessage('Paused');
            GameTimer.Enabled := False;
          end;
      end;
      DrawShapeEndPoint := CalcShapeEndPoint;
    end
    else
      PlaceShapeAtBoard;
  end
  else
  begin
    case key of
      VK_RETURN:
        begin
          case GameTimer.Tag of
            VK_P:
              begin
                ShowMessageFlag := False;
                GameTimer.Enabled := True;
              end;
            TAG_ENDGAME, VK_Q, VK_ESCAPE:
              begin
                GameTimer.Tag := TAG_INITSTART;
                Msg.Show('Game Start');
              end;
            TAG_RESTART:
              begin
                GameTimer.Enabled := True;
                ShowMessageFlag := False;
                ReStartGame;
              end;
            TAG_INITSTART:
              begin
                GameTimer.Enabled := True;
                ShowMessageFlag := False;
                StartGame;
              end;
          end;
        end;
      VK_ESCAPE, VK_Q:
        MainForm.Close;
    end;
  end;
  Repaint;
end;

procedure TTetrisBoard.OnMyTimer(Sender: TObject);
begin
  if ShapeCanMoveDown then
    ActiveShape.IncreaseBoardY(1)
  else
    PlaceShapeAtBoard;

  DrawShapeEndPoint := CalcShapeEndPoint;
  Repaint;
end;

procedure TTetrisBoard.Paint;
var
  i, j: integer;
  T: TRect;
begin
  Inherited;

  if ActiveShape = nil then Exit;
  with fBoard.Canvas do
  begin
    Pen.Color := RGB(100, 100, 100);
    Pen.Style := psClear;
    Brush.Color := RGB(105, 105, 105);

    for i := 0 to BOARDYSIZE - 1 do
      for j := 0 to BOARDXSIZE - 1 do
        Rectangle(j * BRICKSIZE, i * BRICKSIZE, (j + 1) * BRICKSIZE + 1, (i + 1) * BRICKSIZE + 1);

    // Painting the curretn moving shape;
    for i := 0 to  ActiveShape.BricksCount - 1 do
    begin
      T := Rect(ActiveShape.BoardPoint.X * BRICKSIZE + (ActiveShape.Bricks[i].Position.X - 1) * BRICKSIZE,
                ActiveShape.BoardPoint.Y * BRICKSIZE + (ActiveShape.Bricks[i].Position.Y - 1) * BRICKSIZE,
                ActiveShape.BoardPoint.X * BRICKSIZE + (ActiveShape.Bricks[i].Position.X - 1) * BRICKSIZE + BRICKSIZE + 1,
                ActiveShape.BoardPoint.Y * BRICKSIZE + (ActiveShape.Bricks[i].Position.Y - 1) * BRICKSIZE + BRICKSIZE + 1);

      ActiveShape.Bricks[i].DrawBrick(fBoard.Canvas, T);

      if DrawShapeEndPoint then
      begin
        T := Rect(ActiveShape.BoardPointInEnd.X * BRICKSIZE + (ActiveShape.Bricks[i].Position.X - 1) * BRICKSIZE,
                  ActiveShape.BoardPointInEnd.Y * BRICKSIZE + (ActiveShape.Bricks[i].Position.Y - 1) * BRICKSIZE,
                  ActiveShape.BoardPointInEnd.X * BRICKSIZE + (ActiveShape.Bricks[i].Position.X - 1) * BRICKSIZE + BRICKSIZE + 1,
                  ActiveShape.BoardPointInEnd.Y * BRICKSIZE + (ActiveShape.Bricks[i].Position.Y - 1) * BRICKSIZE + BRICKSIZE + 1);

        ActiveShape.Bricks[i].DrawBrickShadow(fBoard.Canvas, T, TipShapeDistance - BOARDSHAPETIPMAX);
      end;
    end;

    for i := 0 to BrickList.Count - 1 do
    begin
      T := Rect(Bricks[i].Position.X * BRICKSIZE,
                Bricks[i].Position.Y * BRICKSIZE,
                Bricks[i].Position.X * BRICKSIZE + BRICKSIZE + 1,
                Bricks[i].Position.Y * BRICKSIZE + BRICKSIZE + 1);

      Bricks[i].DrawBrick(fBoard.Canvas, T);
    end;


  end;

  if ShowMessageFlag then
    BitBlt(fBoard.Canvas.Handle, 10, 160, Msg.Width, Msg.Height, Msg.Canvas.Handle, 0, 0, SrcCopy);

  BitBlt(Canvas.Handle, 0, 0, Width, Height, fBoard.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TTetrisBoard.PlaceinBottom;
begin
  while ShapeCanMoveDown do
    ActiveShape.BoardPoint := Point(ActiveShape.BoardPoint.X, ActiveShape.BoardPoint.Y + 1);
  PlaceShapeAtBoard;
end;

procedure TTetrisBoard.PlaceShapeAtBoard;
var
  i: integer;
  P: TPoint;
begin
  if ActiveShape.BoardPoint.Y - ActiveShape.FindBricksMax(ftYMax) < 0 then
  begin
    if GameTimer.Tag <> TAG_ENDGAME then
    begin
      GameTimer.Tag := TAG_ENDGAME;
      if GameScore > 0 then
      begin
        fHighScores.Add(GetPlayerName(opt_PlayerName, GameLevel, GameScore), GameLevel, GameScore);
        ShowHighScores;
      end;
    end;
    BoardShowMessage('Game Over');
    GameTimer.Enabled := False;
    Exit;
  end;

  for i := 0 to ActiveShape.BricksCount - 1 do
  begin
    P := Point((ActiveShape.BoardPoint.X + ActiveShape.Bricks[i].Position.X - 1),
               (ActiveShape.BoardPoint.Y + ActiveShape.Bricks[i].Position.Y - 1));
    BrickList.Add(TTetrisBrick.Create(P, Ord(ActiveShape.ShapeType)));

    Positions[P.Y][P.X + 1] := '1';
  end;

  FindLinesAndDelete;
  SwitchNewShape;
end;

procedure TTetrisBoard.RestartGame;
var
  j: integer;
begin
  BrickList.Clear;

  GameLines := 0;
  GameLevel := 1;
  GameScore := 0;

  for j := 0 to BOARDYSIZE - 1 do
    Positions[j] := StringOfChar('0', BOARDXSIZE);

  DrawWaitingShape;
  DrawOptions;
  DrawShapeEndPoint := CalcShapeEndPoint;

  GameTimer.Tag := TAG_RESTART;
  GameTimer.Interval := 1000;
  Msg.Show('Restart Game');
end;

function TTetrisBoard.ShapeCanMoveDown: boolean;
var
  i, xBrick, yBrick: integer;
begin
  Result := True;
  if ActiveShape.FindBricksMax(ftYMax) - 1 + ActiveShape.BoardPoint.Y >= BOARDYSIZE - 1 then
  begin
    Result := False;
    Exit;
  end;

  for i := 0 to ActiveShape.BricksCount - 1 do
  begin
    yBrick := (ActiveShape.Bricks[i].Position.Y - 1) + (ActiveShape.BoardPoint.Y);
    xBrick := (ActiveShape.Bricks[i].Position.X - 1) + (ActiveShape.BoardPoint.X);

    if BoardShapes[xBrick, yBrick + 1] <> nil then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

function TTetrisBoard.ShapeCanMoveLeft: Boolean;
var
  i: integer;
  yBrick, xBrick: integer;
begin
  Result := True;
  if ActiveShape.BoardPoint.X = 0 then
  begin
    Result := False;
    Exit;
  end;

  for i := 0 to ActiveShape.BricksCount - 1 do
  begin
    xBrick := (ActiveShape.Bricks[i].Position.X - 1) + ActiveShape.BoardPoint.X;
    yBrick := (ActiveShape.Bricks[i].Position.Y - 1) + ActiveShape.BoardPoint.Y;

    if BoardShapes[xBrick - 1, yBrick] <> nil then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

function TTetrisBoard.ShapeCanMoveRight: Boolean;
var
  i: integer;
  yBrick, xBrick: integer;
begin
  Result := True;
  if ActiveShape.BoardPoint.X + ActiveShape.FindBricksMax(ftXMax) - 1 = BOARDXSIZE - 1 then
  begin
    Result := False;
    Exit;
  end;

  for i := 0 to ActiveShape.BricksCount - 1 do
  begin
    xBrick := (ActiveShape.Bricks[i].Position.X - 1) + ActiveShape.BoardPoint.X;
    yBrick := (ActiveShape.Bricks[i].Position.Y - 1) + ActiveShape.BoardPoint.Y;

    if BoardShapes[xBrick + 1, yBrick] <> nil then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

procedure TTetrisBoard.StartGame;
var
  j: integer;
begin
  BrickList.Clear;

  ShapeList.Clear;
  AddRandomShape;
  AddRandomShape;

  GameLines := 0;
  GameLevel := 1;
  GameScore := 0;

  for j := 0 to BOARDYSIZE - 1 do
    Positions[j] := StringOfChar('0', BOARDXSIZE);

  DrawWaitingShape;
  DrawOptions;
  DrawShapeEndPoint := CalcShapeEndPoint;

  GameTimer.Tag := TAG_RESTART;
  GameTimer.Interval := 1000;
  Msg.Show('Start Game');
end;

procedure TTetrisBoard.SwitchNewShape;
begin
  AddRandomShape;
  ShapeList.Delete(0);
  DrawWaitingShape;
  DrawOptions;
end;

function TTetrisBoard.WaitingShape: TTetrisShape;
begin
  Result := Shapes[1];
end;

end.

