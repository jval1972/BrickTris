unit bt_messages;

interface

uses
  Classes, Windows, Graphics, SysUtils;

type
  TBoardMessage = class(TObject)
  private
    bm: TBitmap;
    fMessage: string;
  protected
    procedure Paint;
    function GetCanvas: TCanvas;
    function GetWidth: integer;
    function GetHeight: integer;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Show(const s: string);
    property Canvas: TCanvas read GetCanvas;
    property Width: integer read GetWidth;
    property Height: integer read GetHeight;
 end;

implementation

{ TMsg }

constructor TBoardMessage.Create(AOwner: TComponent);
begin
  bm := TBitmap.Create;
  bm.Width := 220;
  bm.Height := 120;
end;

destructor TBoardMessage.Destroy;
begin
  bm.Free;
  inherited;
end;

function TBoardMessage.GetCanvas: TCanvas;
begin
  Result := bm.Canvas;
end;

function TBoardMessage.GetHeight: integer;
begin
  Result := bm.Height;
end;

function TBoardMessage.GetWidth: integer;
begin
  Result := bm.Width;
end;

procedure TBoardMessage.Paint;
var
  w: integer;
begin
  with bm.Canvas do
  begin
    Brush.Color := clRed;
    Pen.Width := 3;
    Pen.Color := clBlack;
    Pen.Style := psSolid;

    brush.Color := RGB(80, 80, 80);
    Rectangle(0, 0, bm.Width, bm.Height);

    Font.Name := 'Tahoma';
    Font.Size := 22;
    Font.Color := clSilver;

    w := (bm.Width div 2) - ((Length(fMessage) * (Font.Size div 2) + (Font.Size div 4) * 8 + (Font.Size div 8) * 8) div 2);
    TextOut(w, 5, fMessage);

    Font.Size := 18;
    Font.Color := clGray;

    fMessage := 'Press Enter';
    w := (bm.Width div 2) - ((Length(fMessage) * (Font.Size div 2) + (Font.Size div 4) * 6 + (Font.Size div 8) * 6) div 2);
    TextOut(w, 70, fMessage);
  end;
end;

procedure TBoardMessage.Show(const s: String);
begin
  fMessage := s;
  Paint;
end;

end.
