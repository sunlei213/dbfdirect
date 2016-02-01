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
    procedure btn2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
  tm:TMemoryStream;
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
     btn1.Enabled:=False;
     btn2.Enabled:=True;
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
i,j,k,l:integer;
tby,t_heat:TIdBytes;
lg:login;
chk:UInt32;
login_frm:Tlogin;
begin
  inherited;
  FreeOnTerminate := True;
  SetLength(t_heat,12);
  FillBytes(t_heat,12,0);
  t_heat[3]:=3;
  t_heat[11]:=3;
  i:=0;
  MYform.idtcpclnt1.Host:='127.0.0.1';
  MYform.idtcpclnt1.Port:=8016;
  try

    lg.l_head.MsgType:=a32_l2h(1);
    lg.l_head.BodyLength:=a32_l2h(92);
    strtospace('resend',Length(lg.SenderCompID),lg.SenderCompID);
    strtospace('mdgw11',Length(lg.TargetCompID),lg.TargetCompID);
    strtospace('mdgw11',Length(lg.Password),lg.Password);
    lg.HeartBtInt:=a32_l2h(15);
    strtospace('1.00',Length(lg.DefaultApplVerID),lg.DefaultApplVerID);
    chk:=MYform.check<login>(lg);
    login_frm.TL_body:=lg;
    login_frm.TL_Check:=a32_l2h(chk);
    tby:=RawToBytes(login_frm,SizeOf(login_frm));
    i:=SizeOf(login_frm);
    MYform.idtcpclnt1.Connect;
//    MYform.idtcpclnt1.Socket.DefStringEncoding:=IdGlobal.IndyTextEncoding_UTF8();
    MYform.idtcpclnt1.Socket.Write(tby);
    l:=0;
    try
      begin
        while not Self.Terminated do
        begin
         MYform.idtcpclnt1.Socket.CheckForDataOnSource;
 //            st:=MYform.idtcpclnt1.Socket.ReadLn;
          if not MYform.idtcpclnt1.Socket.InputBufferIsEmpty then
            begin
              j:= MYform.idtcpclnt1.Socket.InputBuffer.Size;
              setlength(tby,0);
              MYform.idtcpclnt1.Socket.ReadBytes(tby,j);
              tm.Write(TBy[0],length(tby));
              MYform.idtcpclnt1.IOHandler.CheckForDataOnSource(1);
              if MYform.idtcpclnt1.Socket.InputBufferIsEmpty then
                 MYform.mmo1.Lines.Add(inttostr(l)+':'+'buffer空了');
//              st:=ansistring(MYform.idtcpclnt1.Socket.readln);
//              tby:=tencoding.Default.GetBytes(st);
{              for k := 0 to j-1 do
                if tby[k]=0 then tby[k]:=32;
              st:=tencoding.Default.GetString(tbytes(tby));
              MYform.mmo1.Lines.Add(inttostr(l)+':'+st);
             i:=0;
}              l:=l+1;
               MYform.mmo1.Lines.Add(Format('%d:内存流大小：%d',[l,tm.Size]));
            end
          else
            begin
              sleep(40);
              inc(i);
              Application.ProcessMessages;
              if i mod 300 =0 then
              begin
              i:=0;
              MYform.idtcpclnt1.Socket.WriteDirect(t_heat);
              end;
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

procedure TMYform.btn2Click(Sender: TObject);
begin
  if myth1<>nil then
   myth1.Terminate;
  btn1.Enabled:=True;
  btn2.Enabled:=False;
  tm.SaveToFile('d:\sl.dat');
end;

procedure TMYform.FormCreate(Sender: TObject);
begin
 tm:=TMemoryStream.Create;
end;

end.
