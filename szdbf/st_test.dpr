program st_test;

uses
  Vcl.Forms,
  sz_test_main in 'sz_test_main.pas' {MYform},
  sz_fix in 'sz_fix.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMYform, MYform);
  Application.Run;
end.
