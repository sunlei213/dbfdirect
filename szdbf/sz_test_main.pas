unit sz_test_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,sz_fix, Vcl.StdCtrls,IdGlobal,system.Diagnostics,
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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TMyThread = class(TThread)
  private
    function readbuff<T>(AClient: TIdTCPClient;var value:T;msgtype,buff_len:UInt32):Boolean;
    function make_data(AClient: TIdTCPClient):Boolean;
    procedure recvbuff(AClient:TIdTCPClient;buff:TIdBytes;var chk:UInt32);
    function check(value:TIdBytes;chk:UInt32):UInt32;
  protected
    procedure Execute; override;
    procedure showmsg(st:string);
  end;

var
  MYform: TMYform;
  myth1:tmythread;
  tm:TMemoryStream;
implementation
uses
  sz_interface;
{$R *.dfm}

{ TMyThread }

procedure TMyThread.Execute;
var
  i, k, endtime: integer;
  j:UInt64;
  tim:TStopwatch;
  tby, t_heat: TIdBytes;
  lg: login;
  chk, msg_type, body_ln, l: UInt32;
  login_frm: Tlogin;
  isnodata,dateIStrue: Boolean;
begin
  inherited;
  FreeOnTerminate := True;
  SetLength(t_heat, 12);
  FillBytes(t_heat, 12, 0);
  t_heat[3] := 3;
  t_heat[11] := 3;
  MYform.idtcpclnt1.Host := '127.0.0.1';
  MYform.idtcpclnt1.Port := 8016;
  try
    msg_type := 1;
    body_ln := 92;
    l := 3;
    lg.l_head.MsgType := NET2CPU(msg_type);
    lg.l_head.BodyLength := NET2CPU(body_ln);
    strtospace('resend', Length(lg.SenderCompID), lg.SenderCompID);
    strtospace('mdgw11', Length(lg.TargetCompID), lg.TargetCompID);
    strtospace('mdgw11', Length(lg.Password), lg.Password);
    lg.HeartBtInt := NET2CPU(l);
    strtospace('1.00', Length(lg.DefaultApplVerID), lg.DefaultApplVerID);
    tby:=RawToBytes(lg,SizeOf(lg));
    chk := check(tby,0);
    login_frm.TL_body := lg;
    login_frm.TL_Check := NET2CPU(chk);
    tby := RawToBytes(login_frm, SizeOf(login_frm));
    MYform.idtcpclnt1.Connect;
//    MYform.idtcpclnt1.Socket.DefStringEncoding:=IdGlobal.IndyTextEncoding_UTF8();
    MYform.idtcpclnt1.Socket.Write(tby);
    l := 0;
    i := GetTickCount;
    k := i;
    isnodata:=True;
    tim:=TStopWatch.Create;
    try
      begin
        while not Self.Terminated do
        begin
          MYform.idtcpclnt1.Socket.CheckForDataOnSource;
          if not MYform.idtcpclnt1.Socket.InputBufferIsEmpty then
          begin
            if isnodata then
              begin
                isnodata := False;
                tim.Start;
              end;

            dateIStrue:=make_data(MYform.idtcpclnt1);
            l := l + 1;
            if not dateIStrue then
              MYform.mmo1.Lines.Add('数据不正确');
          end
          else
          begin
            if not isnodata then
            begin
              k := GetTickCount;
              isnodata := True;
              tim.Stop;
              j:=tim.ElapsedMilliseconds;
              tim.Reset;
              MYform.mmo1.Lines.Add(Format('%d:buffer空了,耗时%d毫秒', [l, j]));
            end;
            sleep(10);
            Application.ProcessMessages;
          end;
          endtime := GetTickCount;
          if isnodata and ((endtime - k) > 6000) then
            Break;
          if (endtime - i) > 2500 then
          begin
            i := GetTickCount;
            MYform.idtcpclnt1.Socket.WriteDirect(t_heat);
          end;

          if self.Terminated then
            break;
        end;
      end;
    finally
      begin
        MYform.idtcpclnt1.Disconnect;
        Synchronize(
          procedure
          begin
            showmessage('进程结束');
          end);
      end;
    end;
  except
    Synchronize(
      procedure
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
var
  chk, msg_type, body_ln: UInt32;
  dataIStrue: Boolean;
  tby: TIdBytes;
  lg_body: login_body;
  ch_heat_body: Channel_Heartbeat;
  l2_wt: wt_l2;
  data_make:Idata_make;
  tran32:uin32;
begin
  msg_type := AClient.Socket.ReadInt32();
  body_ln := AClient.Socket.ReadInt32();
  dataIStrue := False;
  case msg_type of
    1: //登陆返回信息
      begin
        dataIStrue := readbuff<login_body>(AClient, lg_body, msg_type, body_ln);
         {if dataIStrue then
         MYform.mmo1.Lines.Add(Format('msg_type=%d,body_ln=%d,SenderCompID=%s,TargetCompID=%s,HeartBtInt=%d,Password=%s,DefaultApplVerID=%s',
                                      [msg_type,body_ln,trim(lg_body.SenderCompID),trim(lg_body.TargetCompID),NET2CPU(lg_body.HeartBtInt),trim(lg_body.Password),trim(lg_body.DefaultApplVerID)]));
         }
      end;
    3: //心跳
      begin
        chk := MYform.idtcpclnt1.Socket.ReadInt32();
        dataIStrue:=(chk = 3);
        if dataIStrue then
          MYform.mmo1.Lines.Add('收到心跳');
      end;
    300192: //逐笔委托行情
      begin
        dataIStrue := readbuff<wt_l2>(AClient, l2_wt, msg_type, body_ln);
           {if dataIStrue then
           MYform.mmo1.Lines.Add(Format('msg_type=%d,body_ln=%d,ChannelNo=%d,ApplSeqNum=%d,MDStreamID=%s,SecurityID=%s,SecurityIDSource=%s,Price=%.4n,OrderQty=%d,Side=%s,TransactTime=%d,OrdType=%s',
                                      [msg_type,body_ln,NET2CPU(l2_wt.ChannelNo),NET2CPU(l2_wt.ApplSeqNum),trim(l2_wt.MDStreamID),trim(l2_wt.SecurityID),trim(l2_wt.SecurityIDSource),(NET2CPU(l2_wt.Price)/10000.00),NET2CPU(l2_wt.OrderQty),l2_wt.Side,NET2CPU(l2_wt.TransactTime),l2_wt.OrdType]));
            }
      end;
//    300111,309011,309111:dataIStrue:=get_stock_hq(AClient, msg_type, body_ln);
    300111:
      begin
        data_make:=Tstock_hq.Create(AClient);
        dataIStrue:=data_make.getdate(body_ln);
      end;
    309011:
      begin
        data_make:=Tstock_zs.Create(AClient);
        dataIStrue:=data_make.getdate(body_ln);
      end;
    309111: //行情快照,指数行情,成交量统计指标行情
      begin
        data_make:=Tstock_zsvol.Create(AClient);
        dataIStrue:=data_make.getdate(body_ln);
        //dataIStrue:=get_stock_hq(AClient, msg_type, body_ln);
      end;
    390013: //证券实时状态
      begin
        data_make:=TStockStatus.Create(AClient);
        dataIStrue:=data_make.getdate(body_ln);
      end;

  else
    //MYform.mmo1.Lines.Add(Format('不明类别，类别号：%d,长度：%d',[msg_type,body_ln]));
    tm.Write(msg_type, SizeOf(msg_type));
    tm.Write(body_ln, SizeOf(body_ln));
    setlength(tby, 0);
    AClient.Socket.ReadBytes(tby, body_ln);
    tran32.i32:=msg_type;
    chk:=tran32.by32[3]+tran32.by32[2]+tran32.by32[1]+tran32.by32[0];
    tran32.i32:=body_ln;
    chk:=chk+tran32.by32[3]+tran32.by32[2]+tran32.by32[1]+tran32.by32[0];
    tran32.i32:=check(tby,chk);
    chk := AClient.Socket.ReadInt32();
    dataIStrue:=(tran32.i32=chk);
    tm.Write(TBy[0], length(tby));
    tm.Write(chk, SizeOf(chk));

  end;

  Result:=dataIStrue;
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

function TMYThread.check(value: TIdBytes; chk:UInt32): UInt32;
var
i,j:Integer;
begin
  j:=length(value);
  Result:=chk;
  for I := 0 to j-1 do Result:=Result+value[i];
  Result:=Result mod 256;
end;

{ TMYform }

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


procedure TMYform.btn2Click(Sender: TObject);
begin
  if myth1<>nil then
   myth1.Terminate;
  btn1.Enabled:=True;
  btn2.Enabled:=False;
  tm.SaveToFile('d:\sl.dat');
end;

procedure TMYform.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 tm.Free;
end;

procedure TMYform.FormCreate(Sender: TObject);
begin
 tm:=TMemoryStream.Create;

end;

end.
