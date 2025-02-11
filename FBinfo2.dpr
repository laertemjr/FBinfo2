program FBinfo2;

uses
  Vcl.Forms,
  uFBInfo2 in 'uFBInfo2.pas' {frmFBInfo2},
  uMultiLanguage in 'uMultiLanguage.pas',
  uGlobal in 'uGlobal.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmFBInfo2, frmFBInfo2);
  Application.Run;
end.
