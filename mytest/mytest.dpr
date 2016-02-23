program mytest;

uses
  Vcl.Forms,
  mytest_main in 'mytest_main.pas' {Form1},
  mystock.singleinf.logger in '..\myclass\mystock.singleinf.logger.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
