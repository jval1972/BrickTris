unit frm_main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, bt_tetrisboard;

type
  TMainForm = class(TForm)
    ShapeMain: TShape;
    ShapeFade: TShape;
    LogoImage: TImage;
    OptionsImage: TImage;
    ShapeLogo: TShape;
    HiScoreImage: TImage;
    HiScoresImage: TImage;
    HelpImage: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR;
  public
    TetrisBoard: TTetrisBoard;
    BrickBM: TBitmap;
    ThemeIndex: integer;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  bt_defs, bt_utils;

procedure MakeBrickSlice(const bm: TBitmap; const c1, c2, c3: TColorRef; const leftoffs: integer);
var
  l: integer;
begin
  bm.Canvas.Pen.Style := psSolid;
  bm.Canvas.Brush.Style := bsSolid;

  l := leftoffs;
  bm.Canvas.Pen.Color := c1;
  bm.Canvas.Brush.Color := c1;
  bm.Canvas.FillRect(Rect(l, 0, l + 25, 75));

  bm.Canvas.Pen.Color := c3;
  bm.Canvas.Brush.Color := c3;
  bm.Canvas.Ellipse(l + 7, 7, l + 23, 23);
  bm.Canvas.Ellipse(l + 7, 32, l + 23, 48);
  bm.Canvas.Ellipse(l + 7, 57, l + 23, 73);

  bm.Canvas.Pen.Color := c2;
  bm.Canvas.Brush.Color := c1;
  bm.Canvas.Ellipse(l + 5, 5, l + 21, 21);
  bm.Canvas.Ellipse(l + 5, 30, l + 21, 46);
  bm.Canvas.Ellipse(l + 5, 55, l + 21, 71);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  HideFormCursor(self);

  BrickBM := TBitmap.Create;
  BrickBM.Width := 300;
  BrickBM.Height := 75;
  BrickBM.PixelFormat := pf24Bit;
  MakeBrickSlice(BrickBM, RGB(200, 32, 0), RGB(236, 63, 32), RGB(146, 20, 0), 0);
  MakeBrickSlice(BrickBM, RGB(0, 88, 189), RGB(0, 140, 226), RGB(0, 51, 117), 25);
  MakeBrickSlice(BrickBM, RGB(0, 144, 57), RGB(10, 180, 86), RGB(0, 86, 34), 50);
  MakeBrickSlice(BrickBM, RGB(232, 232, 232), RGB(255, 255, 255), RGB(192, 192, 192), 75);
  MakeBrickSlice(BrickBM, RGB(164, 54, 145), RGB(192, 85, 175), RGB(72, 21, 54), 100);
  MakeBrickSlice(BrickBM, RGB(255, 245, 25), RGB(255, 255, 40), RGB(235, 176, 15), 125);
  MakeBrickSlice(BrickBM, RGB(231, 107, 0), RGB(242, 123, 12), RGB(198, 60, 0), 150);
  MakeBrickSlice(BrickBM, RGB(115, 34, 11), RGB(153, 79, 49), RGB(69, 21, 7), 175);
  MakeBrickSlice(BrickBM, RGB(180, 225, 50), RGB(203, 246, 63), RGB(147, 184, 43), 200);
  MakeBrickSlice(BrickBM, RGB(160, 161, 153), RGB(184, 185, 178), RGB(114, 114, 105), 225);
  MakeBrickSlice(BrickBM, RGB(44, 44, 44), RGB(66, 66, 66), RGB(0, 0, 0), 250);
  MakeBrickSlice(BrickBM, RGB(217, 187, 123), RGB(232, 208, 144), RGB(192, 168, 112), 275);

  DoubleBuffered := True;

  bt_LoadSettingFromFile(ChangeFileExt(ParamStr(0), '.ini'));

  TetrisBoard := TTetrisBoard.Create(self);
  TetrisBoard.Parent := Self;

  Width := Screen.Width;
  Height := Screen.Height;

  BorderStyle := bsNone;

  WindowState := wsMaximized;

  TetrisBoard.Left := (Screen.Width div 2) - (TetrisBoard.Width div 2);
  TetrisBoard.Top := (Screen.Height div 2) - (TetrisBoard.Height div 2) + (TetrisBoard.Height div 16) ;

  ShapeMain.Width := TetrisBoard.Width  + ShapeMain.Pen.Width * 2;
  ShapeMain.Height := TetrisBoard.Height + ShapeMain.Pen.Width * 2;
  ShapeMain.Top := TetrisBoard.Top - ShapeMain.Pen.Width;
  ShapeMain.Left := TetrisBoard.Left - ShapeMain.Pen.Width;

  ShapeLogo.Left := ShapeMain.Left;
  ShapeLogo.Height := LogoImage.Height + ShapeLogo.Pen.Width * 2;
  ShapeLogo.Top := ShapeMain.Top - ShapeLogo.Height + ShapeLogo.Pen.Width;
  ShapeLogo.Width := ShapeMain.Width;

  ShapeFade.Left := ShapeMain.Left + 5;
  ShapeFade.Top := ShapeLogo.Top + 5;
  ShapeFade.Width := ShapeMain.Width;
  ShapeFade.Height := ShapeMain.Height + ShapeLogo.Height - ShapeLogo.Pen.Width;

  LogoImage.Top := ShapeLogo.Top + ShapeLogo.Pen.Width;
  LogoImage.Left := (Screen.Width div 2) - (LogoImage.Width div 2);
  LogoImage.BringToFront;

  ThemeIndex := 0;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    49: ThemeIndex := 0;
    50: ThemeIndex := 1;
    51: ThemeIndex := 2;
  end;
  TetrisBoard.HandleKeyDown(Sender, Key, Shift);
end;

procedure TMainForm.Memo1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  OnKeyDown(Sender,Key,Shift);
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  TetrisBoard.StartGame;
end;

procedure TMainForm.FormPaint(Sender: TObject);
var
  x, y: integer;
begin
  y := 0;
  while y < Height do
  begin
    x := 0;
    while x < Width do
    begin
      Canvas.Draw(x, y, BrickBM);
      x := x + BrickBM.Width;
    end;
    y := y + BrickBM.Height;
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  BrickBM.Free;
  bt_SaveSettingsToFile(ChangeFileExt(ParamStr(0), '.ini'));
end;

procedure TMainForm.WMSetCursor(var Msg: TWMSetCursor);
begin
  SetCursor(Screen.Cursors[crNone]);
  Msg.Result := 1;
end;

end.

