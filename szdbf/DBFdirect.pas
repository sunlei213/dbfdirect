unit DBFdirect;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes,Generics.Collections,arrayex,
  fmtbcd;

type
  TExtFuns = class
    class function IfThen<T>(AValue: Boolean; const ATrue, AFalse: T): T; inline;
  end;

  DBHead = record
    dbtype:byte;
    dbdate:array[0..2] of byte;
    dbrecoun:Cardinal;
    DBHeadLen:word;
    DBRecLen:word;
    DBRest:array[0..19] of byte;
  end;

  DBField=record
    Fieldname:array[0..10] of ansichar;
    FieldType:ansichar;
    FieldOffest:integer;
    FieldLenth:byte;
    FieldDec:byte;
    FieldRest:array [0..13] of byte;
  end;

  TDBField=class
    private
	  name:ansistring;
	  Field_type:ansichar;
	  length,dec:integer;
	  function formatValue(obj:variant):string;
	  function getNumberNullValue():string;
	public
	  constructor CreateFromField(fiel:DBField);
	  constructor Create(na:string;ty:ansichar;le,deci:integer);
	  function getName():string;
	  function getType():ansichar;
	  function getLength():integer;
	  function getDeci():integer;
	  function format(obj:variant):string;
	  function parse(s:string):variant;
	  procedure setName(na:string);
	  procedure setType(ty:ansichar);
	  procedure setLength(le:integer);
	  procedure setDeci(deci:integer);
  end;

  TDBFWrite=class
    private
      WriteBuffStream:TmemoryStream;
      fields:Tlist<TDBField>;
      dbfEncoding:TEncoding;
      procedure writeHeader(recCount:integer);
      procedure writeFieldHeader(field:TDBField;loc:integer);
    public
      constructor Create(DBfields:Tlist<TDBfield>);
      destructor Destroy;override;
      procedure initHead2Stream(recCount:integer);
      procedure addRecord(delflag:boolean;objs:tarrayex<variant>);
      procedure addRecord0(delflag:boolean;objs:tarrayex<variant>);
      procedure wirteStream2File(filename:string);
      procedure SetEncode(encode:TEncoding);
  end;
implementation

class function TExtFuns.IfThen<T>(AValue: Boolean; const ATrue, AFalse: T): T;
begin
  if AValue then
    Result := ATrue
  else
    Result := AFalse;
end;

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

  self.name:=ansistring(na);
  self.Field_type:=ty;
  self.length:=le;
  self.dec:=deci;
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

  self.name:=pansichar(@(fiel.Fieldname));
  self.Field_type:=fiel.FieldType;
  self.length:=fiel.FieldLenth;
  self.dec:=fiel.FieldDec;
end;

function TDBField.format(obj: Variant):string;
begin
  if ((self.Field_type='N') or (self.Field_type='F')) and ( VarIsClear(obj) or varisnull(obj))then
  begin
    Result:= getNumberNullValue();
    exit;
  end;
  Result:=formatValue(obj);
end;

function TDBField.formatValue(obj: Variant):string;
var
  s1:tbcd;
  lowdec1,i,j:integer;
  st1,st2:ansistring;
  ob:string;
  bo:boolean;
  re:Extended;
begin
  if (self.Field_type='N') or (self.Field_type='F') then
  begin
    if VarIsClear(obj) then
       obj:='0';
    if (vartype(obj)=varString) or (vartype(obj)=varUString) then
    begin
      ob:=obj;
      i:=System.Length(ob);
      re:=StrToFloat(ob);
      lowdec1:=self.dec;
      if (re>=10000.0) and (self.dec>0) then lowdec1:=lowdec1-1;
      st1:=ansistring(FloatToStrF(re,ffFixed,i,lowdec1));
      i:= self.getLength-system.Length(st1);
      if i<0 then raise Exception.Create('Value ' + string(st1) + ' cannot fit in pattern');
      system.SetLength(st2,i);
      for j := 1 to i do st2[j]:=' ';
      Result:=string(st2+st1);
      exit;
    end;
    raise Exception.Create('Field Type Eror for ' + obj + '.');
  end;
  if (self.Field_type='C') then
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
  if (self.Field_type='L') then
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
  if (self.Field_type='D') then
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

function TDBField.getDeci: integer;
begin
  Result:=self.dec;
end;

function TDBField.getLength: integer;
begin
  Result:=self.length;
end;

function TDBField.getName: string;
begin
  Result:=string(self.name);
end;

function TDBField.getNumberNullValue: string;
var
st1,st2:string;
i,j:integer;
begin
  st1:='';
  st2:='';
  if self.getLength>0 then st1:=st1+'-';
  if self.getDeci>0 then
  begin
    st1:=st1+'.';
    for I := 0 to self.getDeci - 1 do st1:=st1+'-';
  end;
  i:=self.getLength-system.Length(st1);
  for j := 0 to i - 1 do st2:=st2+' ';
  Result:=st2+st1;
end;

function TDBField.getType: ansichar;
begin
  Result:=self.Field_type;
end;

function TDBField.parse(s: string): variant;
var
st1:string;
df1:TFormatSettings;

begin
  if (self.Field_type='N') or (self.Field_type='F') then
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
  if (self.Field_type='C') then exit(s);
  if (self.Field_type='L') then
  begin
    if ((s='Y') or (s='y') or (s='T') or (s='t')) then exit(True);
    if ((s='N') or (s='n') or (s='F') or (s='f')) then exit(false);
    raise Exception.Create('Unrecognized value for logical field: '+s);
  end;
  if (self.Field_type='D') then
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

procedure TDBField.setDeci(deci: integer);
begin
  self.dec:=deci;
end;

procedure TDBField.setLength(le: integer);
begin
  self.length:=le;
end;

procedure TDBField.setName(na: string);
begin
  self.name:=ansistring(na);
end;

procedure TDBField.setType(ty: ansichar);
begin
  self.Field_type:=ty;
end;

{ TDBFWrite }

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
      if i>=system.Length(byte1) then raise Exception.Create(self.fields[j].getName+ ' field length is'+inttostr(system.Length(byte1))+', It should be ' +inttostr(self.fields[j].getLength)+'.');
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
tmp:Tlist<TDBField>;
dbfield:TDBField;
begin
  tmp:=Tlist<TDBfield>.Create;

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
      if i>=system.Length(byte1) then raise Exception.Create(tmp[j].getName+ ' field length is'+inttostr(system.Length(byte1))+', It should be ' +inttostr(tmp[j].getLength)+'.');
      byte0[(k+i)]:=byte1[i];
    end;
    k:=k+tmp[j].getLength;
  end;
  self.WriteBuffStream.WriteData(TExtFuns.IfThen(delflag,42,32));
  self.WriteBuffStream.WriteBuffer(byte0,0,length(byte0));
  dbfield.Free;
  tmp.Free;
end;

constructor TDBFWrite.Create(DBfields: Tlist<TDBfield>);
begin
  self.fields:=DBfields;
  self.dbfEncoding:=TEncoding.Default;
  self.WriteBuffStream:=tmemorystream.Create;
end;

destructor TDBFWrite.Destroy;
var
i:Integer;
begin
  for I := 0 to Self.fields.Count-1 do Self.fields.Items[i].Free;
  Self.fields.Free;
  Self.WriteBuffStream.Free;
  inherited;
end;

procedure TDBFWrite.initHead2Stream(recCount: integer);
var
i,j:integer;
begin
  try
    begin
    self.writeHeader(recCount);
    j:=1;
    for I := 0 to self.fields.Count-1 do
    begin
      self.writeFieldHeader(self.fields[i],j);
      j:=j+self.fields[i].getLength;
    end;
    self.WriteBuffStream.WriteData(13);
    end;
  except on E: Exception do raise E;
  end;
end;

procedure TDBFWrite.SetEncode(encode: TEncoding);
begin
  self.dbfEncoding:=encode;
end;

procedure TDBFWrite.wirteStream2File(filename: string);
var
desf:TFileStream;
begin
  try
  begin
    desf:=tfilestream.Create(filename,fmOpenReadWrite or fmShareDenyNone);
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

procedure TDBFWrite.writeFieldHeader(field: TDBField; loc: integer);
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
  DecodeDate(SysUtils.Date,year,mon,da);
  DBhea.dbdate[0]:=byte(year-1900);
  DBhea.dbdate[1]:=byte(mon);
  DBhea.dbdate[2]:=byte(da);
  DBhea.dbrecoun:=recCount;
  i:=(self.fields.Count+1)*32+1;
  DBHea.DBHeadLen:=i;
  i:=1;
  for j := 0 to self.fields.Count-1 do i:=i+self.fields[j].getLength;
  DBhea.DBRecLen:=i;
  for I := 0 to 19 do DBhea.DBRest[i]:=byte(0);
  self.WriteBuffStream.WriteBuffer(DBhea,sizeof(DBhead));
end;

end.
