program st_test;

uses
  Vcl.Forms,
  sz_test_main in 'sz_test_main.pas' {MYform},
  sz_fix in 'sz_fix.pas',
  sz_interface in 'sz_interface.pas',
  DBFdirect in 'DBFdirect.pas',
  mystock.logger in '..\myclass\mystock.logger.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMYform, MYform);
  Application.Run;
end.
