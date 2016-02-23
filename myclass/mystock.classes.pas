unit mystock.classes;

interface
uses
  mystock.types,mystock.interfaces,IdGlobal,IdTCPClient,Generics.Collections, ArrayEx, System.SysUtils, System.Variants, System.Classes,system.Math;
type

  TExtFuns = class(Tobject)
  public
    class function IfThen<T>(AValue: Boolean; const ATrue, AFalse: T): T; inline;
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
{ TDBField }

  TDBField = class(TInterfacedObject, IDBField)
  private
	  fname:ansistring;
	  fField_type:ansichar;
	  flength,fdec:integer;
  protected

  public
	  constructor CreateFromField(fiel:DBField);
	  constructor Create(na:string;ty:ansichar;le,deci:integer);
    function GetName:AnsiString;
	  function GetType:ansichar;
	  function GetLength:Byte;
	  function GetDeci:Byte;
	  function format(obj:variant):string;
	  function parse(s:string):variant;
	  procedure SetName(na:string);
	  procedure SetType(ty:ansichar);
	  procedure SetLength(le:integer);
	  procedure SetDeci(deci:integer);
    property name:AnsiString read SetName write SetName;
    property Field_type:AnsiChar read SetType write SetType;
    property length:Byte read GetLength write SetLength;
    property dec:Byte read GetDeci write SetDeci;
  end;


implementation
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
          //  st:=st+format('±ÊÊý%d£º%d',[m,trans64.i64]);
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

{ TExtFuns }

class function TExtFuns.IfThen<T>(AValue: Boolean; const ATrue, AFalse: T): T;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

//------------------------------------------------------------------------------
// ×¢ÊÍ
//------------------------------------------------------------------------------

constructor TDBField.Create(na:string;ty:ansichar;le,deci:integer);
begin
  if (system.Length(na)>10) then
  raise Exception.Create('The field name is more than 10 characters long:'+na );

  if (ty <> 'C') and (ty <> 'N') and (ty <> 'L') and (ty <> 'D') and (ty <> 'F') then
  raise Exception.Create('The field type is not a valid. Got: '+ty);

  if (le<1) then
  raise Exception.Create('The field length should be a positive integer. Got: '+inttostr(le));

  if (ty = 'C') and (le>=254) then
  raise Exception.Create('The field length should be less than 254 characters for character fields. Got: '+inttostr(le));

  if (ty = 'N') and (le>=21) then
  raise Exception.Create('The field length should be less than 21 digits for numeric fields. Got: '+inttostr(le));

  if (ty = 'L') and (le<>1) then
  raise Exception.Create('The field length should be 1 characater for logical fields. Got: '+inttostr(le));

  if (ty = 'D') and (le<>8) then
  raise Exception.Create('The field length should be 8 characaters for date fields. Got: '+inttostr(le));

  if (ty = 'F') and (le>=21) then
  raise Exception.Create('The field length should be less than 21 digits for floating point fields. Got: '+inttostr(le));

  if (deci < 0) then
  raise Exception.Create('The field decimal count should not be a negative integer. Got: '+inttostr(deci));

  if ((ty = 'C') or (ty = 'L') or (ty = 'D')) and (deci <> 0) then
  raise Exception.Create('The field decimal count should be 0 for character, logical, and date fields. Got: '+inttostr(deci));

  if (deci > (le-1)) then
  raise Exception.Create('The field decimal count should be less than the length - 1. Got: '+inttostr(deci));

  self.fname:=ansistring(na);
  self.fField_type:=ty;
  self.flength:=le;
  self.fdec:=deci;
end;

constructor TDBField.CreateFromField(fiel: DBField);
var
  na:ansistring;
  ty:ansichar;
  le,deci:integer;
begin
  na:=pansichar(@(fiel.Fieldname));
  ty:=fiel.FieldType;
  le:=fiel.FieldLenth;
  deci:=fiel.FieldDec;
  if (system.Length(na)>10) then
  raise Exception.Create('The field name is more than 10 characters long:'+string(na) );

  if (ty <> 'C') and (ty <> 'N') and (ty <> 'L') and (ty <> 'D') and (ty <> 'F') then
  raise Exception.Create('The field type is not a valid. Got: '+ty);

  if (le<1) then
  raise Exception.Create('The field length should be a positive integer. Got: '+inttostr(le));

  if (ty = 'C') and (le>=254) then
  raise Exception.Create('The field length should be less than 254 characters for character fields. Got: '+inttostr(le));

  if (ty = 'N') and (le>=21) then
  raise Exception.Create('The field length should be less than 21 digits for numeric fields. Got: '+inttostr(le));

  if (ty = 'L') and (le<>1) then
  raise Exception.Create('The field length should be 1 characater for logical fields. Got: '+inttostr(le));

  if (ty = 'D') and (le<>8) then
  raise Exception.Create('The field length should be 8 characaters for date fields. Got: '+inttostr(le));

  if (ty = 'F') and (le>=21) then
  raise Exception.Create('The field length should be less than 21 digits for floating point fields. Got: '+inttostr(le));

  if (deci < 0) then
  raise Exception.Create('The field decimal count should not be a negative integer. Got: '+inttostr(deci));

  if ((ty <> 'C') or (ty <> 'L') or (ty <> 'D')) and (deci <> 0) then
  raise Exception.Create('The field decimal count should be 0 for character, logical, and date fields. Got: '+inttostr(deci));

  if (deci > (le-1)) then
  raise Exception.Create('The field decimal count should be less than the length - 1. Got: '+inttostr(deci));

  self.fname:=na;
  self.fField_type:=fiel.FieldType;
  self.flength:=fiel.FieldLenth;
  self.fdec:=fiel.FieldDec;
end;

function TDBField.format(obj: Variant):string;
begin
  if ((self.fField_type='N') or (self.fField_type='F')) and ( VarIsClear(obj) or varisnull(obj))then
  begin
    Result:= getNumberNullValue();
    exit;
  end;
  Result:=formatValue(obj);
end;

function TDBField.formatValue(obj: Variant):string;
var
  lowdec1,i,j:integer;
  st1,st2:ansistring;
  ob:string;
  bo:boolean;
  re:Extended;
begin
  if (self.fField_type='N') or (self.fField_type='F') then
  begin
    if (vartype(obj)=varString) or (vartype(obj)=varUString) then
    begin
      ob:=obj;
      i:=System.Length(ob);
      re:=StrToFloat(ob);
      lowdec1:=self.dec;
      if (re>=10000.0) and (self.fdec>0) then lowdec1:=lowdec1-1;
      st1:=ansistring(FloatToStrF(re,ffFixed,i,lowdec1));
      i:= self.Length-system.Length(st1);
      if i<0 then raise Exception.Create('Value ' + string(st1) + ' cannot fit in pattern');
      system.SetLength(st2,i);
      for j := 1 to i do st2[j]:=' ';
      Result:=string(st2+st1);
      exit;
    end;
    raise Exception.Create('Field Type Eror for ' + obj + '.');
  end;
  if (self.fField_type='C') then
  begin
    if varisnull(obj) or VarIsClear(obj) then
    begin
      system.SetLength(st1,self.getlength);
      for I := 1 to self.getlength do st1[i]:=' ';
      obj:=st1;
    end;
    if (vartype(obj)=varString) or (vartype(obj)=varUString) then
    begin
      ob:=obj;
      st1:=ansistring(ob);
      if (system.Length(st1)>self.getLength) then raise Exception.Create('"' + obj +
      '" is longer than ' + inttostr(self.getLength) + ' characters, value: ' + obj);
      system.SetLength(st2,self.getLength-system.Length(st1));
      for I := 1 to self.getLength-system.Length(st1) do st2[i]:=' ';
      Result:=string(st2+st1);
      exit;
    end;
    raise Exception.Create('Expected a String, got '+inttostr(VarType(obj))
    +', value: '+vartostr(obj));
  end;
  if (self.fField_type='L') then
  begin
    if varisnull(obj) or VarIsClear(obj) then
    begin
      obj:=false;
    end;
    if (vartype(obj)=varBoolean) then
    begin
      bo:=obj;
      Result:=TExtFuns.IfThen(bo,'Y','N');
      exit;
    end;
    raise Exception.Create('Expected a Boolean, got '+VarTypeAsText(VarType(obj))
    +', value: '+vartostr(obj));
  end;
  if (self.fField_type='D') then
  begin
    if varisnull(obj) or VarIsClear(obj) then
    begin
      obj:=Date;
    end;
    if (vartype(obj)=varDate) then
    begin
      Result:=formatdatetime('yyyymmdd',variants.VarToDateTime(obj));
      exit;
    end;
    raise Exception.Create('Expected a Date, got '+VarTypeAsText(VarType(obj))
    +', value: '+vartostr(obj));
  end;
  raise Exception.Create('Unrecognized JDBFField type: '+VarTypeAsText(VarType(obj)));
end;

function TDBField.getDeci: Byte;
begin
  Result:=self.fdec;
end;

function TDBField.getLength: Byte;
begin
  Result:=self.flength;
end;

function TDBField.GetName: AnsiString;
begin
  Result:=self.fname;
end;

function TDBField.getNumberNullValue: string;
var
st1,st2:TstringBuilder;
i,j:integer;
begin
  st1:=TStringBuilder.create;
  st2:=TStringBuilder.create;
  if self.getLength>0 then st1.append('-');
  if self.getDeci>0 then
  begin
    st1.append('.');
    st1.append('-',self.fdec);
//    for I := 0 to self.getDeci - 1 do st1:=st1+'-';
  end;
  i:=self.getLength-system.Length(st1);
  st2.append(' ',i);
//  for j := 0 to i - 1 do st2:=st2+' ';
  Result:=st2.tostring+st1.tostring;
end;

function TDBField.GetType: ansichar;
begin
  Result:=self.fField_type;
end;

function TDBField.parse(s: string): variant;
var
st1:string;
df1:TFormatSettings;

begin
  if (self.fField_type='N') or (self.fField_type='F') then
  begin
    st1:=stringreplace(s,'.','', [rfReplaceAll]);
    st1:=stringreplace(st1,'-','', [rfReplaceAll]);
    if st1='' then exit(s);
    try
    begin
       if self.getDeci=0 then exit(StrToInt(s));
       exit(strtofloat(s));
    end;
    except on E: EConvertError do raise E;
    end;
  end;
  if (self.fField_type='C') then exit(s);
  if (self.fField_type='L') then
  begin
    if ((s='Y') or (s='y') or (s='T') or (s='t')) then exit(True);
    if ((s='N') or (s='n') or (s='F') or (s='f')) then exit(false);
    raise Exception.Create('Unrecognized value for logical field: '+s);
  end;
  if (self.fField_type='D') then
  begin
    df1.ShortDateFormat:='yyyymmdd';
    try
      begin
        if s='' then exit(null);
        exit(strtodate(s,df1));
      end;
    except on E: EConvertError do raise E;
    end;
  end;
  raise Exception.Create('Unrecognized JDBFField type: '+self.Field_type);
end;

procedure TDBField.SetDeci(deci: integer);
begin
  self.fdec:=Byte(deci);
end;

procedure TDBField.SetLength(le: integer);
begin
  self.flength:=Byte(le);
end;

procedure TDBField.SetName(na: string);
begin
  self.fname:=ansistring(na);
end;

procedure TDBField.SetType(ty: ansichar);
begin
  self.fField_type:=ty;
end;

end.
