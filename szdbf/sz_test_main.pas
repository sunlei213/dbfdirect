unit sz_test_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,sz_fix, Vcl.StdCtrls,IdGlobal,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient;

type
  TMYform = class(TForm)
    btn1: TButton;
    idtcpclnt1: TIdTCPClient;
    btn2: TButton;
    mmo1: TMemo;
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
    function check<T>(value:T):UInt32;
  public
    { Public declarations }
  end;

  TMyThread = class(TThread)
  protected
    procedure Execute; override;
    procedure showmsg(st:string);
  end;

var
  MYform: TMYform;
  myth1:tmythread;

implementation

{$R *.dfm}

procedure TMYform.btn1Click(Sender: TObject);
type
 mysam=record
   case Integer of
   0:(s1:UInt32);
   1:(s2:array[0..3] of Byte);
 end;
var
sl:mysam;
lg:login;
chk:UInt32;
begin
   lg.SenderCompID:='realtim1';
   lg.TargetCompID:='at001';
   lg.HeartBtInt:=30;
   lg.Password:='sunlei';
   lg.DefaultApplVerID:='1.00';
   sl.s1:=30;
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


{ TMyThread }

procedure TMyThread.Execute;
var
st:string;
i,j:integer;
tby:tidbytes;
begin
  inherited;
  FreeOnTerminate := True;
  i:=0;
  MYform.idtcpclnt1.Host:='127.0.0.1';
  MYform.idtcpclnt1.Port:=9999;
  try
    MYform.idtcpclnt1.Connect;
//    MYform.idtcpclnt1.Socket.DefStringEncoding:=indytextencoding_osdefault();
    try
      begin
        while True do
        begin
         MYform.idtcpclnt1.Socket.CheckForDataOnSource;
 //            st:=MYform.idtcpclnt1.Socket.ReadLn;
          if not MYform.idtcpclnt1.Socket.InputBufferIsEmpty then
            begin
              j:= MYform.idtcpclnt1.Socket.InputBuffer.Size;
//              setlength(tby,j);
              MYform.idtcpclnt1.Socket.ReadBytes(tby,j);
//              st:=ansistring(MYform.idtcpclnt1.Socket.readln);
//              tby:=tencoding.Default.GetBytes(st);
              st:=tencoding.Default.GetString(tbytes(tby));
              MYform.mmo1.Lines.Add(st);
              i:=0
            end
          else
            begin
              sleep(20);
              inc(i);
              Application.ProcessMessages;
              if i mod 300 =0 then
              MYform.idtcpclnt1.Socket.WriteLn('心跳');
            end;
          if self.Terminated then break;
        end;
      end;
      finally
      begin
        MYform.idtcpclnt1.Disconnect;
        Synchronize(procedure
                     begin
                     showmessage('进程结束');
                     end);
      end;
    end;
  except
  Synchronize(procedure
              begin
              ShowMessage('没有连接上主机');
              end);
  end;
end;

procedure TMyThread.showmsg(st: string);
begin
  ShowMessage(st);
end;
end.
