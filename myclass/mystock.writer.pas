unit mystock.writer;

interface
uses
  mystock.types,mystock.interfaces,mystock.dbfclass,Generics.Collections, ArrayEx, System.SysUtils, System.Variants, System.Classes,system.Math;
type
{ TMy_Writer }

  TMy_Writer = class(TInterfacedObject, Iwrite)
  protected
    fmap:TDictionary<string,tarrayex<variant>>;
    ftype:Dbf_Type;
    fFilename:string;
    fpath:string;
    ffreg:Integer;
    fstart:Integer;
    ffields:TList<IDBField>;
    function getfreg:Integer;
    procedure setfreg(sec:Integer);
    procedure writedbf;virtual;
    procedure initfield;virtual;abstract;
  public
    constructor Create;
    procedure setpath(path:string);
    procedure init_data;virtual;abstract;
    destructor Destroy; override;
    procedure update;
    function getmap:TDictionary<string,tarrayex<variant>>;
    function gettype:Dbf_Type;
    property map:TDictionary<string,tarrayex<variant>> read getmap;
    property w_type:Dbf_Type read gettype;
    property freg:Integer read getfreg write setfreg;
  end;

  TSJSHQ_wr=class(TMy_Writer)
  protected
    procedure initfield;override;

  public
    constructor Create;
    procedure init_data;override;
    destructor Destroy; override;
  end;

implementation
uses
  mystock.singleinf.logger;

{ TMy_Writer }

constructor TMy_Writer.Create;
begin
  inherited;
  fmap:=TDictionary<string,tarrayex<variant>>.Create;
  ffreg:=0;
  fstart:=0;
  ffields:=TList<IDBField>.Create;
end;

destructor TMy_Writer.Destroy;
begin
  if Assigned(fmap) then
    FreeAndNil(fmap);
  if Assigned(ffields) then
    FreeAndNil(ffields);
  inherited;
end;

function TMy_Writer.getfreg: Integer;
begin
   Result:=ffreg div 1000;
end;

function TMy_Writer.getmap: TDictionary<string, tarrayex<variant>>;
begin
   Result:=fmap;
end;

function TMy_Writer.gettype: Dbf_Type;
begin
   Result:=ftype;
end;

procedure TMy_Writer.setfreg(sec: Integer);
begin
   ffreg:=sec*1000;
end;

procedure TMy_Writer.setpath(path: string);
begin
  fpath:=path;
end;

procedure TMy_Writer.update;
var
  time_now:Integer;
begin
  if (fstart=0) then
  begin
    fstart:=TThread.GetTickCount;
  end;
  time_now:=TThread.GetTickCount;
  time_now:=time_now-fstart;
  if (time_now>ffreg) then
  begin
    writedbf;
    fstart:=TThread.GetTickCount;
  end;
end;

procedure TMy_Writer.writedbf;
var
  stl: TList<string>;
  st1: string;
  write1: IDBFwrite;
  obj1: TArrayEx<Variant>;
  delflag: Boolean;
  logger: ILogger;
begin
  stl := TList<string>.Create(Self.fmap.Keys);
  write1 := TDBFWrite.Create(ffields);
  write1.initHead2Stream(Self.fmap.Count);
  logger := GetLogInterface;
  try
    begin
      stl.Sort;
      MonitorEnter(fmap);
      try
        for st1 in stl do
        begin
          obj1 := Self.fmap.Items[st1];
          delflag := False;
          write1.addRecord(delflag, obj1);
        end;
      finally
        MonitorExit(fmap);
      end;
      try
        write1.wirteStream2File(Self.fFilename);
      except
        on E: Exception do
          logger.WriteLog('文件%s写入失败，错误类：%s,错误原因%s', [self.fFilename, e.ClassName,
            e.Message], 2);
      end;
    end;
//  for st1 in stl do Self.datamap.Items[st1]:=nil;
//  Self.datamap.Clear;
  finally
    stl.Free;
    write1 := nil;
    logger := nil;
  end;

end;


{ TSJSHQ_wr }

constructor TSJSHQ_wr.Create;
begin
  inherited;
  ftype:=SJSHQ;
end;

destructor TSJSHQ_wr.Destroy;
begin

  inherited;
end;

procedure TSJSHQ_wr.initfield;
begin
  ffields.Add(TDBField.Create('HQZQDM', 'C', 6, 0));
  ffields.Add(TDBField.Create('HQZQJC', 'C', 8, 0));
  ffields.Add(TDBField.Create('HQZRSP', 'N', 9, 3));
  ffields.Add(TDBField.Create('HQJRKP', 'N', 9, 3));
  ffields.Add(TDBField.Create('HQZJCJ', 'N', 9, 3));
  ffields.Add(TDBField.Create('HQCJSL', 'N', 12, 0));
  ffields.Add(TDBField.Create('HQCJJE', 'N', 17, 3));
  ffields.Add(TDBField.Create('HQCJBS', 'N', 9, 0));
  ffields.Add(TDBField.Create('HQZGCJ', 'N', 9, 3));
  ffields.Add(TDBField.Create('HQZDCJ', 'N', 9, 3));
  ffields.Add(TDBField.Create('HQSYL1', 'N', 7, 2));
  ffields.Add(TDBField.Create('HQSYL2', 'N', 7, 2));
  ffields.Add(TDBField.Create('HQJSD1', 'N', 9, 3));
  ffields.Add(TDBField.Create('HQJSD2', 'N', 9, 3));
  ffields.Add(TDBField.Create('HQHYCC', 'N', 12, 0));
  ffields.Add(TDBField.Create('HQSJW5', 'N', 9, 3));
  ffields.Add(TDBField.Create('HQSSL5', 'N', 12, 0));
  ffields.Add(TDBField.Create('HQSJW4', 'N', 9, 3));
  ffields.Add(TDBField.Create('HQSSL4', 'N', 12, 0));
  ffields.Add(TDBField.Create('HQSJW3', 'N', 9, 3));
  ffields.Add(TDBField.Create('HQSSL3', 'N', 12, 0));
  ffields.Add(TDBField.Create('HQSJW2', 'N', 9, 3));
  ffields.Add(TDBField.Create('HQSSL2', 'N', 12, 0));
  ffields.Add(TDBField.Create('HQSJW1', 'N', 9, 3));
  ffields.Add(TDBField.Create('HQSSL1', 'N', 12, 0));
  ffields.Add(TDBField.Create('HQBJW1', 'N', 9, 3));
  ffields.Add(TDBField.Create('HQBSL1', 'N', 12, 0));
  ffields.Add(TDBField.Create('HQBJW2', 'N', 9, 3));
  ffields.Add(TDBField.Create('HQBSL2', 'N', 12, 0));
  ffields.Add(TDBField.Create('HQBJW3', 'N', 9, 3));
  ffields.Add(TDBField.Create('HQBSL3', 'N', 12, 0));
  ffields.Add(TDBField.Create('HQBJW4', 'N', 9, 3));
  ffields.Add(TDBField.Create('HQBSL4', 'N', 12, 0));
  ffields.Add(TDBField.Create('HQBJW5', 'N', 9, 3));
  ffields.Add(TDBField.Create('HQBSL5', 'N', 12, 0));

end;

procedure TSJSHQ_wr.init_data;
var
  dbfread: IDBFRead;
  readtrue: Boolean;
begin
  fFilename := fpath + '\sjshq.dbf';
  if FileExists(ffileName) then
  begin
      //读取hq字段
    dbfread := TDBFWrite.Create(ffields);
    try
      readtrue := dbfread.ReadFile2Stream(fFilename);
    except
      on E: Exception do
      begin
        initfield;
        Exit;
      end;
    end;
    if readtrue then
      dbfread.initStream2Head
    else
      initfield;
  end
  else
  begin
    initfield;
  end;
end;

end.
