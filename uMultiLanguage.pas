unit uMultiLanguage;

interface

// uses

//type

   procedure ptBR();
   procedure en();
// private


// public
// end;

// var

implementation

uses
   uFBInfo2;

procedure ptBR();
begin
   frmFBInfo.Caption := 'FBINFO2 - Identifica o banco de dados Firebird (compatível com as versões 1.x - 5.x)';
   frmFBInfo.btnBrowse.Caption := '&Procurar';
   frmFBInfo.btnCancel.Caption := '&Cancelar';

   if frmFBInfo.btnEdit.Caption = '&Edit' then
      frmFBInfo.btnEdit.Caption := '&Alterar'
   else if frmFBInfo.btnEdit.Caption = '&Save' then
      frmFBInfo.btnEdit.Caption := '&Gravar';

   frmFBInfo.Label6.Caption := 'Selecione o banco de dados Firebird :';
   frmFBInfo.Label1.Caption := 'Banco de dados: ';
   frmFBInfo.Label2.Caption := 'Versão do servidor Firebird que o banco de dados está conectado :';
   frmFBInfo.Label3.Caption := 'Versão ODS do banco de dados :';
   frmFBInfo.Label4.Caption := 'Versão do banco de dados Firebird :';
   frmFBInfo.Label5.Caption := 'Outras informações :';
   frmFBInfo.Label8.Caption := 'Configuração das portas dos servidores Firebird :';
   frmFBInfo.Label7.Caption := 'Desenvolvido em Delphi 12.1, componentes FireDAC, versão 0.3 (2025)';
   frmFBInfo.OpenDialog1.Filter := 'Bancos de dados Firebird|*.GDB;*.FDB;';
   strngs[0] := 'Não é um banco de dados Firebird.';
   strngs[1] := 'Firebird versão desconhecida.';
   strngs[2] := 'Não foi possível a conexão com o banco de dados';
   strngs[3] := '&Gravar';
   strngs[4] := '&Alterar';
end;

procedure en();
begin
   frmFBInfo.Caption := 'FBINFO2 - Identifies the Firebird database (compatible with versions 1.x - 5.x)';
   frmFBInfo.btnBrowse.Caption := '&Browse';
   frmFBInfo.btnCancel.Caption := '&Cancel';

   if frmFBInfo.btnEdit.Caption = '&Alterar' then
      frmFBInfo.btnEdit.Caption := '&Edit'
   else if frmFBInfo.btnEdit.Caption = '&Gravar' then
      frmFBInfo.btnEdit.Caption := '&Save';

   frmFBInfo.Label6.Caption := 'Select Firebird database :';
   frmFBInfo.Label1.Caption := 'Database: ';
   frmFBInfo.Label2.Caption := 'Firebird server version that the database is connected to :';
   frmFBInfo.Label3.Caption := 'ODS version of the database :';
   frmFBInfo.Label4.Caption := 'Firebird Database Version :';
   frmFBInfo.Label5.Caption := 'Other information :';
   frmFBInfo.Label8.Caption := 'Firebird server port configuration :';
   frmFBInfo.Label7.Caption := 'Developed in Delphi 12.1, FireDAC components, version 0.3 (2025)';
   frmFBInfo.OpenDialog1.Filter := 'Firebird databases|*.GDB;*.FDB;';
   strngs[0] := 'It is not a Firebird database.';
   strngs[1] := 'Firebird unknown version.';
   strngs[2] := 'Unable to connect to database';
   strngs[3] := '&Save';
   strngs[4] := '&Edit';
end;

end.
