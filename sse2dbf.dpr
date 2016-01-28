program sse2dbf;

uses
  Vcl.Forms,
  sse2dbf_main in 'sse2dbf_main.pas' {Form2},
  ArrayEx in 'ArrayEx.pas',
  DBFdirect in 'DBFdirect.pas',
  sse2dbf_set in 'sse2dbf_set.pas' {settaskentry};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
//  Application.CreateForm(Tsettaskentry, settaskentry);
  Application.Run;
end.
