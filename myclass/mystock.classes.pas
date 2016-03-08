unit mystock.classes;
interface

uses
   mystock.interfaces, IdGlobal, IdTCPClient, Generics.Collections,
  ArrayEx, System.SysUtils, mystock.types,System.Variants, System.Classes, system.Math;

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
    ftype_coun:TDictionary<Integer,Integer>;
    fvisiters:tlist<Ivisiter>;
    fuser,fpasswd:string;
    fstatus:rec_stat;
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
    function getstatus:rec_stat;
    property ip:string read fip write fip;
    property port:Integer read fport write fport;
    property heart:UInt32 read fheart write fheart;
    property user:string write fuser;
    property passwd:string write fpasswd;
    property dataIStrue:Boolean read fdataIStrue;
  end;

  Trecive_file = class(TInterfacedObject, Idata_recive)
  private
          { private declarations }
    flines: TStringList;
    fType:Integer;
    frecno:Integer;
    fdataIStrue:Boolean;
    ffilenames:TStringList;
    ftype_coun:TDictionary<Integer,Integer>;
    fvisiters:tlist<Ivisiter>;
    fstatus:rec_stat;
    T1IOPVMap,IOPVMap:TDictionary<string,string>;
    isclose:Boolean;
    jydate:string;
    function make_data:Idata_CMD;
    function convertMktdtRecord2Map(rec:String):TArrayEx<Variant>;
    function convertFJYRecord2Map(rec:string):TArrayEx<Variant>;
    function setFirstRecVal(firstRec,szTradePrice,agTradePrice,bgTradePrice:string):tarrayex<variant>;
    function firstRecValFormat(headVals:TArrayEx<string>):tarrayex<variant>;
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
    function getstatus:rec_stat;
    property filenames:TStringList read ffilenames write ffilenames;
    property dataIStrue:Boolean read fdataIStrue;
  end;

  Tstock_hq = class(Tstock)
  private
    stock_body: stock_data;
    mden_body: TArrayEx<MDEntry>;
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
  mystock.commands,Data.FmtBcd;
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
  hq_md: MDEntry;
  sl: Char;
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
  mden_body.SetLen(stock_body.NoMDEntries);
  for I := 0 to stock_body.NoMDEntries - 1 do
  begin
    SetLength(tby, 0);
    SetLength(tby, hq_size);
    recvbuff;
    BytesToRaw(tby, hq_md, hq_size);
    hq_md.MDEntryPx := NET2CPU(hq_md.MDEntryPx);
    hq_md.MDEntrySize := NET2CPU(hq_md.MDEntrySize);
    hq_md.MDPriceLevel := NET2CPU(hq_md.MDPriceLevel);
    hq_md.NumberOfOrders := NET2CPU(hq_md.NumberOfOrders);
    hq_md.NoOrders := NET2CPU(hq_md.NoOrders);
        //hq_md[] := mdenarr[];
         {st:=Format('MDEntrieno=%d,MDEntryType=%s,MDEntryPx=%.6n,MDEntrySize=%d,MDPriceLevel=%d,NumberOfOrders=%d,NoOrders=%d',
                     [+1,trim(hq_md[].MDEntryType),hq_md[].MDEntryPx/1000000.00,hq_md[].MDEntrySize,hq_md[].MDPriceLevel,hq_md[].NumberOfOrders,hq_md[].NoOrders]);
           }
    if hq_md.NoOrders <> 0 then
      for m := 0 to hq_md.NoOrders - 1 do
      begin
        trans64.i64 := AClient.Socket.ReadInt64;
          //  st:=st+format('笔数%d：%d',[m,trans64.i64]);
        for k := 7 downto 0 do
          chk := chk + trans64.by64[k];
      end;
    mden_body[i] := hq_md;
  end;
  l := AClient.Socket.ReadInt32;
  chk := chk mod 256;
  if (l = chk) then
  begin
    data_stream.SetLen(35);
    for I := 2 to 34 do
      data_stream[i] := uint64(0);
    data_stream[0] := string(stock_body.SecurityID).Trim;
    data_stream[2] := stock_body.PrevClosePx div 10;
    data_stream[5] := stock_body.TotalVolumeTrade div 100;
    data_stream[6] := stock_body.TotalValueTrade div 10;
    data_stream[7] := stock_body.NumTrades;
    for hq_md in mden_body do
    begin
      sl:= Char(hq_md.MDEntryType[0]);
      case (sl) of
        '0':
          if (hq_md.MDEntryType[1] = ' ') then
          begin
            data_stream[24 + hq_md.MDPriceLevel] := hq_md.MDEntryPx div 1000;
            data_stream[25 + hq_md.MDPriceLevel] := hq_md.MDEntrySize div 100;
          end;
        '1':
          if (hq_md.MDEntryType[1] = ' ') then
          begin
            data_stream[24 - hq_md.MDPriceLevel] := hq_md.MDEntryPx div 1000;
            data_stream[25 - hq_md.MDPriceLevel] := hq_md.MDEntrySize div 100;
          end
          else
            data_stream[12]:= hq_md.MDEntryPx div 1000;
        '2':
          if (hq_md.MDEntryType[1] = ' ') then
          begin
            data_stream[4] := hq_md.MDEntryPx div 1000;
          end
          else
            data_stream[13]:= hq_md.MDEntryPx div 1000;
        '4':
          if (hq_md.MDEntryType[1] = ' ') then
          begin
            data_stream[3] := hq_md.MDEntryPx div 1000;
          end;
        '5':
          if (hq_md.MDEntryType[1] = 'x') then
          begin
            data_stream[10] := hq_md.MDEntryPx div 10000;
          end;
        '6':
          if (hq_md.MDEntryType[1] = 'x') then
          begin
            data_stream[11] := hq_md.MDEntryPx div 10000;
          end;
        '7':
          if (hq_md.MDEntryType[1] = ' ') then
          begin
            data_stream[8] := hq_md.MDEntryPx div 1000;
          end;
        '8':
          if (hq_md.MDEntryType[1] = ' ') then
          begin
            data_stream[9] := hq_md.MDEntryPx div 1000;
          end;
        'g':
          if (hq_md.MDEntryType[1] = 'x') then
          begin
            data_stream[13] := hq_md.MDEntrySize div 100;
          end;
      end;
    end;
  end;
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
  ftype_coun:=TDictionary<Integer,Integer>.Create;
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

function Trecive_net.getstatus: rec_stat;
begin
 Result:=fstatus;
end;

function Trecive_net.make_command: Idata_CMD;
var
  t_heat: TIdBytes;
  endtime:Integer;
  tmp:Ivisiter;
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
    Result:=tnocmd.Create;
    fdataIStrue:=True;
  end;
  endtime := TThread.GetTickCount;
  if isnodata and ((endtime - sev_heart) > (heart * 2)) then
    fdataIStrue := False;
  if ((endtime - cli_heart) > heart) then
  begin
    cli_heart := TThread.GetTickCount;
    fAC.Socket.WriteDirect(t_heat);
    for tmp in fvisiters do
    begin
      tmp.update(ftype_coun);
    end;
  end;
  if (not fdataIStrue) then
    fstatus := DataErr
  else if isnodata then
    fstatus := NoData
  else
    fstatus := HasData;

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
  ty_coun,totle_coun:Integer;
begin
  msg_type := fAC.Socket.ReadInt32();
  body_ln := fAC.Socket.ReadInt32();
  fdataIStrue := False;
  if ftype_coun.ContainsKey(msg_type) then
     ty_coun:=ftype_coun[msg_type]
  else ty_coun:=0;
  if ftype_coun.ContainsKey(999999) then
     totle_coun:=ftype_coun[999999]
  else totle_coun:=0;
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
        inc(ty_coun);
      end;
    3: //心跳
      begin
        chk := fac.Socket.ReadInt32();
        fdataIStrue:=(chk = 3);
        Result:=tnocmd.Create;
        inc(ty_coun);
      end;
    300192: //逐笔委托行情
      begin
        fdataIStrue := readbuff<wt_l2>(l2_wt, msg_type, body_ln);
        inc(ty_coun);
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
        inc(ty_coun);
      end;
    309011:  //指数行情
      begin
        data_make:=Tstock_zs.Create(fAC);
        fdataIStrue:=data_make.getdate(body_ln);
        inc(ty_coun);
      end;
    309111: //成交量统计指标行情
      begin
        data_make:=Tstock_zsvol.Create(fAC);
        fdataIStrue:=data_make.getdate(body_ln);
        //fdataIStrue:=get_stock_hq(fAC, msg_type, body_ln);
        inc(ty_coun);
      end;
    390013: //证券实时状态
      begin
        data_make:=TStockStatus.Create(fAC);
        fdataIStrue:=data_make.getdate(body_ln);
        inc(ty_coun);
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
  Inc(totle_coun);
  ftype_coun.AddOrSetValue(999999,totle_coun);
  ftype_coun.AddOrSetValue(msg_type,ty_coun);
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
    if (fip <> '') and (fport <> 0) then
    begin
      fAC.Host := fip;
      fAC.Port := fport;
      try
        fAC.Connect;
      except
        fstatus := ConnectErr;
        Exit(False);
      end;
      Result := send_login;
    end
    else
    begin
      fstatus := NoSetIP;
      Exit(False);
    end
  else
    Result := True;
  sev_heart := TThread.GetTickCount;
  cli_heart := sev_heart;

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

{ Trecive_file }

function Trecive_file.convertFJYRecord2Map(rec: string): TArrayEx<Variant>;
begin

end;

function Trecive_file.convertMktdtRecord2Map(rec: String): TArrayEx<Variant>;
var
sl1:tarray<string>;
obj:tarrayex<variant>;
s1,type1,tmp:string;
i:Integer;
begin
  tmp:=Trim(rec);
  if tmp='' then Exit;
  sl1:=tmp.split(['|']);
  for I := 0 to Length(sl1)-1 do sl1[i]:=Trim(sl1[i]);
  type1:=sl1[0];
  if type1='TRAILER' then
     begin
       Exit;
     end;
  obj.SetLen(30);
  if type1='MD001' then
    begin
      obj[0]:=sl1[1];
      obj[1]:=sl1[2];
      obj[2]:=sl1[5];
      obj[3]:=sl1[6];
      s1:=BcdToStr(BCDRoundTo(strtobcd(sl1[4]),0));
      if Length(Trim(s1))>12 then
      s1:='999999999999';
      obj[4]:=s1;
      obj[5]:=sl1[7];
      obj[6]:=sl1[8];
      obj[7]:=isclose.IIf(sl1[10],sl1[9]);
      obj[10]:= sl1[3];;
      obj[11]:=True;
    end
  else
    begin
      obj[0]:=sl1[1];
      obj[1]:=sl1[2];
      obj[2]:=sl1[5];
      obj[3]:=sl1[6];
      s1:=BcdToStr(BCDRoundTo(strtobcd(sl1[4]),0));
      if Length(Trim(s1))>12 then
      s1:='999999999999';
      obj[4]:=s1;
      obj[5]:=sl1[7];
      obj[6]:=sl1[8];
      obj[7]:=isclose.IIf(sl1[10],sl1[9]);
      obj[8]:=sl1[11];
      obj[9]:=sl1[13];
      obj[10]:= sl1[3];;
      if type1='MD004' then s1:=sl1[33]
      else s1:=sl1[31];
      obj[11]:=((Copy(s1,0,1)<>'P') and (Copy(s1,2,1)='1')).IIf(False,True);
      obj[12]:=sl1[12];
      obj[13]:=sl1[15];
      obj[14]:=sl1[16];
      obj[15]:=sl1[19];
      obj[16]:=sl1[20];
      obj[17]:=sl1[14];
      obj[18]:=sl1[17];
      obj[19]:=sl1[18];
      obj[20]:=sl1[21];
      obj[21]:=sl1[22];
      obj[23]:=sl1[24];
      obj[24]:=sl1[27];
      obj[25]:=sl1[28];
      obj[26]:=sl1[25];
      obj[27]:=sl1[26];
      obj[28]:=sl1[29];
      obj[29]:=sl1[30];
    end;
  if type1='MD004' then
  begin
    Self.T1IOPVMap.AddOrSetValue(sl1[1],sl1[31]);
    Self.IOPVMap.AddOrSetValue(sl1[1],sl1[32]);
  end;
  result:=obj;
end;

constructor Trecive_file.Create;
begin
  inherited;
  flines:=TStringList.Create;
  fdataIStrue:=False;
  ftype_coun:=TDictionary<Integer,Integer>.Create;
  Self.T1IOPVMap:=TDictionary<string,string>.Create;
  Self.IOPVMap:=TDictionary<string,string>.Create;
  fvisiters:=TList<Ivisiter>.Create;
  fType:=0;
end;

destructor Trecive_file.Destroy;
begin
  fvisiters.Clear;
  fvisiters.Free;
  ftype_coun.Free;
  flines.Free;
  inherited;
end;

function Trecive_file.firstRecValFormat(
  headVals: TArrayEx<string>): tarrayex<variant>;
var
fr:TArrayEx<Variant>;
begin
   fr.SetLen(30);
   fr[0]:=headVals[0];
   fr[1]:=headVals[1];
   fr[2]:=headVals[2];
   fr[3]:=headVals[3];
   fr[4]:=headVals[4];
   fr[5]:=headVals[5];
   fr[10]:=headVals[10];
   fr[11]:=headVals[11];
   fr[12]:=headVals[12];
   fr[14]:=headVals[14];
   Result:=fr;
end;

function Trecive_file.getstatus: rec_stat;
begin
  Result:=fstatus;
end;

function Trecive_file.make_command: Idata_CMD;
begin
  Result:=make_data;
end;

function Trecive_file.make_data: Idata_CMD;
var
  lin, szRecord, agRecord, enRecord: string;
  i:Integer;
begin
  if frecno < flines.Count then
  begin
    case fType of
      0:
        begin
          lin := flines[frecno];
          if frecno = 0 then
          begin
            szRecord := flines[1];
            agRecord := flines[2];
            enRecord := flines[3];
            result := tfastcmd.create(setfirstrecval(lin, (szrecord.split(['|']))[9], (szrecord.split(['|']))[9], (szrecord.split(['|']))[9]));
          end
          else
           result:=tfastcmd.create(convertMktdtRecord2Map(lin));
        end;
      1:
        result:=tfjycmd.create(convertFJYRecord2Map(lin));
    end;
  end
  else
  begin
    i:=frecno-flines.count;
    case i of
      0: result:=tfjycmd.create(tarrayex<Variant>.Create(['888880', '新标准券', '1.0', '0.0', '0', '0.0', '0.0', '0.0', '0.0', '0.0', '0', True, '0', '0.0', '0', '0.0', '0', '0', '0.0', '0', '0.0', '0', '0.0', '0', '0.0', '0', '0.0', '0', '0.0', '0']));
      1:result:=tfjycmd.create(tarrayex<Variant>.Create(['799990', '市值股数', '1.0', '0.0', '0', '0.0', '0.0', '0.0', '0.0', '0.0', '0', True, '0', '0.0', '0', '0.0', '0', '0', '0.0', '0', '0.0', '0', '0.0', '0', '0.0', '0', '0.0', '0', '0.0', '0']));
    end;
  end;
  inc(frecno);
end;

function Trecive_file.setFirstRecVal(firstRec, szTradePrice, agTradePrice,
  bgTradePrice: string): tarrayex<variant>;
var
obj:Tarrayex<string>;
stl:tarray<string>;
s1:string;
begin
   obj.SetLen(33);
   stl:=firstRec.split(['|']);
   obj[0]:='000000';
   obj[1]:=StringReplace(Copy(stl[6],10,8),':','',[rfReplaceAll])+'  ';
   obj[2]:=agTradePrice;
   obj[3]:=bgTradePrice;
   obj[4]:='0';
   Self.jydate:=Copy(stl[6],1,8);
   obj[5]:=Self.jydate;
   s1:=stl[8];
   if Copy(stl[8],1,1)='E' then
     begin
       obj[10]:='1111111111';
       Self.isclose:=True;
     end
   else
     begin
       obj[10]:='0';
       Self.isclose:=False;
     end;
   obj[11]:=szTradePrice;
   obj[12]:=Copy(s1,3,1);
   obj[14]:=Copy(s1,2,1);
   Result:=firstRecValFormat(obj);
end;

function Trecive_file.start: Boolean;
var
id:string;
begin
  Result:=False;
  case fType of
  0: id:='fast';
  1: id:='fjy';
  end;
  if Assigned(ffilenames) then
  begin
    while Result do
    begin
      try
        flines.LoadFromFile(ffilenames.Values[id]);
        frecno:=0;
        Result:=True;
      except on e:Exception  do
        Sleep(50);
      end;
    end;
  end;
end;

function Trecive_file.stop: Boolean;
begin
  Result := False;
  if Assigned(ffilenames) then
  begin
    flines.Clear;
    Inc(ftype);
    if (fType >= ffilenames.Count) then
      ftype := 0;
    Result := True;
  end;
end;

procedure Trecive_file.vi_reg(vi: ivisiter);
begin

end;

end.
