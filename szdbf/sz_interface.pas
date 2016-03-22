unit sz_interface;

interface

uses
  Generics.Collections, ArrayEx, System.SysUtils, System.Variants, System.Classes,system.Math,
  sz_fix, IdGlobal, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,DBFdirect;

type
  Idata_make = interface
    function Serial(query: TQueue<tarrayex<Variant>>; body_ln: UInt32): Boolean;
    function getdate(body_ln: UInt32): Boolean;
  end;

  Idata_trans = interface
    function cover_data(d_map:TDictionary<string,tarrayex<variant>>;queue:TQueue<tarrayex<Variant>>):Integer;
    function  write_dbf(filename:string):Boolean;
  end;

{ Tstock }

  Tstock = class(TInterfacedObject, Idata_make)
  private
    tby: TIdBytes;
    AClient: TIdTCPClient;
    chk: UInt32;
    data_stream: TArrayEx<Variant>;
    procedure recvbuff;
  protected
  public
    constructor Create(AClient: TIdTCPClient; i: UInt32);
    function Serial(query: TQueue<tarrayex<Variant>>; body_ln: UInt32): Boolean;
    function getdate(body_ln: UInt32): Boolean; virtual; abstract;
  end;


{ Tstock_hq }

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
    max_cov_num:Integer;
  protected

  public
    constructor Create(cover_num:Integer);
    function cover_data(d_map:TDictionary<string,tarrayex<variant>>;
      queue:TQueue<tarrayex<Variant>>):Integer;
    function write_dbf(filename: string): Boolean;
  end;

{ TSjsxxwrite }

  TSjsxxWrite = class(TInterfacedObject, Idata_trans)
  private
    max_cov_num:Integer;
  protected

  public
    constructor Create(cover_num:Integer);
    function cover_data(d_map:TDictionary<string,tarrayex<variant>>;queue:TQueue<tarrayex<Variant>>):Integer;
    function write_dbf(filename:string):Boolean;

  end;

implementation

uses
  Vcl.Dialogs;

{ Tstock }


constructor Tstock.Create(AClient: TIdTCPClient; i: UInt32);
var
  il: uin32;
begin
  Self.AClient := AClient;
  il.i32 := i;
  chk := il.by32[3] + il.by32[2] + il.by32[1] + il.by32[0];
end;


procedure Tstock.recvbuff;
var
  I, j: Integer;
begin
  j := Length(self.tby);
  Self.AClient.IOHandler.ReadBytes(self.tby, j, False);
  for I := 0 to j - 1 do
    Self.chk := Self.chk + self.tby[i];
end;

function Tstock.Serial(query: TQueue<tarrayex<Variant>>; body_ln: UInt32): Boolean;
begin
  if getdate(body_ln) then
  begin
    query.Enqueue(data_stream);
    Result := True;
  end
  else
    Result := False;
end;

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
          //  st:=st+format('����%d��%d',[m,trans64.i64]);
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
  inherited Create(AClient, 309111);
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

function TSjshqWrite.cover_data(d_map: TDictionary<string, tarrayex<variant>>;
  queue: TQueue<tarrayex<Variant>>): Integer;
var
  my_data,tmp_data:TArrayEx<Variant>;
  I,j,k:Integer;
begin
  j:=Min(max_cov_num ,queue.Count);
  Result:=0;
  for I := 0 to j-1 do
    begin
      if queue.Count=0 then Break;
      my_data:=queue.Dequeue;
      if d_map.ContainsKey(my_data[0]) then
        begin
          tmp_data:=d_map.Items[my_data[0]];
          for k := 0 to my_data.Len-1  do
            tmp_data[k]:=my_data[k];
        end;

      Result:=Result+1;

    end;
end;

constructor TSjshqWrite.Create(cover_num: Integer);
begin
  inherited Create;
  max_cov_num:=cover_num;
end;

function TSjshqWrite.write_dbf(filename: string): Boolean;
begin

end;

{ TSjsxxWrite }

function TSjsxxWrite.cover_data(d_map: TDictionary<string, tarrayex<variant>>;
  queue: TQueue<tarrayex<Variant>>): Integer;
begin

end;

constructor TSjsxxWrite.Create(cover_num: Integer);
begin
  inherited Create;
  max_cov_num:=cover_num;
end;

function TSjsxxWrite.write_dbf(filename: string): Boolean;
begin
end;

end.
