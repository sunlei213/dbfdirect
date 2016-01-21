program sse2dbf;

uses
  Vcl.Forms,
  sse2dbf_main in 'sse2dbf_main.pas' {Form2},
  ArrayEx in 'ArrayEx.pas',
  DBFdirect in 'DBFdirect.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
