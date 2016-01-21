unit sse2dbf_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,DBFdirect;

type
  TForm2 = class(TForm)
    Label1: TLabel;
    fastdir: TEdit;
    Label2: TLabel;
    fjydir: TEdit;
    Label3: TLabel;
    dbfdir: TEdit;
    tran_start: TButton;
    tran_stop: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

end.
