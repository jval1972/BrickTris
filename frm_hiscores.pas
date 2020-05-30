unit frm_hiscores;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  THighScoresForm = class(TForm)
    Panel1: TPanel;
    PaintBox1: TPaintBox;
    OKButton: TButton;
    CancelButton: TButton;
    PositionLabel1: TLabel;
    PositionLabel2: TLabel;
    PositionLabel3: TLabel;
    PositionLabel4: TLabel;
    PositionLabel5: TLabel;
    PositionLabel6: TLabel;
    PositionLabel7: TLabel;
    PositionLabel8: TLabel;
    PositionLabel9: TLabel;
    PositionLabel10: TLabel;
    PositionLabel11: TLabel;
    PositionLabel12: TLabel;
    PositionLabel13: TLabel;
    PositionLabel14: TLabel;
    PositionLabel15: TLabel;
    PositionLabel16: TLabel;
    PlayerLabelH: TLabel;
    PlayerLabel1: TLabel;
    PlayerLabel2: TLabel;
    PlayerLabel3: TLabel;
    PlayerLabel4: TLabel;
    PlayerLabel5: TLabel;
    PlayerLabel6: TLabel;
    PlayerLabel7: TLabel;
    PlayerLabel8: TLabel;
    PlayerLabel9: TLabel;
    PlayerLabel10: TLabel;
    PlayerLabel11: TLabel;
    PlayerLabel12: TLabel;
    PlayerLabel13: TLabel;
    PlayerLabel14: TLabel;
    PlayerLabel15: TLabel;
    PlayerLabel16: TLabel;
    DateLabelH: TLabel;
    DateLabel1: TLabel;
    DateLabel2: TLabel;
    DateLabel3: TLabel;
    DateLabel4: TLabel;
    DateLabel5: TLabel;
    DateLabel6: TLabel;
    DateLabel7: TLabel;
    DateLabel8: TLabel;
    DateLabel9: TLabel;
    DateLabel10: TLabel;
    DateLabel11: TLabel;
    DateLabel12: TLabel;
    DateLabel13: TLabel;
    DateLabel14: TLabel;
    DateLabel15: TLabel;
    DateLabel16: TLabel;
    LevelLabelH: TLabel;
    LevelLabel1: TLabel;
    LevelLabel2: TLabel;
    LevelLabel3: TLabel;
    LevelLabel4: TLabel;
    LevelLabel5: TLabel;
    LevelLabel6: TLabel;
    LevelLabel7: TLabel;
    LevelLabel8: TLabel;
    LevelLabel9: TLabel;
    LevelLabel10: TLabel;
    LevelLabel11: TLabel;
    LevelLabel12: TLabel;
    LevelLabel13: TLabel;
    LevelLabel14: TLabel;
    LevelLabel15: TLabel;
    LevelLabel16: TLabel;
    ScoreLabelH: TLabel;
    ScoreLabel1: TLabel;
    ScoreLabel2: TLabel;
    ScoreLabel3: TLabel;
    ScoreLabel4: TLabel;
    ScoreLabel5: TLabel;
    ScoreLabel6: TLabel;
    ScoreLabel7: TLabel;
    ScoreLabel8: TLabel;
    ScoreLabel9: TLabel;
    ScoreLabel10: TLabel;
    ScoreLabel11: TLabel;
    ScoreLabel12: TLabel;
    ScoreLabel13: TLabel;
    ScoreLabel14: TLabel;
    ScoreLabel15: TLabel;
    ScoreLabel16: TLabel;
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ShowHighScores;

implementation

{$R *.dfm}

uses
  frm_main,
  bt_utils,
  bt_hiscores;

procedure ShowHighScores;
var
  f: THighScoresForm;
begin
  f := THighScoresForm.Create(nil);
  try
    f.ShowModal;
  finally
    f.Free;
  end;
end;

procedure THighScoresForm.PaintBox1Paint(Sender: TObject);
begin
  PaintBoxDrawCenterGraphic(PaintBox1, MainForm.HiScoresImage.Picture.Graphic);
end;

procedure THighScoresForm.FormCreate(Sender: TObject);
var
  LABELS: array[0..NUMHIGHSCORES - 1, 0..3] of TLabel;
  scores: highscoretable_t;
  i: integer;
begin
  HideFormCursor(self);

  LABELS[0, 0] := PlayerLabel1;
  LABELS[1, 0] := PlayerLabel2;
  LABELS[2, 0] := PlayerLabel3;
  LABELS[3, 0] := PlayerLabel4;
  LABELS[4, 0] := PlayerLabel5;
  LABELS[5, 0] := PlayerLabel6;
  LABELS[6, 0] := PlayerLabel7;
  LABELS[7, 0] := PlayerLabel8;
  LABELS[8, 0] := PlayerLabel9;
  LABELS[9, 0] := PlayerLabel10;
  LABELS[10, 0] := PlayerLabel11;
  LABELS[11, 0] := PlayerLabel12;
  LABELS[12, 0] := PlayerLabel13;
  LABELS[13, 0] := PlayerLabel14;
  LABELS[14, 0] := PlayerLabel15;
  LABELS[15, 0] := PlayerLabel16;

  LABELS[0, 1] := DateLabel1;
  LABELS[1, 1] := DateLabel2;
  LABELS[2, 1] := DateLabel3;
  LABELS[3, 1] := DateLabel4;
  LABELS[4, 1] := DateLabel5;
  LABELS[5, 1] := DateLabel6;
  LABELS[6, 1] := DateLabel7;
  LABELS[7, 1] := DateLabel8;
  LABELS[8, 1] := DateLabel9;
  LABELS[9, 1] := DateLabel10;
  LABELS[10, 1] := DateLabel11;
  LABELS[11, 1] := DateLabel12;
  LABELS[12, 1] := DateLabel13;
  LABELS[13, 1] := DateLabel14;
  LABELS[14, 1] := DateLabel15;
  LABELS[15, 1] := DateLabel16;

  LABELS[0, 2] := LevelLabel1;
  LABELS[1, 2] := LevelLabel2;
  LABELS[2, 2] := LevelLabel3;
  LABELS[3, 2] := LevelLabel4;
  LABELS[4, 2] := LevelLabel5;
  LABELS[5, 2] := LevelLabel6;
  LABELS[6, 2] := LevelLabel7;
  LABELS[7, 2] := LevelLabel8;
  LABELS[8, 2] := LevelLabel9;
  LABELS[9, 2] := LevelLabel10;
  LABELS[10, 2] := LevelLabel11;
  LABELS[11, 2] := LevelLabel12;
  LABELS[12, 2] := LevelLabel13;
  LABELS[13, 2] := LevelLabel14;
  LABELS[14, 2] := LevelLabel15;
  LABELS[15, 2] := LevelLabel16;

  LABELS[0, 3] := ScoreLabel1;
  LABELS[1, 3] := ScoreLabel2;
  LABELS[2, 3] := ScoreLabel3;
  LABELS[3, 3] := ScoreLabel4;
  LABELS[4, 3] := ScoreLabel5;
  LABELS[5, 3] := ScoreLabel6;
  LABELS[6, 3] := ScoreLabel7;
  LABELS[7, 3] := ScoreLabel8;
  LABELS[8, 3] := ScoreLabel9;
  LABELS[9, 3] := ScoreLabel10;
  LABELS[10, 3] := ScoreLabel11;
  LABELS[11, 3] := ScoreLabel12;
  LABELS[12, 3] := ScoreLabel13;
  LABELS[13, 3] := ScoreLabel14;
  LABELS[14, 3] := ScoreLabel15;
  LABELS[15, 3] := ScoreLabel16;

  scores := MainForm.TetrisBoard.HighScores.scores;

  for i := 0 to NUMHIGHSCORES - 1 do
  begin
    if Length(scores[i].name) > 0 then
      LABELS[i, 0].Caption := scores[i].name
    else
      LABELS[i, 0].Caption := '-';

    if scores[i].date > 1.0 then
      LABELS[i, 1].Caption := formatdatetime('ddddd', scores[i].date)
    else
      LABELS[i, 1].Caption := '-';

    if scores[i].level > 0 then
      LABELS[i, 2].Caption := IntToStr(scores[i].level)
    else
      LABELS[i, 2].Caption := '-';

    if scores[i].score > 0 then
      LABELS[i, 3].Caption := IntToStr(scores[i].score)
    else
      LABELS[i, 3].Caption := '-';
  end;
end;

end.
