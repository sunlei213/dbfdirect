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
  private
    function tranbyte<T>(value:T):TIdBytes;
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
begin
     sl.s1:=30;
     myth1:=TMyThread.Create(True);
     myth1.Start;
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
tby:TIdBytes;
lg:login;
chk:UInt32;
hd:head;
login_frm:Tlogin;
begin
  inherited;
  FreeOnTerminate := True;
  i:=0;
  MYform.idtcpclnt1.Host:='127.0.0.1';
  MYform.idtcpclnt1.Port:=8016;
  try
    MYform.idtcpclnt1.Connect;
    hd.MsgType:=1;
    hd.BodyLength:=92;
    strtospace('realtime1',Length(lg.SenderCompID),lg.SenderCompID);
    strtospace('mdgw11',Length(lg.TargetCompID),lg.TargetCompID);
    strtospace('',Length(lg.Password),lg.Password);
    strtospace('1.00',Length(lg.DefaultApplVerID),lg.DefaultApplVerID);
    chk:=MYform.check<login>(lg);
    login_frm.TL_head:=hd;
    login_frm.TL_body:=lg;
    login_frm.TL_Check:=chk;
    MYform.idtcpclnt1.Socket.DefStringEncoding:=IdGlobal.IndyTextEncoding_UTF8();
    MYform.idtcpclnt1.Socket.WriteDirect(tranbyte<Tlogin>(login_frm),SizeOf(login_frm));
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
function TMyThread.tranbyte<T>(value: T): TIdBytes;
var
 tb1:TIdBytes;
 j:Integer;
begin
  j:=SizeOf(value);
  Result:=0;
  SetLength(tb1,j);
  CopyMemory(@tb1[0],@value,j);
  Result:=tb1;
end;

end.
