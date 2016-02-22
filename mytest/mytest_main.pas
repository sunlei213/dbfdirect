unit mytest_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,System.Generics.Collections ,System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,system.Diagnostics, Vcl.StdCtrls, singleton;

type
  myintf=interface
    function readdata:TArray<Integer>;
    procedure setdata(cou:Integer;st1:string);
    procedure show;
  end;
  TMyMsg=class(TInterfacedObject,myintf)
  private
    leng:Integer;
    fmsg:TArray<string>;
    inarr:tarray<Integer>;
    str1:string;
    function recover(st:string):Integer;
  public
    constructor create;
    destructor destroy;override;
    procedure setdata(cou:Integer;st1:string);
    function readdata:TArray<Integer>;virtual;
    procedure show;
  end;
  TForm1 = class(TForm)
    edt1: TEdit;
    btn1: TButton;
    btn2: TButton;
    mmo1: TMemo;
    btn3: TButton;
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    stopw:TStopwatch;
    queu:TQueue<myintf>;
    procedure testintface(x1:myintf);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  log:TLogger;

implementation



{$R *.dfm}

procedure TForm1.btn1Click(Sender: TObject);
var
  st,st1:string;
  va:Variant;
  i,j,k:Integer;
  num:array [0..7] of integer;
  starr:TArray<string>;
  my:myintf;
  my1:TMyMsg;
  log2:TLogger;
begin
  log2:=TLogger.Instance;
  num[0]:=1;
  for I := 1 to 7 do
    num[i]:=num[i-1]*10;
  st:=edt1.Text;
  j:=st.ToInteger;
  st:='1234.85697';
  k:=1234856970;
  my1:=TMyMsg.create;
  my1.setdata(2,'destroy');
  my:=my1;
  testintface(my);
  log2.WriteLog('log2,button1',2);
  ShowMessage('test');
  stopw.Reset;
  stopw.Start;
  for I := 0 to j-1 do
  begin
   my:=TMyMsg.create;
   my.setdata(2,st);
   queu.Enqueue(my);
  end;
  stopw.Stop;
  mmo1.Lines.Add(Format('整型%d,%s循环%d次耗时%d毫秒',[k,st,i,stopw.ElapsedMilliseconds]));
end;

procedure TForm1.btn2Click(Sender: TObject);
var
  st,st1:string;
  va:Variant;
  i,j:Integer;
  k:TArray<Integer>;
  imy:myintf;
begin
  st:=edt1.Text;
  j:=st.ToInteger;
  st:='1234.56789';
//  k:=st.ToExtended;
  stopw.Reset;
  stopw.Start;
  for I := 0 to queu.Count-1 do
  begin
   imy:=queu.Dequeue;
   k:=imy.readdata;
   imy.setdata(2,st);
  end;
  stopw.Stop;
  mmo1.Lines.Add(Format('浮点%d,%d,%d循环%d次耗时%d毫秒',[k[0],k[1],queu.Count,i,stopw.ElapsedMilliseconds]));
end;

procedure TForm1.btn3Click(Sender: TObject);
var
  st,st1:string;
  va:Variant;
  i,j:Integer;
  k:Extended;
begin
  st:=edt1.Text;
  j:=st.ToInteger;
  st:='1234.85697';
  stopw.Reset;
  stopw.Start;
  for I := 0 to j do
  begin
   va:=st;
   st1:=va;
  end;
  stopw.Stop;
  mmo1.Lines.Add(Format('浮点%s循环%d次耗时%d毫秒',[st1,i,stopw.ElapsedMilliseconds]));
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 stopw:=TStopwatch.Create;
 queu:=TQueue<myintf>.Create;
 log:= TLogger.Instance;
 log.LogShower:=mmo1;
 log.WriteLog('程序开始了',1);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  log.WriteLog('程序结束了',1);
  queu.Free;
  log.ReleaseInstance;
end;

procedure TForm1.testintface(x1: myintf);
begin
  x1.show;
end;

{ TMyMsg }

constructor TMyMsg.create;
var
  i:Integer;
begin
  inherited create;
  leng:=0;
  SetLength(fmsg,0);
  SetLength(inarr,7);
  inarr[0]:=1;
  for I := 1 to 6 do
    inarr[i]:=inarr[i-1]*10;
end;

destructor TMyMsg.destroy;
begin
  SetLength(fmsg,0);
  log.WriteLog(Self.str1,1);
  inherited;
end;

function TMyMsg.readdata: TArray<Integer>;
var
  I: Integer;
begin
  SetLength(Result,leng);
  for I := 0 to leng-1 do
    Result[i]:=recover(fmsg[i]);
end;

function TMyMsg.recover(st: string): Integer;
var
  starr:TArray<string>;
  i,j:Integer;
begin
  starr:=st.Split(['.']);
  i:=starr[1].ToInteger;
  j:=6-starr[1].Length;
  if j<0 then j:=0;
  Result:=starr[0].ToInteger*1000000+i*inarr[j];
end;

procedure TMyMsg.setdata(cou: Integer; st1: string);
var
  i:Integer;
begin
  leng:=cou;
  setlength(fmsg,cou);
  Self.str1:=st1;
  for I := 0 to cou-1 do
    fmsg[i]:=st1;
end;

procedure TMyMsg.show;
begin
  Self.leng:=leng+1;
  log.WriteLog('第%d次调用',[Leng],1);
end;

end.
