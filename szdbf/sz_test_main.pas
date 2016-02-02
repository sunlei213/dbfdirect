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
    function readbuff<T>(AClient: TIdTCPClient;var value:T;msgtype,buff_len:UInt32):Boolean;
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
type
  TarrMDEntry=array of MDEntry;
var
st:string;
i,j,k,l,endtime:integer;
tby,t_heat:TIdBytes;
lg:login;
lg_body:login_body;
ch_heat_body:Channel_Heartbeat;
stock_body:stock_data;
mden_body:MDEntry;
mdenarr:Tarrmdentry;
chk,msg_type,body_ln:UInt32;
login_frm:Tlogin;
isnodata,dataIStrue:Boolean;
l2_wt:wt_l2;
begin
  inherited;
  FreeOnTerminate := True;
  SetLength(t_heat,12);
  FillBytes(t_heat,12,0);
  t_heat[3]:=3;
  t_heat[11]:=3;
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
    i:=GetTickCount;
    try
      begin
        while not Self.Terminated do
        begin
         MYform.idtcpclnt1.Socket.CheckForDataOnSource;
 //            st:=MYform.idtcpclnt1.Socket.ReadLn;
          if not MYform.idtcpclnt1.Socket.InputBufferIsEmpty then
            begin
              j:= MYform.idtcpclnt1.Socket.InputBuffer.Size;
              msg_type:=MYform.idtcpclnt1.Socket.ReadInt32(False);
              body_ln:=MYform.idtcpclnt1.Socket.ReadInt32(False);
              j:=a32_l2h(msg_type);
              chk:=a32_l2h(body_ln);
              dataIStrue:=False;
              case j of
              1     :begin
                     dataIStrue:=readbuff<login_body>(MYform.idtcpclnt1,lg_body,msg_type,chk);
                     if dataIStrue then
                     MYform.mmo1.Lines.Add(Format('%d:msg_type=%d,body_ln=%d,SenderCompID=%s,TargetCompID=%s,HeartBtInt=%d,Password=%s,DefaultApplVerID=%s',
                                                  [l,j,chk,trim(lg_body.SenderCompID),trim(lg_body.TargetCompID),a32_l2h(lg_body.HeartBtInt),trim(lg_body.Password),trim(lg_body.DefaultApplVerID)]));
                     end;
              3     :begin
                     chk:=MYform.idtcpclnt1.Socket.ReadInt32();
                     //if chk=3 then k:=0;
                     end;
              390095:begin

                     end;
              300192:begin
                       dataIStrue:=readbuff<wt_l2>(MYform.idtcpclnt1,l2_wt,msg_type,chk);
                       if dataIStrue then
                       MYform.mmo1.Lines.Add(Format('%d:msg_type=%d,body_ln=%d,ChannelNo=%d,ApplSeqNum=%d,MDStreamID=%s,SecurityID=%s,SecurityIDSource=%s,Price=%.4n,OrderQty=%d,Side=%s,TransactTime=%d,OrdType=%s',
                                                  [l,j,chk,a16_l2h(l2_wt.ChannelNo),a64_l2h(l2_wt.ApplSeqNum),trim(l2_wt.MDStreamID),trim(l2_wt.SecurityID),trim(l2_wt.SecurityIDSource),(a64_l2h(l2_wt.Price)/10000.00),a64_l2h(l2_wt.OrderQty),l2_wt.Side,a64_l2h(l2_wt.TransactTime),l2_wt.OrdType]));

                     end;
              else
                setlength(tby,0);
                MYform.idtcpclnt1.Socket.ReadBytes(tby,chk);
                chk:=MYform.idtcpclnt1.Socket.ReadInt32();
                tm.Write(TBy[0],length(tby));
                tm.Write(chk,SizeOf(chk));
              end;
              isnodata:=False;

              MYform.idtcpclnt1.IOHandler.CheckForDataOnSource;
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
              if not isnodata then
              begin
                k:=GetTickCount;
                isnodata:=True;
              end;
              sleep(40);
              Application.ProcessMessages;
            end;
          endtime:=GetTickCount;
          if isnodata and ((endtime-k)>15000) then Break;
          if (endtime-i)>12000 then
          begin
          i:=GetTickCount;
          MYform.idtcpclnt1.Socket.WriteDirect(t_heat);
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
function TMyThread.readbuff<T>(AClient: TIdTCPClient;var value:T;msgtype,buff_len: UInt32): Boolean;
var
 tb1:TIdBytes;
 j,check:UInt32;
 trans:uin32;
  I: Integer;
begin
  AClient.IOHandler.ReadBytes(tb1,buff_len,False);
  Result:=false;
  check:=SizeOf(value);
  if SizeOf(value)<>buff_len then Exit;
  check:=0;
  trans.i32:=msgtype;
  for I := 0 to 3 do
     check:=check+trans.by32[i];
  trans.i32:=buff_len;
  for I := 3 downto 0 do
    check:=check+trans.by32[i];
  for I := 0 to buff_len-1 do
    check:=check+tb1[i];
  j:=check mod 256;
  check:=AClient.IOHandler.ReadInt32();
  if j<>check then Exit;
  try
  BytesToRaw(tb1,value,buff_len);
  Result:=True;
  except
  Result:=False;
  end;
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
