unit mystock.classes;
interface

uses
  mystock.types, mystock.interfaces, IdGlobal, IdTCPClient, Generics.Collections,
  ArrayEx, System.SysUtils, System.Variants, System.Classes, system.Math;

type
  Trecive_net = class(TInterfacedObject, Idata_recive)
  private
          { private declarations }
    fAC:TIdTCPClient;
    sev_heart,cli_heart:integer;
    islogin,isnodata:Boolean;
    fdataIStrue:Boolean;
    fip:string;
    fport:Integer;
    fheart:UInt32;
    ftype_coun:tstringlist;
    fvisiters:tlist<Ivisiter>;
    fuser,fpasswd:string;
    function send_login:Boolean;
    function check(value: TIdBytes; chk:UInt32): UInt32;
    function make_data:Idata_CMD;
    function readbuff<T>(var value:T;msgtype,buff_len: UInt32): Boolean;
    procedure recvbuff(buff: TIdBytes;var chk: UInt32);
  protected
          { protected declarations }
  public
          { public declarations }
    constructor Create;
    destructor Destroy; override;
    procedure vi_reg(vi:ivisiter);
    function start: Boolean;
    function stop: Boolean;
    function make_command: Idata_CMD;
    property ip:string read fip write fip;
    property port:Integer read fport write fport;
    property heart:UInt32 read fheart write fheart;
    property user:string write fuser;
    property passwd:string write fpasswd;
    property dataIStrue:Boolean read fdataIStrue;
  end;

  Tstock_hq = class(Tstock)
  private
    stock_body: stock_data;
    mden_body: MDEntry;
    data_size, hq_size: Integer;
  protected
  public
    constructor Create(AClient: TIdTCPClient);
    function getdate(body_ln: UInt32): Boolean; override;
  end;

  Tstock_zs = class(Tstock)
  private
    stock_body: stock_data;
    hq: hq_MDEntry;
    data_size, hq_size: Integer;
  protected
  public
    constructor Create(AClient: TIdTCPClient);
    function getdate(body_ln: UInt32): Boolean; override;
  end;

  Tstock_zsvol = class(Tstock)
  private
    stock_body: stock_data;
    data_size: Integer;
  protected
  public
    constructor Create(AClient: TIdTCPClient);
    function getdate(body_ln: UInt32): Boolean; override;
  end;


{ TStockStatus }

  TStockStatus = class(Tstock)
  private
    stock_body: StockStatus;
    data_size: Integer;
  protected
  public
    constructor Create(AClient: TIdTCPClient);
    function getdate(body_ln: UInt32): Boolean; override;
  end;

{ TSjshqwrite }

  TSjshqWrite = class(TInterfacedObject, Idata_trans)
  private
    max_cov_num: Integer;
  protected
  public
    constructor Create(cover_num: Integer);
    function cover_data(d_map: TDictionary<string, tarrayex<variant>>; queue: TQueue<tarrayex<Variant>>): Integer;
    function write_dbf(filename: string): Boolean;
  end;

{ TSjsxxwrite }

  TSjsxxWrite = class(TInterfacedObject, Idata_trans)
  private
    max_cov_num: Integer;
  protected
  public
    constructor Create(cover_num: Integer);
    function cover_data(d_map: TDictionary<string, tarrayex<variant>>; queue: TQueue<tarrayex<Variant>>): Integer;
    function write_dbf(filename: string): Boolean;
  end;

implementation
uses
  mystock.commands;
{ Tstock_hq }

constructor Tstock_hq.Create(AClient: TIdTCPClient);
begin
  inherited Create(AClient, 300111);
  data_size := SizeOf(stock_data);
  hq_size := SizeOf(MDEntry);
end;

function Tstock_hq.getdate(body_ln: UInt32): Boolean;
var
  trans1: uin32;
  trans64: uin64;
  l: UInt32;
  I: Integer;
  m: Integer;
  k: Integer;
begin
  trans1.i32 := body_ln;
  chk := chk + trans1.by32[3] + trans1.by32[2] + trans1.by32[1] + trans1.by32[0];
  SetLength(tby, data_size);
  recvbuff;
  BytesToRaw(tby, stock_body, data_size);
  stock_body.OrigTime := NET2CPU(stock_body.OrigTime);
  stock_body.ChannelNo := NET2CPU(stock_body.ChannelNo);
  stock_body.PrevClosePx := NET2CPU(stock_body.PrevClosePx);
  stock_body.NumTrades := NET2CPU(stock_body.NumTrades);
  stock_body.TotalVolumeTrade := NET2CPU(stock_body.TotalVolumeTrade);
  stock_body.TotalValueTrade := NET2CPU(stock_body.TotalValueTrade);
  stock_body.NoMDEntries := NET2CPU(stock_body.NoMDEntries);
  for I := 0 to stock_body.NoMDEntries - 1 do
  begin
    SetLength(tby, 0);
    SetLength(tby, hq_size);
    recvbuff;
    BytesToRaw(tby, mden_body, hq_size);
    mden_body.MDEntryPx := NET2CPU(mden_body.MDEntryPx);
    mden_body.MDEntrySize := NET2CPU(mden_body.MDEntrySize);
    mden_body.MDPriceLevel := NET2CPU(mden_body.MDPriceLevel);
    mden_body.NumberOfOrders := NET2CPU(mden_body.NumberOfOrders);
    mden_body.NoOrders := NET2CPU(mden_body.NoOrders);
        //mden_body := mdenarr[i];
         {st:=Format('MDEntrieno=%d,MDEntryType=%s,MDEntryPx=%.6n,MDEntrySize=%d,MDPriceLevel=%d,NumberOfOrders=%d,NoOrders=%d',
                     [i+1,trim(mden_body.MDEntryType),mden_body.MDEntryPx/1000000.00,mden_body.MDEntrySize,mden_body.MDPriceLevel,mden_body.NumberOfOrders,mden_body.NoOrders]);
           }
    if mden_body.NoOrders <> 0 then
      for m := 0 to mden_body.NoOrders - 1 do
      begin
        trans64.i64 := AClient.Socket.ReadInt64;
          //  st:=st+format('笔数%d：%d',[m,trans64.i64]);
        for k := 7 downto 0 do
          chk := chk + trans64.by64[k];
      end;
  end;
  l := AClient.Socket.ReadInt32;
  chk := chk mod 256;
  Result := (l = chk);
end;



{ Tstock_zs }

constructor Tstock_zs.Create(AClient: TIdTCPClient);
begin
  inherited Create(AClient, 309011);
  data_size := SizeOf(stock_data);
  hq_size := SizeOf(hq_MDEntry);
end;

function Tstock_zs.getdate(body_ln: UInt32): Boolean;
var
  trans1: uin32;
  l: UInt32;
  I: Integer;
begin
  trans1.i32 := body_ln;
  chk := chk + trans1.by32[3] + trans1.by32[2] + trans1.by32[1] + trans1.by32[0];
  SetLength(tby, data_size);
  recvbuff;
  BytesToRaw(tby, stock_body, data_size);
  stock_body.OrigTime := NET2CPU(stock_body.OrigTime);
  stock_body.ChannelNo := NET2CPU(stock_body.ChannelNo);
  stock_body.PrevClosePx := NET2CPU(stock_body.PrevClosePx);
  stock_body.NumTrades := NET2CPU(stock_body.NumTrades);
  stock_body.TotalVolumeTrade := NET2CPU(stock_body.TotalVolumeTrade);
  stock_body.TotalValueTrade := NET2CPU(stock_body.TotalValueTrade);
  stock_body.NoMDEntries := NET2CPU(stock_body.NoMDEntries);
  for I := 0 to stock_body.NoMDEntries - 1 do
  begin
    SetLength(tby, 0);
    SetLength(tby, hq_size);
    recvbuff;
    BytesToRaw(tby, hq, hq_size);
    hq.MDEntryPx := NET2CPU(hq.MDEntryPx);

      //hq := mdenarr[i];
       {st:=Format('MDEntrieno=%d,MDEntryType=%s,MDEntryPx=%.6n,MDEntrySize=%d,MDPriceLevel=%d,NumberOfOrders=%d,NoOrders=%d',
                   [i+1,trim(hq.MDEntryType),hq.MDEntryPx/1000000.00,hq.MDEntrySize,hq.MDPriceLevel,hq.NumberOfOrders,hq.NoOrders]);
         }
  end;
  l := AClient.Socket.ReadInt32;
  chk := chk mod 256;
  Result := (l = chk);
end;

{ Tstock_zsvol }

constructor Tstock_zsvol.Create(AClient: TIdTCPClient);
begin
  inherited Create(AClient, 309011);
  data_size := SizeOf(stock_data);
end;

function Tstock_zsvol.getdate(body_ln: UInt32): Boolean;
var
  trans1: uin32;
  l: UInt32;
begin
  trans1.i32 := body_ln;
  chk := chk + trans1.by32[3] + trans1.by32[2] + trans1.by32[1] + trans1.by32[0];
  SetLength(tby, data_size);
  recvbuff;
  BytesToRaw(tby, stock_body, data_size);
  stock_body.OrigTime := NET2CPU(stock_body.OrigTime);
  stock_body.ChannelNo := NET2CPU(stock_body.ChannelNo);
  stock_body.PrevClosePx := NET2CPU(stock_body.PrevClosePx);
  stock_body.NumTrades := NET2CPU(stock_body.NumTrades);
  stock_body.TotalVolumeTrade := NET2CPU(stock_body.TotalVolumeTrade);
  stock_body.TotalValueTrade := NET2CPU(stock_body.TotalValueTrade);
  stock_body.NoMDEntries := NET2CPU(stock_body.NoMDEntries);
  l := AClient.Socket.ReadInt32;
  chk := chk mod 256;
  Result := (l = chk);

end;

{ TStockStatus }

constructor TStockStatus.Create(AClient: TIdTCPClient);
begin
  inherited Create(AClient, 390013);
  data_size := SizeOf(stock_data);
end;

function TStockStatus.getdate(body_ln: UInt32): Boolean;
var
  trans1: uin32;
  trans16: uin16;
  l: UInt32;
  I: Integer;
begin
  trans1.i32 := body_ln;
  chk := chk + trans1.by32[3] + trans1.by32[2] + trans1.by32[1] + trans1.by32[0];
  SetLength(tby, data_size);
  recvbuff;
  BytesToRaw(tby, stock_body, data_size);
  stock_body.OrigTime := NET2CPU(stock_body.OrigTime);
  stock_body.ChannelNo := NET2CPU(stock_body.ChannelNo);
  stock_body.NoSwitch := NET2CPU(stock_body.NoSwitch);
  for I := 0 to stock_body.NoSwitch - 1 do
  begin
    trans16.i16 := AClient.Socket.ReadInt16();
    chk := chk + trans16.by16[1] + trans16.by16[0];
    trans16.i16 := AClient.Socket.ReadInt16();
    chk := chk + trans16.by16[1] + trans16.by16[0];
  end;
  l := AClient.Socket.ReadInt32;
  chk := chk mod 256;
  Result := (l = chk);
end;


{ TSjshqWrite }

function TSjshqWrite.cover_data(d_map: TDictionary<string, tarrayex<variant>>; queue: TQueue<tarrayex<Variant>>): Integer;
var
  my_data, tmp_data: TArrayEx<Variant>;
  I, j, k: Integer;
begin
  j := Min(max_cov_num, queue.Count);
  Result := 0;
  for I := 0 to j - 1 do
  begin
    if queue.Count = 0 then
      Break;
    my_data := queue.Dequeue;
    if d_map.ContainsKey(my_data[0]) then
    begin
      tmp_data := d_map.Items[my_data[0]];
      for k := 0 to my_data.Len - 1 do
        tmp_data[k] := my_data[k];
    end;

    Result := Result + 1;

  end;
end;

constructor TSjshqWrite.Create(cover_num: Integer);
begin
  inherited Create;
  max_cov_num := cover_num;
end;

function TSjshqWrite.write_dbf(filename: string): Boolean;
begin

end;

{ TSjsxxWrite }

function TSjsxxWrite.cover_data(d_map: TDictionary<string, tarrayex<variant>>; queue: TQueue<tarrayex<Variant>>): Integer;
begin

end;

constructor TSjsxxWrite.Create(cover_num: Integer);
begin
  inherited Create;
  max_cov_num := cover_num;
end;

function TSjsxxWrite.write_dbf(filename: string): Boolean;
begin
end;


{ Trecive_net }

function Trecive_net.check(value: TIdBytes; chk: UInt32): UInt32;
var
i,j:Integer;
begin
  j:=length(value);
  Result:=chk;
  for I := 0 to j-1 do Result:=Result+value[i];
  Result:=Result mod 256;
end;


constructor Trecive_net.Create;
begin
  inherited;
  fAC:=TIdTCPClient.Create(nil);
  islogin:=False;
  isnodata:=True;
  fdataIStrue:=False;
  ftype_coun:=TStringList.Create;
  fvisiters:=TList<Ivisiter>.Create;
end;

destructor Trecive_net.Destroy;
begin
  fvisiters.Clear;
  fvisiters.Free;
  ftype_coun.Free;
  fAC.Free;
  inherited;
end;

function Trecive_net.make_command: Idata_CMD;
var
  t_heat: TIdBytes;
  endtime:Integer;
begin
  SetLength(t_heat, 12);
  FillBytes(t_heat, 12, 0);
  t_heat[3] := 3;
  t_heat[11] := 3;
  fAC.Socket.CheckForDataOnSource;
  if not fAC.Socket.InputBufferIsEmpty then
  begin
    if isnodata then
    begin
      isnodata := False;
    end;
    Result := make_data;
  end
  else
  begin
    if not isnodata then
    begin
      sev_heart := TThread.GetTickCount;
      isnodata := True;
    end;
    sleep(10);
    Result:=tnocmd.Create
  end;
  endtime := TThread.GetTickCount;
  if isnodata and ((endtime - sev_heart) > heart * 2) then
    fdataIStrue := False;
  if (endtime - cli_heart) > heart then
  begin
    cli_heart := TThread.GetTickCount;
    fAC.Socket.WriteDirect(t_heat);
  end;

end;

function Trecive_net.make_data: Idata_CMD;
var
  chk, msg_type, body_ln: UInt32;
  tby: TIdBytes;
  lg_body: login_body;
  ch_heat_body: Channel_Heartbeat;
  l2_wt: wt_l2;
  data_make:Idata_make;
  tran32:uin32;
begin
  msg_type := fAC.Socket.ReadInt32();
  body_ln := fAC.Socket.ReadInt32();
  fdataIStrue := False;
  case msg_type of
    1: //登陆返回信息
      begin
        fdataIStrue := readbuff<login_body>(lg_body, msg_type, body_ln);
        islogin:=True;
        Result:=tnocmd.Create;
         {if fdataIStrue then
         MYform.mmo1.Lines.Add(Format('msg_type=%d,body_ln=%d,SenderCompID=%s,TargetCompID=%s,HeartBtInt=%d,Password=%s,DefaultApplVerID=%s',
                                      [msg_type,body_ln,trim(lg_body.SenderCompID),trim(lg_body.TargetCompID),NET2CPU(lg_body.HeartBtInt),trim(lg_body.Password),trim(lg_body.DefaultApplVerID)]));
         }
      end;
    3: //心跳
      begin
        chk := fac.Socket.ReadInt32();
        fdataIStrue:=(chk = 3);
        Result:=tnocmd.Create;
      end;
    300192: //逐笔委托行情
      begin
        fdataIStrue := readbuff<wt_l2>(l2_wt, msg_type, body_ln);
           {if fdataIStrue then
           MYform.mmo1.Lines.Add(Format('msg_type=%d,body_ln=%d,ChannelNo=%d,ApplSeqNum=%d,MDStreamID=%s,SecurityID=%s,SecurityIDSource=%s,Price=%.4n,OrderQty=%d,Side=%s,TransactTime=%d,OrdType=%s',
                                      [msg_type,body_ln,NET2CPU(l2_wt.ChannelNo),NET2CPU(l2_wt.ApplSeqNum),trim(l2_wt.MDStreamID),trim(l2_wt.SecurityID),trim(l2_wt.SecurityIDSource),(NET2CPU(l2_wt.Price)/10000.00),NET2CPU(l2_wt.OrderQty),l2_wt.Side,NET2CPU(l2_wt.TransactTime),l2_wt.OrdType]));
            }
      end;
//    300111,309011,309111:fdataIStrue:=get_stock_hq(fAC, msg_type, body_ln);
    300111: //行情快照
      begin
        data_make:=Tstock_hq.Create(fAC);
        fdataIStrue:=data_make.getdate(body_ln);
      end;
    309011:  //指数行情
      begin
        data_make:=Tstock_zs.Create(fAC);
        fdataIStrue:=data_make.getdate(body_ln);
      end;
    309111: //成交量统计指标行情
      begin
        data_make:=Tstock_zsvol.Create(fAC);
        fdataIStrue:=data_make.getdate(body_ln);
        //fdataIStrue:=get_stock_hq(fAC, msg_type, body_ln);
      end;
    390013: //证券实时状态
      begin
        data_make:=TStockStatus.Create(fAC);
        fdataIStrue:=data_make.getdate(body_ln);
      end;

  else
    setlength(tby, 0);
    fAC.Socket.ReadBytes(tby, body_ln);
    tran32.i32:=msg_type;
    chk:=tran32.by32[3]+tran32.by32[2]+tran32.by32[1]+tran32.by32[0];
    tran32.i32:=body_ln;
    chk:=chk+tran32.by32[3]+tran32.by32[2]+tran32.by32[1]+tran32.by32[0];
    tran32.i32:=check(tby,chk);
    chk := fAC.Socket.ReadInt32();
    fdataIStrue:=(tran32.i32=chk);
    Result:=tnocmd.Create;
  end;

end;

function Trecive_net.readbuff<T>(var value: T; msgtype,
  buff_len: UInt32): Boolean;
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
  recvbuff(tb1,check);
  j:=check mod 256;
  check:=fAC.IOHandler.ReadInt32();
  if j<>check then Exit;
  try
  BytesToRaw(tb1,value,buff_len);
  Result:=True;
  except
  Result:=False;
  end;
end;


procedure Trecive_net.recvbuff(buff: TIdBytes; var chk: UInt32);
var
  I,j: Integer;
begin
  j:=Length(buff);
  fAC.IOHandler.ReadBytes(buff,j,False);
  for I := 0 to j-1 do chk:=chk+buff[i];
end;


function Trecive_net.send_login: Boolean;
var
  lg: login;
  tby:TIdBytes;
  chk:UInt32;
begin
  lg.l_head.MsgType:=NET2CPU(Cardinal(1));
  lg.l_head.BodyLength:=NET2CPU(Cardinal(92));
  strtospace('resend', Length(lg.SenderCompID), lg.SenderCompID);
  strtospace(fuser, Length(lg.TargetCompID), lg.TargetCompID);
  strtospace(fpasswd, Length(lg.Password), lg.Password);
  lg.HeartBtInt := NET2CPU(fheart);
  strtospace('1.00', Length(lg.DefaultApplVerID), lg.DefaultApplVerID);
  tby:=RawToBytes(lg,SizeOf(lg));
  chk := check(tby,0);
  try
  fAC.Socket.Write(tby);
  fAC.Socket.Write(chk);
  except
  Exit(False);
  end;
  Result:=True;
end;

function Trecive_net.start: Boolean;
begin
  if (not fAC.Connected) then
    if (fip<>'') and (fport<>0) then
      begin
        fAC.Host:=fip;
        fAC.Port:=fport;
        try
          fAC.Connect;
        except
          Exit(False);
        end;
        Result:=send_login;
      end;
  sev_heart:=TThread.GetTickCount;
  cli_heart:=sev_heart;
end;

function Trecive_net.stop: Boolean;
begin
  if fAC.Connected then
    fAC.Disconnect;
end;

procedure Trecive_net.vi_reg(vi: ivisiter);
begin
  fvisiters.Add(vi);
end;

end.
