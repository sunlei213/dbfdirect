program stock;

uses
  Vcl.Forms,
  stock_main in 'stock_main.pas' {Form2},
  mystock.classes in '..\myclass\mystock.classes.pas',
  mystock.interfaces in '..\myclass\mystock.interfaces.pas',
  mystock.types in '..\myclass\mystock.types.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
