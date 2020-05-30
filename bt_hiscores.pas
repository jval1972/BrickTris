unit bt_hiscores;

interface

uses
  bt_sha1;

const
  NUMHIGHSCORES = 16;

type
  highscore_t = record
    name: string[16];
    score: integer;
    level: integer;
    date: TDateTime;
    sha1: string[SizeOf(T160BitDigest)];
  end;
  highscore_p = ^highscore_t;

  highscoretable_t = array[0..NUMHIGHSCORES - 1] of highscore_t;

  THighScoreTable = class(TObject)
  private
    fscores: highscoretable_t;
    ffilename: string;
    function CalcItemSHA1(const id: integer): string;
    procedure CheckItemSHA1(const id: integer);
    procedure SortScores;
  public
    constructor Create(const afilename: string); virtual;
    destructor Destroy; override;
    function Add(const aname: string; const alevel: integer; const ascore: integer): boolean;
    property scores: highscoretable_t read fscores;
  end;

implementation

uses
  Windows, Classes, SysUtils;

constructor THighScoreTable.Create(const afilename: string);
var
  i: integer;
begin
  ZeroMemory(@fscores, SizeOf(highscoretable_t));
  for i := 0 to NUMHIGHSCORES - 1 do
    fscores[i].sha1 := CalcItemSHA1(i);
  ffilename := afilename;
  if FileExists(ffilename) then
  begin
    with TFileStream.Create(ffilename, fmOpenRead) do
    begin
      try
        Read(fscores, SizeOf(highscoretable_t));
      finally
        Free;
      end;
    end;
    for i := 0 to NUMHIGHSCORES - 1 do
      CheckItemSHA1(i);
    SortScores;
  end;
end;

destructor THighScoreTable.Destroy;
begin
  with TFileStream.Create(ffilename, fmCreate) do
  begin
    try
      Write(fscores, SizeOf(highscoretable_t));
    finally
      Free;
    end;
  end;
end;

function THighScoreTable.CalcItemSHA1(const id: integer): string;
begin
  Result := SHA1DigestAsString(CalcSHA1Buf(fscores[id], integer(@(highscore_p(0)^.sha1))));
end;

procedure THighScoreTable.CheckItemSHA1(const id: integer);
begin
  if CalcItemSHA1(id) <> fscores[id].sha1 then
  begin
    ZeroMemory(@fscores[id], SizeOf(highscore_t));
    fscores[id].sha1 := CalcItemSHA1(id);
  end;
end;

procedure THighScoreTable.SortScores;
  function compare(ii, jj: integer): double;
  begin
    if fscores[ii].score <> fscores[jj].score then
      Result := fscores[ii].score - fscores[jj].score
    else if fscores[ii].level <> fscores[jj].level then
      Result := fscores[ii].level - fscores[jj].level
    else
      Result := fscores[jj].date - fscores[ii].date;
  end;
var
  i, j: integer;
  t: highscore_t;
begin
  for i := 0 to NUMHIGHSCORES - 2 do
    for j := NUMHIGHSCORES - 1 downto i + 1 do
      if compare(i, j) < 0.0 then
      begin
        t := fscores[i];
        fscores[i] := fscores[j];
        fscores[j] := t;
      end;
end;

function THighScoreTable.Add(const aname: string; const alevel: integer; const ascore: integer): boolean;
begin
  SortScores;
  if (ascore > fscores[NUMHIGHSCORES - 1].score) or
     ((ascore = fscores[NUMHIGHSCORES - 1].score) and (alevel > fscores[NUMHIGHSCORES - 1].level)) then
  begin
    fscores[NUMHIGHSCORES - 1].name := UpperCase(aname);
    fscores[NUMHIGHSCORES - 1].score := ascore;
    fscores[NUMHIGHSCORES - 1].level := alevel;
    fscores[NUMHIGHSCORES - 1].date := Now;
    fscores[NUMHIGHSCORES - 1].sha1 := CalcItemSHA1(NUMHIGHSCORES - 1);
    SortScores;
    Result := True;
  end
  else
    Result := False;
end;

end.
