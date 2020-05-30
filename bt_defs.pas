unit bt_defs;

interface

function bt_LoadSettingFromFile(const fn: string): boolean;

procedure bt_SaveSettingsToFile(const fn: string);

const
  MAXHISTORYPATH = 2048;

type
  bigstring_t = array[0..MAXHISTORYPATH - 1] of char;
  bigstring_p = ^bigstring_t;

var
  opt_PlayerName: string = 'PLAYER1';

function bigstringtostring(const bs: bigstring_p): string;

procedure stringtobigstring(const src: string; const bs: bigstring_p);

implementation

uses
  SysUtils, Classes;

const
  NUMSETTINGS = 2;

type
  TSettingsType = (tstDevider, tstInteger, tstBoolean, tstString, tstBigString);

  TSettingItem = record
    desc: string;
    typeof: TSettingsType;
    location: pointer;
  end;

var
  Settings: array[0..NUMSETTINGS - 1] of TSettingItem = (
    (
      desc: '[BRICKTRIS]';
      typeof: tstDevider;
      location: nil;
    ),
    (
      desc: 'PLAYERNAME';
      typeof: tstString;
      location: @opt_PlayerName;
    )
  );


procedure splitstring(const inp: string; var out1, out2: string; const splitter: string = ' ');
var
  p: integer;
begin
  p := Pos(splitter, inp);
  if p = 0 then
  begin
    out1 := inp;
    out2 := '';
  end
  else
  begin
    out1 := Trim(Copy(inp, 1, p - 1));
    out2 := Trim(Copy(inp, p + 1, Length(inp) - p));
  end;
end;

function IntToBool(const x: integer): boolean;
begin
  Result := x <> 0;
end;

function BoolToInt(const b: boolean): integer;
begin
  if b then
    Result := 1
  else
    Result := 0;
end;

function bigstringtostring(const bs: bigstring_p): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to MAXHISTORYPATH - 1 do
    if bs[i] = #0 then
      Exit
    else
      Result := Result + bs[i];
end;

procedure stringtobigstring(const src: string; const bs: bigstring_p);
var
  i: integer;
begin
  for i := 0 to MAXHISTORYPATH - 1 do
    bs[i] := #0;

  for i := 1 to Length(src) do
  begin
    bs[i - 1] := src[i];
    if i = MAXHISTORYPATH then
      Exit;
  end;
end;

procedure bt_SaveSettingsToFile(const fn: string);
var
  s: TStringList;
  i: integer;
begin
  s := TStringList.Create;
  try
    for i := 0 to NUMSETTINGS - 1 do
    begin
      if Settings[i].typeof = tstInteger then
        s.Add(Format('%s=%d', [Settings[i].desc, PInteger(Settings[i].location)^]))
      else if Settings[i].typeof = tstBoolean then
        s.Add(Format('%s=%d', [Settings[i].desc, BoolToInt(PBoolean(Settings[i].location)^)]))
      else if Settings[i].typeof = tstBigString then
        s.Add(Format('%s=%s', [Settings[i].desc, bigstringtostring(bigstring_p(Settings[i].location))]))
      else if Settings[i].typeof = tstString then
        s.Add(Format('%s=%s', [Settings[i].desc, PString(Settings[i].location)^]))
      else if Settings[i].typeof = tstDevider then
      begin
        if s.Count > 0 then
          s.Add('');
        s.Add(Settings[i].desc);
      end;
    end;
    s.SaveToFile(fn);
  finally
    s.Free;
  end;
end;

function bt_LoadSettingFromFile(const fn: string): boolean;
var
  s: TStringList;
  i, j: integer;
  s1, s2: string;
  itmp: integer;
begin
  if not FileExists(fn) then
  begin
    result := false;
    exit;
  end;
  result := true;

  s := TStringList.Create;
  try
    s.LoadFromFile(fn);
    begin
      for i := 0 to s.Count - 1 do
      begin
        splitstring(s.Strings[i], s1, s2, '=');
        if s2 <> '' then
        begin
          s1 := UpperCase(s1);
          for j := 0 to NUMSETTINGS - 1 do
            if UpperCase(Settings[j].desc) = s1 then
            begin
              if Settings[j].typeof = tstInteger then
              begin
                itmp := StrToIntDef(s2, PInteger(Settings[j].location)^);
                PInteger(Settings[j].location)^ := itmp;
              end
              else if Settings[j].typeof = tstBoolean then
              begin
                itmp := StrToIntDef(s2, BoolToInt(PBoolean(Settings[j].location)^));
                PBoolean(Settings[j].location)^ := IntToBool(itmp);
              end
              else if Settings[j].typeof = tstString then
              begin
                PString(Settings[j].location)^ := s2;
              end
              else if Settings[j].typeof = tstBigString then
              begin
                stringtobigstring(s2, bigstring_p(Settings[j].location));
              end;
            end;
        end;
      end;
    end;
  finally
    s.Free;
  end;

end;

end.

