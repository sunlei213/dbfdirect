program mytest;

uses
  FastMM4,
  Vcl.Forms,
  mytest_main in 'mytest_main.pas' {Form1},
  singleton in '..\myclass\singleton.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
