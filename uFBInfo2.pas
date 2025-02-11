unit uFBInfo2;

interface

uses
   Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
   Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
   Data.DB, StrUtils, Vcl.ExtCtrls, System.IniFiles,
   System.ImageList, Vcl.ImgList, Vcl.Buttons, FireDAC.Stan.Intf,
   FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
   FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
   FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait, FireDAC.Comp.UI, FireDAC.Phys.IBBase,
   FireDAC.Phys.FB, FireDAC.Comp.Client, FireDAC.Phys.IBWrapper, Winapi.ShellAPI;

type
   TfrmFBInfo2 = class(TForm)
      OpenDialog1: TOpenDialog;
      btnBrowse: TButton;
      Label1: TLabel;
      Label2: TLabel;
      lblFBserver: TLabel;
      Label3: TLabel;
      lblODS: TLabel;
      Label4: TLabel;
      lblFBv: TLabel;
      lblPort: TLabel;
      lblPS: TLabel;
      Label5: TLabel;
      lblSqlDialect: TLabel;
      edtBD: TEdit;
      Label6: TLabel;
      Label7: TLabel;
      Panel1: TPanel;
      Label8: TLabel;
      Label9: TLabel;
      Label10: TLabel;
      edtFB15: TEdit;
      edtFB25: TEdit;
      Label11: TLabel;
      Label12: TLabel;
      btnEdit: TButton;
      btnCancel: TButton;
      edtFB30: TEdit;
    edtFB50: TEdit;
      ImageList1: TImageList;
      btn_ptBR: TSpeedButton;
      btn_en: TSpeedButton;
      FDConnection1: TFDConnection;
      FDPhysFBDriverLink1: TFDPhysFBDriverLink;
      FDGUIxWaitCursor1: TFDGUIxWaitCursor;
      FDIBInfo1: TFDIBInfo;
      lblFBPath: TLabel;
      Memo1: TMemo;
      procedure btnBrowseClick(Sender: TObject);
      procedure conectParams();
      function verifySpaces(path:string) : string;
      procedure clean();
      procedure SetIniValue(pLocal, pSession, pSubSession, pValue:string);
      function GetIniValue(pLocal, PSession, pSubSession:string):string;
      procedure FormActivate(Sender: TObject);
      procedure btnEditClick(Sender: TObject);
      procedure btnCancelClick(Sender: TObject);
      procedure loadConfigINI();
      procedure EdtReadOnly(state:Boolean);
      procedure btn_ptBRClick(Sender: TObject);
      procedure btn_enClick(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
   end;

var
   frmFBInfo2: TfrmFBInfo2;
   iniconf: TIniFile;
   port: array[0..3] of string = ('','','','');
   SoEdt: Boolean;
   strngs: array[0..4] of string = ('','','','','');
   // To use with FDIBInfo1.GetVersion()
   rVer : TIBInfo.TVersion;
   rConf : TIBInfo.TConfig;

implementation

uses
   uMultiLanguage, uGlobal;

{$R *.dfm}

{ Suggested port configuration for Firebird servers:
•	Firebird 5.0 server: port 3055, compatible with version 4.0
•	Firebird 3.0 server: port 3030
•	Firebird 2.5 server: port 3025, compatible with versions 2.1, 2.0
•	Firebird 1.5 server: port 3015, compatible with the version 1.0
}

procedure TfrmFBInfo2.FormActivate(Sender: TObject);
begin
   // Parameters required to use FDIBInfo1
   FDIBInfo1.DriverLink := FDPhysFBDriverLink1;
   FDIBInfo1.Host := '127.0.0.1';
   FDIBInfo1.Protocol := ipTCPIP;
   clean;
   iniconf := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'config.ini');
   loadConfigINI;
   EdtReadOnly(True);
   ptBR;
end;

procedure TfrmFBInfo2.btnBrowseClick(Sender: TObject);
var
  i, j:integer;
  s, pathExe, pathBD, pathTXT, vODS, vODS_temp :string;
  parametros:PChar;
begin

  clean;

  if OpenDialog1.Execute then
  begin
    for i:= 0 to High(port) do
    begin
       try
         edtBD.Text := OpenDialog1.FileName;
         s := UpperCase(RightStr(edtBD.Text,3));
         if (s <> 'FDB') AND (s <> 'GDB')then
         begin
           ShowMessage(strngs[0]); // 'It is not a Firebird database.'
           edtBD.Text := EmptyStr;
           Break;
         end;

         Screen.Cursor := crHourGlass;
         conectParams;
         // DB path
         FDConnection1.Params.Add('Database=' + edtBD.Text);
         // Port
         FDConnection1.Params.Add('Port=' + port[i]);
         FDIBInfo1.Port := StrToInt(port[i]);
         FDConnection1.Connected := True;
         lblPort.Caption := 'Port: ' + port[i];

         FDIBInfo1.UserName := 'sysdba';
         FDIBInfo1.Password := 'masterkey';
         FDIBInfo1.GetVersion(rVer);
         lblFBserver.Caption := rVer.FServerStr;

         FDIBInfo1.UserName := 'sysdba';
         FDIBInfo1.Password := 'masterkey';
         FDIBInfo1.GetConfig(rConf);
         lblFBPath.Caption  := rConf.FServerPath;

         s := lblFBPath.Caption;
         if (Pos('3_',s) <> 0) or (Pos('4_',s) <> 0) or (Pos('5_',s) <> 0) then
            pathExe := lblFBPath.Caption + 'gstat.exe'
         else
            pathExe := lblFBPath.Caption + 'bin\gstat.exe';

         pathBD  := edtBD.Text;
         pathTXT := ExtractFilePath(Application.ExeName) + 'out.txt';
         pathExe := verifySpaces(pathExe);
         pathBD  := verifySpaces(pathBD);
         pathTXT := verifySpaces(pathTXT);

         {ShellExecute(0, nil, 'cmd.exe', PChar('/C ' + pathExe + ' -h -user SYSDBA -pass masterkey '
          + pathBD + ' > C:\Users\usuario\out.txt'), PChar(pathExe), SW_HIDE);}
         try
            parametros := PChar('/C ' + pathExe + ' -h -user SYSDBA -pass masterkey ' + pathBD + ' > ' + pathTXT);
            j := ShellExecuteAndWait(0, '', 'cmd.exe', parametros, PChar(pathExe), SW_HIDE, True);
         except
            on E:Exception do
            // Log('Error: '+E.Message);
         end;

         Memo1.Lines.LoadFromFile(pathTXT);

         for j := 0 to Pred(Memo1.Lines.Count) do
         begin
            if (Memo1.Lines.Strings[j].Contains('ODS') = True) then
               lblODS.Caption := RemoveSpaces(Memo1.Lines.Strings[j]);

            if (Memo1.Lines.Strings[j].Contains('Page size') = True) then
               lblPS.Caption := RemoveSpaces(Memo1.Lines.Strings[j]) + ' bytes';

            if (Memo1.Lines.Strings[j].Contains('Database dialect') = True) then
               lblSqlDialect.Caption := RemoveSpaces(Memo1.Lines.Strings[j]);
         end;

         vODS_temp := lblODS.Caption;
         vODS := RightStr(vODS_temp, Length(vODS_temp)-12);

          // Identify Firebird version based on ODS
         if vODS = '13.1' then lblFBv.Caption := 'Firebird 5.0'
            else if vODS = '13.0' then lblFBv.Caption := 'Firebird 4.0'
               else if vODS = '12.0' then lblFBv.Caption := 'Firebird 3.0'
                  else if vODS = '11.2' then lblFBv.Caption := 'Firebird 2.5'
                     else if vODS = '11.1' then lblFBv.Caption := 'Firebird 2.1'
                        else if vODS = '11.0' then lblFBv.Caption := 'Firebird 2.0'
                           else if vODS = '10.1' then lblFBv.Caption := 'Firebird 1.5'
                              else if vODS = '10.0' then lblFBv.Caption := 'Firebird 1.0'
                                 else lblFBv.Caption := strngs[1]; // 'Unknown Firebird version'

         FDConnection1.Connected := False;
         Screen.Cursor := crDefault;
         Break;
       except
         if i = High(port) then
         begin
           ShowMessage(strngs[2]); // 'Unable to connect to database'
           Screen.Cursor := crDefault;
           clean;
         end;
         continue;
       end;
       end;
     end
     else
     begin
       edtBD.Text := EmptyStr;
       OpenDialog1.FileName := EmptyStr;
     end;
end;

procedure TfrmFBInfo2.conectParams;
begin
   FDConnection1.Params.Clear;
   // DriverName
   FDConnection1.DriverName := 'FB';
   // DriverID
   FDConnection1.Params.Add('DriverID=FB');
   // Usuário
   FDConnection1.Params.Add('User_Name=SYSDBA');
   // PassWord
   FDConnection1.Params.Add('Password=masterkey');
   // Protocolo
   FDConnection1.Params.Add('Protocol=TCPIP');
   // Servidor
   FDConnection1.Params.Add('Server=127.0.0.1');
   // CharacterSet
   //FDConnection1.Params.Add('CharacterSet=WIN1252');
   // Login Prompt
   FDConnection1.LoginPrompt := False;
end;

procedure TfrmFBInfo2.btnEditClick(Sender: TObject);
begin
   if btnEdit.Caption = strngs[3] then // &Save
   begin
      iniconf.WriteString('Port','FB15',edtFB15.Text);
      iniconf.WriteString('Port','FB25',edtFB25.Text);
      iniconf.WriteString('Port','FB30',edtFB30.Text);
      iniconf.WriteString('Port','FB50',edtFB50.Text);
      btnCancel.Enabled := False;
      btnEdit.Caption := strngs[4]; // Edit
      EdtReadOnly(True);
      loadConfigINI;
      Exit;
   end;

   btnEdit.Caption   := strngs[3]; // &Save
   btnCancel.Enabled := True;
   EdtReadOnly(False);
end;

procedure TfrmFBInfo2.btnCancelClick(Sender: TObject);
begin
   loadConfigINI;
   btnCancel.Enabled := False;
   btnEdit.Caption := strngs[4]; // Edit
   EdtReadOnly(True);
end;

procedure TfrmFBInfo2.clean;
begin
   OpenDialog1.FileName := EmptyStr;
   edtBD.Text := EmptyStr;
   lblFBserver.Caption := EmptyStr;
   lblODS.Caption := EmptyStr;
   lblFBv.Caption := EmptyStr;
   lblPort.Caption := EmptyStr;
   lblPS.Caption := EmptyStr;
   lblSqlDialect.Caption := EmptyStr;
   lblFBPath.Caption := EmptyStr;
   Memo1.Clear;
end;

procedure TfrmFBInfo2.SetIniValue(pLocal, pSession, pSubSession, pValue:string);
var vArquivo:TIniFile;
begin
   vArquivo:=TIniFile.Create(pLocal);
   vArquivo.WriteString(pSession, pSubSession, pValue);
   vArquivo.Free;
end;

function TfrmFBInfo2.GetIniValue(pLocal, PSession, pSubSession:string):string;
var vArquivo:TIniFile;
begin
   vArquivo:=TIniFile.Create(plocal);
   Result:=vArquivo.ReadString(pSession, pSubSession, '');
   vArquivo.Free;
end;

procedure TfrmFBInfo2.loadConfigINI;
begin
   edtFB15.Text := iniconf.ReadString('Port','FB15','');
   port[3] := edtFB15.Text;

   edtFB25.Text := iniconf.ReadString('Port','FB25','');
   port[2] := edtFB25.Text;

   edtFB30.Text := iniconf.ReadString('Port','FB30','');
   port[1] := edtFB30.Text;

   edtFB50.Text := iniconf.ReadString('Port','FB50','');
   port[0] := edtFB50.Text;
end;

// If it is a long path (with space characters), wrap it in double quotes.
function TfrmFBInfo2.verifySpaces(path:string) : string;
begin
   if Pos(' ', path) > 0 then
   begin
      path := AnsiQuotedStr(path, Char(34));
      Result := path;
   end
   else
      Result := path;
end;

procedure TfrmFBInfo2.EdtReadOnly(state: Boolean);
begin
   edtFB15.ReadOnly := state;
   edtFB25.ReadOnly := state;
   edtFB30.ReadOnly := state;
   edtFB50.ReadOnly := state;
end;

procedure TfrmFBInfo2.btn_enClick(Sender: TObject);
begin
   en;
end;

procedure TfrmFBInfo2.btn_ptBRClick(Sender: TObject);
begin
   ptBR;
end;

end.
