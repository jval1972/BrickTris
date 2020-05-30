unit frm_help;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  THelpForm = class(TForm)
    Panel1: TPanel;
    PaintBox1: TPaintBox;
    OKButton: TButton;
    CancelButton: TButton;
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ShowHelp;

implementation

{$R *.dfm}

uses
  frm_main,
  bt_utils;

procedure ShowHelp;
var
  f: THelpForm;
begin
  f := THelpForm.Create(nil);
  try
    f.ShowModal;
  finally
    f.Free;
  end;
end;

procedure THelpForm.PaintBox1Paint(Sender: TObject);
begin
  PaintBoxDrawCenterGraphic(PaintBox1, MainForm.HelpImage.Picture.Graphic);
end;

procedure THelpForm.FormCreate(Sender: TObject);
begin
  HideFormCursor(self);
end;

end.
