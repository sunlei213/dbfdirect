unit sz_test_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,sz_fix, Vcl.StdCtrls;

type
  TMYform = class(TForm)
    btn1: TButton;
    lbl1: TLabel;
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
    function check<T>(value:T):UInt32;
  public
    { Public declarations }
  end;

var
  MYform: TMYform;

implementation

{$R *.dfm}

procedure TMYform.btn1Click(Sender: TObject);
var
lg:login;
chk:UInt32;
begin
   lg.SenderCompID:='realtim1';
   lg.TargetCompID:='at001';
   lg.HeartBtInt:=30;
   lg.Password:='sunlei';
   lg.DefaultApplVerID:='1.00';
   chk:=check<login>(lg);
end;

function TMYform.check<T>(value: T): UInt32;
var
tb1:TBytes;
i,j:Integer;
begin
  j:=SizeOf(value);
  Result:=0;
  SetLength(tb1,j);
  CopyMemory(@tb1[0],@value,j);
  for I := 0 to j-1 do Result:=Result+tb1[i];
  Result:=Result mod 256;
end;

end.
