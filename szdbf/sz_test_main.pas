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
    function make_data(AClient: TIdTCPClient):Boolean;
    procedure recvbuff(AClient:TIdTCPClient;buff:TIdBytes;var chk:UInt32);
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
i,j,k,endtime:integer;
tby,t_heat:TIdBytes;
lg:login;
lg_body:login_body;
chk,msg_type,body_ln,l:UInt32;
login_frm:Tlogin;
isnodata:Boolean;
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
    msg_type:=1;
    body_ln:=92;
    l:=3;
    lg.l_head.MsgType:=NET2CPU(msg_type);
    lg.l_head.BodyLength:=NET2CPU(body_ln);
    strtospace('resend',Length(lg.SenderCompID),lg.SenderCompID);
    strtospace('mdgw11',Length(lg.TargetCompID),lg.TargetCompID);
    strtospace('mdgw11',Length(lg.Password),lg.Password);
    lg.HeartBtInt:=NET2CPU(l);
    strtospace('1.00',Length(lg.DefaultApplVerID),lg.DefaultApplVerID);
    chk:=MYform.check<login>(lg);
    login_frm.TL_body:=lg;
    login_frm.TL_Check:=NET2CPU(chk);
    tby:=RawToBytes(login_frm,SizeOf(login_frm));
    i:=SizeOf(login_frm);
    MYform.idtcpclnt1.Connect;
//    MYform.idtcpclnt1.Socket.DefStringEncoding:=IdGlobal.IndyTextEncoding_UTF8();
    MYform.idtcpclnt1.Socket.Write(tby);
    l:=0;
    i:=GetTickCount;
    j:=i;
    try
      begin
        while not Self.Terminated do
        begin
         MYform.idtcpclnt1.Socket.CheckForDataOnSource;
          if not MYform.idtcpclnt1.Socket.InputBufferIsEmpty then
            begin
              isnodata:=False;
              make_data(MYform.idtcpclnt1);

//              st:=ansistring(MYform.idtcpclnt1.Socket.readln);
//              tby:=tencoding.Default.GetBytes(st);
{              for k := 0 to j-1 do
                if tby[k]=0 then tby[k]:=32;
              st:=tencoding.Default.GetString(tbytes(tby));
              MYform.mmo1.Lines.Add(inttostr(l)+':'+st);
             i:=0;
}              l:=l+1;
             //  MYform.mmo1.Lines.Add(Format('%d:内存流大小：%d',[l,tm.Size]));
            end
          else
            begin
              if not isnodata then
              begin
                k:=GetTickCount;
                isnodata:=True;
              end;
              j:=GetTickCount-j;
              MYform.mmo1.Lines.Add(Format('%d:buffer空了,耗时%d毫秒',[l,j]));
              j:=GetTickCount;
              sleep(40);
              Application.ProcessMessages;
            end;
          endtime:=GetTickCount;
          if isnodata and ((endtime-k)>6000) then Break;
          if (endtime-i)>2500 then
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
function TMyThread.make_data(AClient: TIdTCPClient): Boolean;
type
  TarrMDEntry=array of MDEntry;
var
  st:string;
  trans64:uin64;
  dataIStrue: Boolean;
  i,j,k,m:integer;
  tby:TIdBytes;
  lg:login;
  lg_body:login_body;
  ch_heat_body:Channel_Heartbeat;
  stock_body:stock_data;
  mden_body:MDEntry;
  mdenarr:Tarrmdentry;
  chk,msg_type,body_ln,l:UInt32;
  login_frm:Tlogin;
  l2_wt:wt_l2;
  trans1,trans2:uin32;
begin
  msg_type:=MYform.idtcpclnt1.Socket.ReadInt32();
  body_ln:=MYform.idtcpclnt1.Socket.ReadInt32();
  dataIStrue:=False;
  case msg_type of
  1     :begin
         dataIStrue:=readbuff<login_body>(AClient,lg_body,msg_type,body_ln);
         {if dataIStrue then
         MYform.mmo1.Lines.Add(Format('msg_type=%d,body_ln=%d,SenderCompID=%s,TargetCompID=%s,HeartBtInt=%d,Password=%s,DefaultApplVerID=%s',
                                      [msg_type,body_ln,trim(lg_body.SenderCompID),trim(lg_body.TargetCompID),NET2CPU(lg_body.HeartBtInt),trim(lg_body.Password),trim(lg_body.DefaultApplVerID)]));
         }end;
  3     :begin
         chk:=MYform.idtcpclnt1.Socket.ReadInt32();
         if chk=3 then MYform.mmo1.Lines.Add('收到心跳');
         end;
  300192:begin
           dataIStrue:=readbuff<wt_l2>(AClient,l2_wt,msg_type,body_ln);
           {if dataIStrue then
           MYform.mmo1.Lines.Add(Format('msg_type=%d,body_ln=%d,ChannelNo=%d,ApplSeqNum=%d,MDStreamID=%s,SecurityID=%s,SecurityIDSource=%s,Price=%.4n,OrderQty=%d,Side=%s,TransactTime=%d,OrdType=%s',
                                      [msg_type,body_ln,NET2CPU(l2_wt.ChannelNo),NET2CPU(l2_wt.ApplSeqNum),trim(l2_wt.MDStreamID),trim(l2_wt.SecurityID),trim(l2_wt.SecurityIDSource),(NET2CPU(l2_wt.Price)/10000.00),NET2CPU(l2_wt.OrderQty),l2_wt.Side,NET2CPU(l2_wt.TransactTime),l2_wt.OrdType]));
            }
         end;
  300111:begin
          trans1.i32:=msg_type;
          trans2.i32:=body_ln;
          l:=SizeOf(stock_body);
          for I := 3 downto 0 do
           begin
            chk:=chk+trans1.by32[i];
            chk:=chk+trans2.by32[i];
           end;
          setlength(tby,0);
          SetLength(tby,l);
          recvbuff(MYform.idtcpclnt1,tby,chk);
          BytesToRaw(tby,stock_body,l);
          stock_body.OrigTime:=NET2CPU(stock_body.OrigTime);
          stock_body.ChannelNo:=NET2CPU(stock_body.ChannelNo);
          stock_body.PrevClosePx:=NET2CPU(stock_body.PrevClosePx);
          stock_body.NumTrades:=NET2CPU(stock_body.NumTrades);
          stock_body.TotalVolumeTrade:=NET2CPU(stock_body.TotalVolumeTrade);
          stock_body.TotalValueTrade:=NET2CPU(stock_body.TotalValueTrade);
          stock_body.NoMDEntries:=NET2CPU(stock_body.NoMDEntries);
          {st:=Format('msg_type=%d,body_ln=%d,OrigTime=%d,ChannelNo=%d,MDStreamID=%s,SecurityID=%s,SecurityIDSource=%s,TradingPhaseCode=%s,PrevClosePx=%.4n,NumTrades=%d,TotalVolumeTrade=%.2n,TotalValueTrade=%.4n,NoMDEntries=%d',
                     [msg_type,body_ln,stock_body.OrigTime,stock_body.ChannelNo,trim(stock_body.MDStreamID),Trim(stock_body.SecurityID),trim(stock_body.SecurityIDSource),trim(stock_body.TradingPhaseCode),stock_body.PrevClosePx/10000.00,stock_body.NumTrades,stock_body.TotalVolumeTrade/100.00,stock_body.TotalValueTrade/10000.00,stock_body.NoMDEntries]);
          MYform.mmo1.Lines.Add(st);}
          setlength(mdenarr,0);
          SetLength(mdenarr,stock_body.NoMDEntries);
          j:=SizeOf(MDEntry);
          l:=l+j*stock_body.NoMDEntries;
          for I := 0 to stock_body.NoMDEntries-1 do
            begin
              SetLength(tby,0);
              SetLength(tby,j);
              recvbuff(MYform.idtcpclnt1,tby,chk);
              BytesToRaw(tby,mdenarr[i],j);
              mdenarr[i].MDEntryPx:=NET2CPU(mdenarr[i].MDEntryPx);
              mdenarr[i].MDEntrySize:=NET2CPU(mdenarr[i].MDEntrySize);
              mdenarr[i].MDPriceLevel:=NET2CPU(mdenarr[i].MDPriceLevel);
              mdenarr[i].NumberOfOrders:=NET2CPU(mdenarr[i].NumberOfOrders);
              mdenarr[i].NoOrders:=NET2CPU(mdenarr[i].NoOrders);
              mden_body:=mdenarr[i];
              {st:=Format('MDEntrieno=%d,MDEntryType=%s,MDEntryPx=%.6n,MDEntrySize=%d,MDPriceLevel=%d,NumberOfOrders=%d,NoOrders=%d',
                         [i+1,trim(mden_body.MDEntryType),mden_body.MDEntryPx/1000000.00,mden_body.MDEntrySize,mden_body.MDPriceLevel,mden_body.NumberOfOrders,mden_body.NoOrders]);
               }if mdenarr[i].NoOrders<>0 then
               for m:= 0 to mdenarr[i].NoOrders-1 do
                begin
                  trans64.i64:=MYform.idtcpclnt1.Socket.ReadInt64;
                  inc(l,4);
                //  st:=st+format('笔数%d：%d',[m,trans64.i64]);
                  for k:=7 downto 0 do  chk:=chk+trans64.by64[k];
                end;
             //MYform.mmo1.Lines.Add(st);
            end;
          l:=MYform.idtcpclnt1.Socket.ReadInt32;
          chk:=chk mod 256;
          {if l=chk then
             MYform.mmo1.Lines.Add('数据正确')
          else
             MYform.mmo1.Lines.Add('数据校验错误');}
         end;

  else
    //MYform.mmo1.Lines.Add(Format('不明类别，类别号：%d,长度：%d',[msg_type,body_ln]));
    setlength(tby,0);
    MYform.idtcpclnt1.Socket.ReadBytes(tby,body_ln);
    chk:=MYform.idtcpclnt1.Socket.ReadInt32(False);
    tm.Write(TBy[0],length(tby));
    tm.Write(chk,SizeOf(chk));
  end;

end;

function TMyThread.readbuff<T>(AClient: TIdTCPClient;var value:T;msgtype,buff_len: UInt32): Boolean;
var
 tb1:TIdBytes;
 j,check:UInt32;
 trans1,trans2:uin32;
  I: Integer;
begin
  Result:=false;
  if SizeOf(value)<>buff_len then Exit;
  check:=0;
  j:=0;
  trans1.i32:=msgtype;
  trans2.i32:=buff_len;
  for I := 3 downto 0 do
    begin
     check:=check+trans1.by32[i];
     check:=check+trans2.by32[i];
    end;
  SetLength(tb1,buff_len);
  recvbuff(AClient,tb1,check);
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

procedure TMyThread.recvbuff(AClient: TIdTCPClient; buff: TIdBytes;
  var chk: UInt32);
var
  I,j: Integer;
begin
  j:=Length(buff);
  AClient.IOHandler.ReadBytes(buff,j,False);
  for I := 0 to j-1 do chk:=chk+buff[i];
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
