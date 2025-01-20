unit uGlobal;

interface

uses
   Winapi.Windows, System.SysUtils, Vcl.Forms, Winapi.ShellAPI, System.Variants, System.RegularExpressions;

function ShellExecuteAndWait(AHandle: HWND; Operation, FileName, Parameter, Directory: String; Show: Word; bWait: Boolean): Longint;
function removeSpaces(variante:Variant):string;

// var

implementation

// uses

function ShellExecuteAndWait(AHandle: HWND; Operation, FileName, Parameter, Directory: String; Show: Word; bWait: Boolean): Longint;
var
  bOK: Boolean;
  Info: TShellExecuteInfo;
begin
  FillChar(Info, SizeOf(Info), Chr(0));
  Info.cbSize := SizeOf(Info);
  Info.fMask := SEE_MASK_NOCLOSEPROCESS;
  Info.lpVerb := PChar(Operation);
  Info.lpFile := PChar(FileName);
  Info.Wnd := AHandle;
  Info.lpParameters := PChar(Parameter);
  Info.lpDirectory := PChar(Directory);
  Info.nShow := Show;
  bOK := Boolean(ShellExecuteEx(@Info));
  if bOK then
  begin
    if bWait then
    begin
      while WaitForSingleObject(Info.hProcess, 100) = WAIT_TIMEOUT do
        Application.ProcessMessages;
      bOK := GetExitCodeProcess(Info.hProcess, DWORD(Result));
    end
    else
      Result := 0;
  end;
  if not bOK then
    Result := -1;
end;

function removeSpaces(variante:Variant):string;
var s1, s2:string;
begin
   s1 := '';
   if variante = null then
   begin
      Result := s1;
      Exit;
   end;
   s2 := StringReplace(variante, Chr(9),' ',[rfReplaceAll]);
   s1 := Trim(TRegEx.Replace(s2,'\s{2,}',' '));
   Result := s1;
end;

end.
