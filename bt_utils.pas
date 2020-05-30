unit bt_utils;

interface

uses
  Forms, Controls, ExtCtrls, Graphics;

procedure PaintBoxDrawCenterGraphic(const P: TPaintBox; const G: TGraphic);

procedure HideFormCursor(const frm: TForm);

implementation

procedure PaintBoxDrawCenterGraphic(const P: TPaintBox; const G: TGraphic);
var
  l, t: integer;
begin
  l := (P.Width - G.Width) div 2;
  t := (P.Height - G.Height) div 2;
  P.Canvas.Draw(l, t, G);
end;

procedure HideFormCursor(const frm: TForm);
var
  i: integer;
begin
  frm.Cursor := crNone;
  for i := 0 to frm.ComponentCount - 1 do
    if frm.Components[i].InheritsFrom(TControl) then
      TControl(frm.Components[i]).Cursor := crNone;
end;

end.
