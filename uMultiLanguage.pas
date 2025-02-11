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
   with frmFBInfo2 do
   begin
      Caption := 'FBINFO2 - Identifica o banco de dados Firebird (compatível com as versões 1.x - 5.x)';
      btnBrowse.Caption := '&Procurar';
      btnCancel.Caption := '&Cancelar';

      if btnEdit.Caption = '&Edit' then
         btnEdit.Caption := '&Alterar'
      else if btnEdit.Caption = '&Save' then
         btnEdit.Caption := '&Gravar';

      Label6.Caption := 'Selecione o banco de dados Firebird :';
      Label1.Caption := 'Banco de dados: ';
      Label2.Caption := 'Versão do servidor Firebird que o banco de dados está conectado :';
      Label3.Caption := 'Versão ODS do banco de dados :';
      Label4.Caption := 'Versão do banco de dados Firebird :';
      Label5.Caption := 'Outras informações :';
      Label8.Caption := 'Configuração das portas dos servidores Firebird :';
      Label7.Caption := 'Desenvolvido em Delphi 12.1, componentes FireDAC, versão 0.3 (2025)';
      OpenDialog1.Filter := 'Bancos de dados Firebird|*.GDB;*.FDB;';
   end;

   strngs[0] := 'Não é um banco de dados Firebird.';
   strngs[1] := 'Firebird versão desconhecida.';
   strngs[2] := 'Não foi possível a conexão com o banco de dados';
   strngs[3] := '&Gravar';
   strngs[4] := '&Alterar';
end;

procedure en();
begin
   With frmFBInfo2 do
   begin
      Caption := 'FBINFO2 - Identifies the Firebird database (compatible with versions 1.x - 5.x)';
      btnBrowse.Caption := '&Browse';
      btnCancel.Caption := '&Cancel';

      if btnEdit.Caption = '&Alterar' then
         btnEdit.Caption := '&Edit'
      else if btnEdit.Caption = '&Gravar' then
         btnEdit.Caption := '&Save';

      Label6.Caption := 'Select Firebird database :';
      Label1.Caption := 'Database: ';
      Label2.Caption := 'Firebird server version that the database is connected to :';
      Label3.Caption := 'ODS version of the database :';
      Label4.Caption := 'Firebird Database Version :';
      Label5.Caption := 'Other information :';
      Label8.Caption := 'Firebird server port configuration :';
      Label7.Caption := 'Developed in Delphi 12.1, FireDAC components, version 0.3 (2025)';
      OpenDialog1.Filter := 'Firebird databases|*.GDB;*.FDB;';
   end;

   strngs[0] := 'It is not a Firebird database.';
   strngs[1] := 'Firebird unknown version.';
   strngs[2] := 'Unable to connect to database';
   strngs[3] := '&Save';
   strngs[4] := '&Edit';
end;

end.
