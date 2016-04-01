program test;

uses
//  FastMM4,
  Vcl.Forms,
  test_main in 'test_main.pas' {Form1},
  singleton in 'singleton.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
