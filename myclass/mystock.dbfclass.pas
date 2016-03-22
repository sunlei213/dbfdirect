unit mystock.dbfclass;

interface
uses
  mystock.types,mystock.interfaces,ArrayEx, System.SysUtils, System.Variants, System.Classes, system.Math,Generics.Collections;
type

{ TDBField }

  TDBField = class(TInterfacedObject, IDBField)
  private
    fname: ansistring;
    fField_type: ansichar;
    flength, fdec: integer;
    function formatValue(obj: variant): string;
    function getNumberNullValue(): string;
  protected
  public
    constructor CreateFromField(fiel: DBField);
    constructor Create(na: string; ty: ansichar; le, deci: integer);
    function GetName: AnsiString;
    function GetType: ansichar;
    function GetLength: Byte;
    function GetDeci: Byte;
    function format(obj: variant): string;
    function unformatValue(st:string):Variant;
    function parse(s: string): variant;
    procedure SetName(na: AnsiString);
    procedure SetType(ty: ansichar);
    procedure SetLength(le: Byte);
    procedure SetDeci(deci: Byte);
    property name: AnsiString read GetName write SetName;
    property Field_type: AnsiChar read GetType write SetType;
    property length: Byte read GetLength write SetLength;
    property dec: Byte read GetDeci write SetDeci;
  end;
{ TDBFRead }

  TDBFWrite=class(TInterfacedObject, IDBFRead, IDBFwrite)
    private
      WriteBuffStream:TmemoryStream;
      fields:Tlist<IDBField>;
      dbfEncoding:TEncoding;
      fDBhead:DBHead;
      frecstarPos:Integer;
      procedure writeHeader(recCount:integer);
      procedure writeFieldHeader(field:IDBField;loc:integer);
      procedure ReadHeader;
      procedure ReadFieldHeader;
    public
      constructor Create(DBfields:Tlist<IDBfield>);
      destructor Destroy;override;
      procedure initHead2Stream(recCount:integer);
      procedure addRecord(delflag:boolean;objs:tarrayex<variant>);
      procedure addRecord0(delflag:boolean;objs:tarrayex<variant>);
      procedure wirteStream2File(filename:string);
      procedure SetEncode(encode:TEncoding);
      function initStream2Head:Integer;
      function readRecord(recnum:Integer):tarrayex<variant>;
      function ReadFile2Stream(filename:string):Boolean;
      procedure SetEncoder(encode:TEncoding);
  end;

implementation

//------------------------------------------------------------------------------
// 注释 TDBField 实现
//------------------------------------------------------------------------------

constructor TDBField.Create(na: string; ty: ansichar; le, deci: integer);
begin
  if (system.Length(na) > 10) then
    raise Exception.Create('The field name is more than 10 characters long:' + na);

  if (ty <> 'C') and (ty <> 'N') and (ty <> 'L') and (ty <> 'D') and (ty <> 'F') then
    raise Exception.Create('The field type is not a valid. Got: ' + ty);

  if (le < 1) then
    raise Exception.Create('The field length should be a positive integer. Got: ' + inttostr(le));

  if (ty = 'C') and (le >= 254) then
    raise Exception.Create('The field length should be less than 254 characters for character fields. Got: ' + inttostr(le));

  if (ty = 'N') and (le >= 21) then
    raise Exception.Create('The field length should be less than 21 digits for numeric fields. Got: ' + inttostr(le));

  if (ty = 'L') and (le <> 1) then
    raise Exception.Create('The field length should be 1 characater for logical fields. Got: ' + inttostr(le));

  if (ty = 'D') and (le <> 8) then
    raise Exception.Create('The field length should be 8 characaters for date fields. Got: ' + inttostr(le));

  if (ty = 'F') and (le >= 21) then
    raise Exception.Create('The field length should be less than 21 digits for floating point fields. Got: ' + inttostr(le));

  if (deci < 0) then
    raise Exception.Create('The field decimal count should not be a negative integer. Got: ' + inttostr(deci));

  if ((ty = 'C') or (ty = 'L') or (ty = 'D')) and (deci <> 0) then
    raise Exception.Create('The field decimal count should be 0 for character, logical, and date fields. Got: ' + inttostr(deci));

  if (deci > (le - 1)) then
    raise Exception.Create('The field decimal count should be less than the length - 1. Got: ' + inttostr(deci));

  self.fname := ansistring(na);
  self.fField_type := ty;
  self.flength := le;
  self.fdec := deci;
end;

constructor TDBField.CreateFromField(fiel: DBField);
var
  na: ansistring;
  ty: ansichar;
  le, deci: integer;
begin
  na := pansichar(@(fiel.Fieldname));
  ty := fiel.FieldType;
  le := fiel.FieldLenth;
  deci := fiel.FieldDec;
  if (system.Length(na) > 10) then
    raise Exception.Create('The field name is more than 10 characters long:' + string(na));

  if (ty <> 'C') and (ty <> 'N') and (ty <> 'L') and (ty <> 'D') and (ty <> 'F') then
    raise Exception.Create('The field type is not a valid. Got: ' + ty);

  if (le < 1) then
    raise Exception.Create('The field length should be a positive integer. Got: ' + inttostr(le));

  if (ty = 'C') and (le >= 254) then
    raise Exception.Create('The field length should be less than 254 characters for character fields. Got: ' + inttostr(le));

  if (ty = 'N') and (le >= 21) then
    raise Exception.Create('The field length should be less than 21 digits for numeric fields. Got: ' + inttostr(le));

  if (ty = 'L') and (le <> 1) then
    raise Exception.Create('The field length should be 1 characater for logical fields. Got: ' + inttostr(le));

  if (ty = 'D') and (le <> 8) then
    raise Exception.Create('The field length should be 8 characaters for date fields. Got: ' + inttostr(le));

  if (ty = 'F') and (le >= 21) then
    raise Exception.Create('The field length should be less than 21 digits for floating point fields. Got: ' + inttostr(le));

  if (deci < 0) then
    raise Exception.Create('The field decimal count should not be a negative integer. Got: ' + inttostr(deci));

  if ((ty = 'C') or (ty = 'L') or (ty = 'D')) and (deci <> 0) then
    raise Exception.Create('The field decimal count should be 0 for character, logical, and date fields. Got: ' + inttostr(deci));

  if (deci > (le - 1)) then
    raise Exception.Create('The field decimal count should be less than the length - 1. Got: ' + inttostr(deci));

  self.fname := na;
  self.fField_type := fiel.FieldType;
  self.flength := fiel.FieldLenth;
  self.fdec := fiel.FieldDec;
end;

function TDBField.format(obj: Variant): string;
begin
  if ((self.fField_type = 'N') or (self.fField_type = 'F')) and (VarIsClear(obj) or varisnull(obj)) then
  begin
    Result := getNumberNullValue();
    exit;
  end;
  Result := formatValue(obj);
end;

function TDBField.formatValue(obj: Variant): string;
var
  lowdec1, i, j: integer;
  st1, st2: ansistring;
  ob,sttmp: string;
  ub,Hi,lo:Int64;
  uub,uHi,uLo:UInt64;
  bo: boolean;
  re: Extended;
  bit1:array [0..6] of Integer;
  stb:TstringBuilder;
begin
  bit1[0]:=1;
  for I := (low(bit1)+1) to High(bit1) do
    bit1[i]:=bit1[i-1]*10;
  if (self.fField_type = 'N') or (self.fField_type = 'F') then
  begin
    if (vartype(obj) = varString) or (vartype(obj) = varUString) then
    begin
      ob := obj;
      i := System.Length(ob);
      re := StrToFloat(ob);
      lowdec1 := self.fdec;
      if (re >= 10000.0) and (self.fdec > 0) then
        lowdec1 := lowdec1 - 1;
      st1 := ansistring(FloatToStrF(re, ffFixed, i, lowdec1));
      i := self.Length - system.Length(st1);
      if i < 0 then
        raise Exception.Create('Value ' + string(st1) + ' cannot fit in pattern');
      system.SetLength(st2, i);
      for j := 1 to i do
        st2[j] := ' ';
      Result := string(st2 + st1);
      exit;
    end;
    if (vartype(obj) = varInt64) then
    begin
      bo:=False;
      ub:=obj;
      if ub<0 then
      begin
        bo:=True;
        ub:=0-ub;
      end;
      lowdec1 := bit1[self.fdec];
      hi:=ub div Int64(lowdec1);
      lo:=ub mod Int64(lowdec1);
      if(fdec>0)then
        begin
        sttmp:=inttostr(lo);
        i:=Integer(fdec)-sttmp.Length;
        if i>0 then
         begin
           stb:=TstringBuilder.Create;
           stb.Append('0',i);
           sttmp:=stb.ToString+sttmp;
           stb.Free;
         end;
        st1 := ansistring(IntToStr(hi)+'.'+sttmp);
        end
      else
        st1:= ansistring(IntToStr(hi));
      if bo then
        st1:=AnsiString('-'+string(st1).Trim);
      i := Integer(self.Length) - system.Length(st1);
      if i < 0 then
        raise Exception.Create('Value ' + string(st1) + ' cannot fit in pattern');
      system.SetLength(st2, i);
      for j := 1 to i do
        st2[j] := ' ';
      Result := string(st2 + st1);
      exit;
    end;
    if (vartype(obj) = varUInt64) then
    begin
      uub:=obj;
      lowdec1 := bit1[self.fdec];
      uhi:=uub div uInt64(lowdec1);
      ulo:=uub mod uInt64(lowdec1);
      if(fdec>0)then
        begin
        sttmp:=inttostr(ulo);
        i:=Integer(fdec)-sttmp.Length;
        if i>0 then
         begin
           stb:=TstringBuilder.Create;
           stb.Append('0',i);
           sttmp:=stb.ToString+sttmp;
           stb.Free;
         end;
        st1 := ansistring(IntToStr(uhi)+'.'+sttmp);
        end
      else
        st1:= ansistring(IntToStr(uhi));
      i := Integer(self.Length) - system.Length(st1);
      if i < 0 then
        raise Exception.Create('Value ' + string(st1) + ' cannot fit in pattern');
      system.SetLength(st2, i);
      for j := 1 to i do
        st2[j] := ' ';
      Result := string(st2 + st1);
      exit;
    end;
    raise Exception.Create('Field Type Eror for ' + obj + '.');
  end;
  if (self.fField_type = 'C') then
  begin
    if varisnull(obj) or VarIsClear(obj) then
    begin
      system.SetLength(st1, self.getlength);
      for I := 1 to self.getlength do
        st1[i] := ' ';
      obj := st1;
    end;
    if (vartype(obj) = varString) or (vartype(obj) = varUString) then
    begin
      ob := obj;
      st1 := ansistring(ob);
      if (system.Length(st1) > self.getLength) then
        raise Exception.Create('"' + obj + '" is longer than ' + inttostr(self.getLength) + ' characters, value: ' + obj);
      system.SetLength(st2, self.getLength - system.Length(st1));
      for I := 1 to self.getLength - system.Length(st1) do
        st2[i] := ' ';
      Result := string(st1 + st2);
      exit;
    end;
    raise Exception.Create('Expected a String, got ' + inttostr(VarType(obj)) + ', value: ' + vartostr(obj));
  end;
  if (self.fField_type = 'L') then
  begin
    if varisnull(obj) or VarIsClear(obj) then
    begin
      obj := false;
    end;
    if (vartype(obj) = varBoolean) then
    begin
      bo := obj;
      Result := TExtFuns.IfThen(bo, 'Y', 'N');
      exit;
    end;
    raise Exception.Create('Expected a Boolean, got ' + VarTypeAsText(VarType(obj)) + ', value: ' + vartostr(obj));
  end;
  if (self.fField_type = 'D') then
  begin
    if varisnull(obj) or VarIsClear(obj) then
    begin
      obj := Date;
    end;
    if (vartype(obj) = varDate) then
    begin
      Result := formatdatetime('yyyymmdd', System.Variants.VarToDateTime(obj));
      exit;
    end;
    raise Exception.Create('Expected a Date, got ' + VarTypeAsText(VarType(obj)) + ', value: ' + vartostr(obj));
  end;
  raise Exception.Create('Unrecognized JDBFField type: ' + VarTypeAsText(VarType(obj)));
end;

function TDBField.getDeci: Byte;
begin
  Result := self.fdec;
end;

function TDBField.getLength: Byte;
begin
  Result := self.flength;
end;

function TDBField.GetName: AnsiString;
begin
  Result := self.fname;
end;

function TDBField.getNumberNullValue: string;
var
  st1, st2: TstringBuilder;
  i: integer;
begin
  st1 := TStringBuilder.create;
  st2 := TStringBuilder.create;
  if self.getLength > 0 then
    st1.append('-');
  if self.getDeci > 0 then
  begin
    st1.append('.');
    st1.append('-', self.fdec);
//    for I := 0 to self.getDeci - 1 do st1:=st1+'-';
  end;
  i := Integer(self.Length) - st1.Length;
  st2.append(' ', i);
//  for j := 0 to i - 1 do st2:=st2+' ';
  Result := st2.tostring + st1.tostring;
  st1.Free;
  st2.Free;
end;

function TDBField.GetType: ansichar;
begin
  Result := self.fField_type;
end;

function TDBField.parse(s: string): variant;
var
  st1: string;
  df1: TFormatSettings;
begin
  if (self.fField_type = 'N') or (self.fField_type = 'F') then
  begin
    st1 := stringreplace(s, '.', '', [rfReplaceAll]);
    st1 := stringreplace(st1, '-', '', [rfReplaceAll]);
    if st1 = '' then
      exit(s);
    try
      begin
        if self.getDeci = 0 then
          exit(StrToInt(s));
        exit(strtofloat(s));
      end;
    except
      on E: EConvertError do
        raise E;
    end;
  end;
  if (self.fField_type = 'C') then
    exit(s);
  if (self.fField_type = 'L') then
  begin
    if ((s = 'Y') or (s = 'y') or (s = 'T') or (s = 't')) then
      exit(True);
    if ((s = 'N') or (s = 'n') or (s = 'F') or (s = 'f')) then
      exit(false);
    raise Exception.Create('Unrecognized value for logical field: ' + s);
  end;
  if (self.fField_type = 'D') then
  begin
    df1.ShortDateFormat := 'yyyymmdd';
    try
      begin
        if s = '' then
          exit(null);
        exit(strtodate(s, df1));
      end;
    except
      on E: EConvertError do
        raise E;
    end;
  end;
  raise Exception.Create('Unrecognized JDBFField type: ' + self.fField_type);
end;

procedure TDBField.SetDeci(deci: Byte);
begin
  self.fdec := deci;
end;

procedure TDBField.SetLength(le: Byte);
begin
  self.flength := le;
end;

procedure TDBField.SetName(na: AnsiString);
begin
  self.fname := na;
end;

procedure TDBField.SetType(ty: ansichar);
begin
  self.fField_type := ty;
end;

function TDBField.unformatValue(st: string): Variant;
var
  lowdec1, i: integer;
  starr:TArray<string>;
  ob: string;
  ub,Hi,lo:Int64;
  re: TDateTime;
  isFu:Boolean;
  bit1:array [0..6] of Integer;
  df1: TFormatSettings;
begin
  bit1[0] := 1;
  for I := (low(bit1) + 1) to High(bit1) do
    bit1[i] := bit1[i - 1] * 10;
  ob := st.Trim;
  isFu := false;
  if (self.fField_type = 'N') or (self.fField_type = 'F') then
  begin
    if (ob.Length > 0) then
    begin
      if ob.IndexOf('-') >= 0 then
      begin
        ob:=ob.Replace('-', '0',[rfReplaceAll]);
        isFu := True;
      end;
      starr := ob.Split(['.']);
      lo := 0;
      hi := 0;
      lowdec1 := bit1[self.fdec];
      if (System.Length(starr) > 1) then
      begin
        if starr[1].Length < Self.fdec then
          for I := 1 to Self.fdec - starr[1].Length do
            starr[1] := starr[1] + '0';
        lo := starr[1].ToInt64;
      end;
      if starr[0].Length >0 then
        hi := starr[0].ToInt64;
      ub := Hi * int64(lowdec1) + lo;
      if isFu then
        ub := 0 - ub;
      Result := ub;
      exit;
    end
    else
      exit(0);
  end;
  if (self.fField_type = 'C') then
  begin
    Result:=ob;
    Exit;
  end;
  if (self.fField_type = 'L') then
  begin
    if ob='Y' then
    begin
      Result := True;
      exit;
    end;
    if ob='N' then
    begin
      Result := False;
      exit;
    end;
    if ob.Length=0 then
      Exit(False);
    raise Exception.Create('Expected a Boolean, got ' + ob );
  end;
  if (self.fField_type = 'D') then
  begin
    df1.ShortDateFormat := 'yyyy-mm-dd';
    df1.DateSeparator:='-';
    if ob.Length<8 then
      Exit(now);
    Insert('-', ob, 5);
    Insert('-', ob, 8);
    if TryStrToDate(ob,re,df1) then
    begin
      Result := re;
      Exit;
    end;

    raise Exception.Create('Expected a Date, got ' + st );
  end;
  raise Exception.Create('Unrecognized JDBFField type: '+ st);
end;

//==============================================================================
// DBFWrite 实现
//==============================================================================

procedure TDBFWrite.addRecord(delflag: boolean; objs: tarrayex<variant>);
var
i,j,k:integer;
byte0,byte1:tbytes;
st:string;
begin
  if (objs.Len<>self.fields.Count) then raise Exception.Create('Error adding record: Wrong number of values. Expected '+inttostr(self.fields.Count)+',got:'+inttostr(objs.Len));
  i:=0;
  for j := 0 to self.fields.Count-1 do i:=i+self.fields[j].getLength;
  SetLength(byte0,i);
  k:=0;
  for j := 0 to self.fields.Count-1 do
  begin
    st:='';
    try
      st:=self.fields[j].format(objs[j]);
    except on E: Exception do raise E;
    end;
    byte1:=self.dbfEncoding.GetBytes(st);
    for I := 0 to self.fields[j].getLength-1 do
    begin
      if i>=system.Length(byte1) then raise Exception.Create(string(self.fields[j].Name)+ ' field length is'+inttostr(system.Length(byte1))+', It should be ' +inttostr(self.fields[j].getLength)+'.');
      byte0[(k+i)]:=byte1[i];
    end;
    k:=k+self.fields[j].getLength;
  end;
  self.WriteBuffStream.WriteData(TExtFuns.IfThen(delflag,42,32));
  self.WriteBuffStream.WriteBuffer(byte0,0,length(byte0));
end;

procedure TDBFWrite.addRecord0(delflag: boolean; objs: tarrayex<variant>);
var
i,j,k:integer;
byte0,byte1:tbytes;
st:string;
tmp:Tlist<IDBField>;
dbfield:IDBField;
begin
  tmp:=Tlist<IDBfield>.Create;
  for I := 0 to self.fields.Count-1 do
    begin
      if i=5 then
        begin
          dbfield:=Tdbfield.Create(string(self.fields[i].name),'C',self.fields[i].getLength,0);
          tmp.Add(dbfield);
        end
      else
        tmp.Add(self.fields[i]);
    end;
  if (objs.Len<>tmp.Count) then raise Exception.Create('Error adding record: Wrong number of values. Expected '+inttostr(tmp.Count)+',got:'+inttostr(objs.Len));
  i:=0;
  for j := 0 to tmp.Count-1 do i:=i+tmp[j].getLength;
  SetLength(byte0,i);
  k:=0;
  for j := 0 to tmp.Count-1 do
  begin
    st:='';
    try
      st:=tmp[j].format(objs[j]);
    except on E: Exception do raise E;
    end;
    byte1:=self.dbfEncoding.GetBytes(st);
    for I := 0 to tmp[j].getLength-1 do
    begin
      if i>=system.Length(byte1) then raise Exception.Create(string(tmp[j].Name)+ ' field length is'+inttostr(system.Length(byte1))+', It should be ' +inttostr(tmp[j].getLength)+'.');
      byte0[(k+i)]:=byte1[i];
    end;
    k:=k+tmp[j].getLength;
  end;
  self.WriteBuffStream.WriteData(TExtFuns.IfThen(delflag,42,32));
  self.WriteBuffStream.WriteBuffer(byte0,0,length(byte0));
  tmp.Free;
end;

constructor TDBFWrite.Create(DBfields: Tlist<IDBfield>);
begin
  self.fields:=DBfields;
  self.dbfEncoding:=TEncoding.Default;
  self.WriteBuffStream:=tmemorystream.Create;
end;


destructor TDBFWrite.Destroy;
begin
  Self.WriteBuffStream.Free;
  inherited;
end;

procedure TDBFWrite.initHead2Stream(recCount: integer);
var
  i, j: integer;
begin
  try
    begin
      self.writeHeader(recCount);
      j := 1;
      for I := 0 to self.fields.Count - 1 do
      begin
        self.writeFieldHeader(self.fields[i], j);
        j := j + self.fields[i].getLength;
      end;
      self.WriteBuffStream.WriteData(13);
    end;
  except
    on E: Exception do
      raise E;
  end;
end;

function TDBFWrite.initStream2Head:Integer;
begin
  Result:=0;
  try
    ReadHeader;
    ReadFieldHeader;
    frecstarPos:= fDBhead.DBHeadLen;
    Result:=fDBhead.dbrecoun;
  except
    on E: Exception do
      raise E;
  end;
end;

procedure TDBFWrite.ReadFieldHeader;
var
 i,fid_coun:Integer;
 fid:DBField;
begin
  fid_coun:=(Self.fDBhead.DBHeadLen div 32)-1;
  fields.Clear;
  for I := 0 to fid_coun-1 do
  begin
    self.WriteBuffStream.ReadBuffer(fid,sizeof(DBField));
    fields.Add(TDBField.CreateFromField(fid));
  end;
end;

function TDBFWrite.ReadFile2Stream(filename: string):Boolean;
var
  desf: TFileStream;
begin
  try
    begin
      if FileExists(filename) then
        desf := tfilestream.Create(filename, fmOpenReadWrite or fmShareDenyNone)
      else
        Exit(False);
    end;
  except
    on E: Exception do
      raise E;
  end;
  try
    try
      begin
        WriteBuffStream.LoadFromStream(desf);
        Result := True;
      end;
    except
      on E: Exception do
      begin
        raise E;
      end;
    end;
  finally
    desf.Free;
  end;
end;

procedure TDBFWrite.ReadHeader;
begin
  Self.WriteBuffStream.Position:=0;
  self.WriteBuffStream.ReadBuffer(fDBhead,sizeof(DBhead));
end;

function TDBFWrite.readRecord(recnum:Integer): tarrayex<variant>;
var
  j, k: integer;
  byte0, byte1: tbytes;
  ch: Byte;
  st: string;
  objs: TArrayex<Variant>;
begin
  WriteBuffStream.Position := frecstarPos+fDBhead.DBRecLen*recnum;
  self.WriteBuffStream.ReadData(ch);
  SetLength(byte0, self.fDBhead.DBRecLen - 1);
  self.WriteBuffStream.ReadBuffer(byte0, length(byte0));
  objs.SetLen(fields.Count);
  k := 0;
  st := '';
  for j := 0 to self.fields.Count - 1 do
  begin
    SetLength(byte1, self.fields[j].length);
    move(byte0[k], byte1[0], self.fields[j].length);
    st := Self.dbfEncoding.GetString(byte1);
    objs[j] := Self.fields[j].unformatValue(st);
    k := k + self.fields[j].length;
  end;
  Result := objs;

end;

procedure TDBFWrite.SetEncode(encode: TEncoding);
begin
  self.dbfEncoding:=encode;
end;

procedure TDBFWrite.SetEncoder(encode: TEncoding);
begin
  self.dbfEncoding:=encode;
end;

procedure TDBFWrite.wirteStream2File(filename: string);
var
desf:TFileStream;
begin
  try
  begin
    if FileExists(filename) then
      desf:=tfilestream.Create(filename,fmOpenReadWrite or fmShareDenyNone)
    else
      desf:=tfilestream.Create(filename,fmCreate or fmShareDenyNone)
  end;
  except on E: Exception do
    raise E;
  end;
  try
    try
    begin
      desf.Size:=Self.WriteBuffStream.Size;
      self.WriteBuffStream.Position:=0;
      desf.Position:=0;
      desf.CopyFrom(self.WriteBuffStream,0);
    end;
    except on E: Exception do raise E;
    end;
  finally
    desf.Free;
  end;
end;

procedure TDBFWrite.writeFieldHeader(field: IDBField; loc: integer);
var
i,j:integer;
tb1:tbytes;
st1:string;
fid:DBField;
begin
  st1:=string(field.name);
  tb1:=self.dbfEncoding.GetBytes(st1);
  j:=system.Length(tb1);
  if j>10 then j:=10;
  for I := 0 to j-1 do fid.Fieldname[i]:=ansichar(tb1[i]);
  for I := j to 10 do
    fid.Fieldname[i]:=ansichar(0);
  fid.FieldType:=field.Field_type;
  fid.FieldOffest:=loc;
  fid.FieldLenth:=byte(field.length);
  fid.FieldDec:=byte(field.dec);
  for I := 0 to Length(fid.FieldRest)-1 do fid.FieldRest[i]:=0;

  self.WriteBuffStream.WriteBuffer(fid,sizeof(DBField));
end;

procedure TDBFWrite.writeHeader(recCount: integer);
var
i,j:word;
DBhea:DBhead;
year,mon,da:word;
begin
  DBhea.dbtype:=3;
  DecodeDate(System.SysUtils.Date,year,mon,da);
  DBhea.dbdate[0]:=byte(year-1900);
  DBhea.dbdate[1]:=byte(mon);
  DBhea.dbdate[2]:=byte(da);
  DBhea.dbrecoun:=recCount;
  i:=(self.fields.Count+1)*32+1;
  DBHea.DBHeadLen:=i;
  i:=1;
  for j := 0 to self.fields.Count-1 do i:=i+self.fields[j].Length;
  DBhea.DBRecLen:=i;
  for I := 0 to 19 do DBhea.DBRest[i]:=byte(0);
  self.WriteBuffStream.WriteBuffer(DBhea,sizeof(DBhead));
end;

end.
