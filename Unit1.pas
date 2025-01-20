unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Data.DB, StrUtils, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Consts,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.VCLUI.Wait,
  FireDAC.Phys.FBDef, FireDAC.Phys.IBWrapper, FireDAC.Phys.IBBase,
  FireDAC.Phys.FB, FireDAC.Comp.UI, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Winapi.ShellAPI;

type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    lblFBserver: TLabel;
    Label3: TLabel;
    lbODS: TLabel;
    Label4: TLabel;
    lbFBv: TLabel;
    lblPorta: TLabel;
    lblPS: TLabel;
    Label5: TLabel;
    lblDialetoSQL: TLabel;
    edtBD: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    FDConnection1: TFDConnection;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FDIBInfo1: TFDIBInfo;
    lblFBPath: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure conectParams();
    procedure FormActivate(Sender: TObject);
    procedure limpar();
    function verificaEspaco(caminho:string) : string;
  private
    { Private declarations }
    const porta:array[0..3] of string = ('3055', '3030','3025', '3015');
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  // Para usar com FDIBInfo1.GetVersion()
  rVer : TIBInfo.TVersion;
  rConf : TIBInfo.TConfig;

implementation

uses uGlobal;
{$R *.dfm}

{ Conexões Firebird e bancos de dados:
•  Servidor Firebird 5.0: porta 3055, compatível com a versão 4.0
•	Servidor Firebird 3.0: porta 3030
•	Servidor Firebird 2.5: porta 3025, compatível com as versões 2.1, 2.0
•	Servidor Firebird 1.5: porta 3015, compatível com a versão 1.0
}

procedure TForm1.Button1Click(Sender: TObject);
var
  i, x:integer;
  s, pathExe, pathBD, pathTXT, vODS, vODS_temp :string;
  parametros:PChar;
begin
  limpar;
  OpenDialog1.Filter := 'Bancos de Dados Firebird|*.GDB;*.FDB;';

  if OpenDialog1.Execute then
  begin
    for i:= 0 to High(porta) do
    begin
    try
      edtBD.Text := OpenDialog1.FileName;
      s := UpperCase(RightStr(edtBD.Text,3));
      if (s <> 'FDB') AND (s <> 'GDB')then
      begin
        ShowMessage('Não é um banco de dados Firebird.');
        edtBD.Text := EmptyStr;
        Break;
      end;

      conectParams;
      // local do BD
      FDConnection1.Params.Add('Database=' + edtBD.Text);
      // Porta
      FDConnection1.Params.Add('Port=' + porta[i]);
      FDIBInfo1.Port := StrToInt(porta[i]);
      FDConnection1.Connected := True;
      lblPorta.Caption := 'Porta: ' + porta[i];

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
      pathExe := verificaEspaco(pathExe);
      pathBD  := verificaEspaco(pathBD);
      pathTXT := verificaEspaco(pathTXT);

      {ShellExecute(0, nil, 'cmd.exe', PChar('/C ' + pathExe + ' -h -user SYSDBA -pass masterkey '
       + pathBD + ' > C:\Users\usuario\out.txt'), PChar(pathExe), SW_HIDE);}
      try
         parametros := PChar('/C ' + pathExe + ' -h -user SYSDBA -pass masterkey ' + pathBD + ' > ' + pathTXT);
         x := ShellExecuteAndWait(0, '', 'cmd.exe', parametros, PChar(pathExe), SW_HIDE, True);
      except
         on E:Exception do
         // GeraLog('Erro ao copiar: '+E.Message);
      end;

      Memo1.Lines.LoadFromFile(pathTXT);

      for x := 0 to Pred(Memo1.Lines.Count) do
      begin
         if (Memo1.Lines.Strings[x].Contains('ODS') = True) then
            lbODS.Caption := RemoveSpaces(Memo1.Lines.Strings[x]);

         if (Memo1.Lines.Strings[x].Contains('Page size') = True) then
            lblPS.Caption := RemoveSpaces(Memo1.Lines.Strings[x]) + ' bytes';

         if (Memo1.Lines.Strings[x].Contains('Database dialect') = True) then
            lblDialetoSQL.Caption := RemoveSpaces(Memo1.Lines.Strings[x]);
      end;

      vODS_temp := lbODS.Caption;
      vODS := RightStr(vODS_temp, Length(vODS_temp)-12);

       // Identifica a versão Firebird com base na ODS
      if vODS = '13.1' then lbFBv.Caption := 'Firebird 5.0';
      if vODS = '13.0' then lbFBv.Caption := 'Firebird 4.0';
      if vODS = '12.0' then lbFBv.Caption := 'Firebird 3.0';
      if vODS = '11.2' then lbFBv.Caption := 'Firebird 2.5';
      if vODS = '11.1' then lbFBv.Caption := 'Firebird 2.1';
      if vODS = '11.0' then lbFBv.Caption := 'Firebird 2.0';
      if vODS = '10.1' then lbFBv.Caption := 'Firebird 1.5';
      if vODS = '10.0' then lbFBv.Caption := 'Firebird 1.0';

      FDConnection1.Connected := False;
      Break;
    except
      if i = High(porta) then
      begin
        ShowMessage('Não foi possível a conexão com o banco de dados');
        limpar;
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

procedure TForm1.conectParams;
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
   FDConnection1.Params.Add('CharacterSet=WIN1252');
   // Login Prompt
   FDConnection1.LoginPrompt := False;
   // SQL Dialect
   //FDConnection1.Params.Add('SQLDialect=3');
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
   // Parâmetros necessários para poder usar FDIBInfo1
   FDIBInfo1.DriverLink := FDPhysFBDriverLink1;
   FDIBInfo1.Host := '127.0.0.1';
   FDIBInfo1.Protocol := ipTCPIP;
   limpar;
end;

procedure TForm1.limpar;
begin
   edtBD.Text := EmptyStr;
   lblFBserver.Caption := EmptyStr;
   lbODS.Caption := EmptyStr;
   lbFBv.Caption := EmptyStr;
   lblPorta.Caption := EmptyStr;
   lblPS.Caption := EmptyStr;
   lblDialetoSQL.Caption := EmptyStr;
   lblFBPath.Caption := EmptyStr;
   Memo1.Clear;
end;

// Se for um caminho longo (com caracteres de espaço), envolve-o em aspas duplas
function TForm1.verificaEspaco(caminho:string) : string;
begin
   if Pos(' ', caminho) > 0 then
   begin
      caminho := AnsiQuotedStr(caminho, Char(34));
      Result := caminho;
   end
   else
      Result := caminho;
end;

end.
