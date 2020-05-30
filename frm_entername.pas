unit frm_entername;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TEnterNameForm = class(TForm)
    Panel1: TPanel;
    PaintBox1: TPaintBox;
    Label1: TLabel;
    NameEdit: TEdit;
    OKButton: TButton;
    CancelButton: TButton;
    Label2: TLabel;
    ScoreLabel: TLabel;
    LevelLabel: TLabel;
    Label4: TLabel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function GetPlayerName(var defname: string; const alevel, ascore: integer): string;

implementation

{$R *.dfm}

uses
  frm_main,
  bt_utils;

function GetPlayerName(var defname: string; const alevel, ascore: integer): string;
var
  f: TEnterNameForm;
begin
  f := TEnterNameForm.Create(nil);
  try
    f.NameEdit.Text := UpperCase(defname);
    f.LevelLabel.Caption := IntToStr(alevel);
    f.ScoreLabel.Caption := IntToStr(ascore);
    f.ShowModal;
    if f.ModalResult = mrOK then
      defname := UpperCase(Trim(f.NameEdit.Text));
    Result := defname;
  finally
    f.Free;
  end;
end;

procedure TEnterNameForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ModalResult = mrOK then
    CanClose := Trim(NameEdit.Text) <> ''
  else
    CanClose := True;
end;

procedure TEnterNameForm.PaintBox1Paint(Sender: TObject);
begin
  PaintBoxDrawCenterGraphic(PaintBox1, MainForm.HiScoreImage.Picture.Graphic);
end;

procedure TEnterNameForm.FormCreate(Sender: TObject);
begin
  HideFormCursor(self);
  NameEdit.Text := '';
end;

end.
