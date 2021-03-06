// tar_urlcompleter 1.1 - ������ ��������-������ �����������, �������� http:// � ������
// Copyright � Evgeniy Galantsev 2003-2005

library tar_urlcompleter;

uses Windows, Messages, avl;

type
	TInfo=record
  	size: integer; // ������ ���������
  	plugin: PChar; // ����������� ������ 'Hello! I am the TypeAndRun plugin.' - ��� ����������� �������
		name: PChar; // �������� �������
		version: PChar; // ��� ������
    description: PChar; // ������� �������� ����������������
    author: PChar; // ����� �������
    copyright: PChar; // ����� �� ������
    homepage: PChar; // �������� �������� �������
  end;
  TExec=record
  	size: integer; // ������ ���������
    run: integer; // ����������, ����������� �� ������
    con_text: PChar; // ���� ���� ���������� ����� � �������
    con_sel_start: integer; // ������ ��������� ������ � �������
    con_sel_length: integer; // ����� ���������
  end;

var
  DllFileName: Array[0..MAX_PATH] of Char; // ���� � dll'��� - ����� ��� ����������� �����, ��� ������� ���������
	Domains: TStringList;
  ConsoleHWND: HWND;

// ����������� ��� �������� dll
// WinHWND - ����� �������� ����
procedure Load(WinHWND: HWND); cdecl;
var
	tmp: string;
begin
  ConsoleHWND:=WinHWND;
  GetModuleFileName(HInstance, DllFileName, MAX_PATH); // ��������� ������ ���� � tar_math.dll
  tmp:=DllFileName;
	Domains:=TStringList.Create;
  Domains.LoadFromFile(ExtractFilePath(tmp)+'\domains.txt');
end;
exports Load;

// ����������� ��� �������� dll
procedure Unload; cdecl;
begin
  Domains.Free;
end;
exports Unload;

// �������� ��� �������������� dll � �������� TypeAndRun
// � ������� ���������� � �������
function GetInfo: TInfo; cdecl;
var
	info: TInfo;
begin
	info.size:=SizeOf(TInfo);
	info.plugin:='Hello! I am the TypeAndRun plugin.';
	info.name:='tar_urlcompleter';
	info.version:='1.1';
  info.description:='Complete URL''s running without http://'+#13+'For sample: ghisler.com';
	info.author:='Evgeniy Galantsev (-=GaLaN=-)';
  info.copyright:='Copyright � Evgeniy Galantsev 2003-2005';
  info.homepage:='http://galanc.com/';
	Result:=info;
end;
exports GetInfo;

// �������� ����� ����
// WinHandle - ����� ����
// txtText - ���������� ������
procedure SendText(WinHandle: HWND; txtText: string);
var
	Data: TCopyDataStruct;
	s: string;
begin
  s:=txtText;
  Data.dwData := 0;
  Data.cbData := Length(s);
  Data.lpData := @s[1];
  SendMessage(WinHandle, WM_COPYDATA, 0, integer(@Data));
end;

// ��������� ����������� �������
function CheckDomains(str: string): boolean;
var
	i: integer;
  tmpD: string;
begin
	Result:=False;
  if Pos(' ', str)<>0 then exit;
  if Pos(':\', str)<>0 then exit;
  for i:=0 to Domains.Count-1 do begin
	  tmpD:=Domains.Strings[i];
  	if tmpD<>'' then begin
      if Pos(tmpD, str)<>0 then begin
        SendText(ConsoleHWND, 'http://'+str);
        Result:=True;
        Break;
      end;
    end;
  end;
end;

// ������ ������ � ������� ������� - ����������, ������ �� ������ � ������, ������������ � �������
// str - ����������� ������
function RunString(str: PChar): TExec; cdecl;
var
  exec: TExec;
begin
  // ������������� ������������ ���������
  exec.size:=SizeOf(TExec);
	exec.run:=0;
  exec.con_text:='';
  exec.con_sel_start:=0;
  exec.con_sel_length:=0;
	if CheckDomains(str) then exec.run:=1;
  Result:=exec;
end;
exports RunString;

end.
