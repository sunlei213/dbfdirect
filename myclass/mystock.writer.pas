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

  TSJSZS_wr=class(TMy_Writer)
  protected
    procedure initfield;override;

  public
    constructor Create;
    procedure init_data;override;
    destructor Destroy; override;
  end;

  TSJSXXN_wr=class(TMy_Writer)
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
          logger.WriteLog('Œƒº˛%s–¥»Î ß∞‹£¨¥ÌŒÛ¿‡£∫%s,¥ÌŒÛ‘≠“Ú%s', [self.fFilename, e.ClassName,
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
      //∂¡»°hq◊÷∂Œ
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

{ TSJSZS_wr }

constructor TSJSZS_wr.Create;
begin
  inherited;
  ftype:=SJSZS;
end;

destructor TSJSZS_wr.Destroy;
begin

  inherited;
end;

procedure TSJSZS_wr.initfield;
begin
  ffields.Add(TDBField.Create('ZSZSDM', 'C', 6, 0));
  ffields.Add(TDBField.Create('ZSZSQC', 'C', 12, 0));
  ffields.Add(TDBField.Create('ZSYWMC', 'C', 20, 0));
  ffields.Add(TDBField.Create('ZSSSZS', 'N', 11, 4));
  ffields.Add(TDBField.Create('ZSKSZS', 'N', 11, 4));
  ffields.Add(TDBField.Create('ZSZGZS', 'N', 11, 4));
  ffields.Add(TDBField.Create('ZSZDZS', 'N', 11, 4));
  ffields.Add(TDBField.Create('ZSZJZS', 'N', 11, 4));
  ffields.Add(TDBField.Create('ZSCJSL', 'N', 12, 0));
  ffields.Add(TDBField.Create('ZSCJJE', 'N', 17, 3));
end;

procedure TSJSZS_wr.init_data;
var
  dbfread: IDBFRead;
  readtrue: Boolean;
begin
  fFilename := fpath + '\sjszs.dbf';
  if FileExists(ffileName) then
  begin
      //∂¡»°hq◊÷∂Œ
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

{ TSJSXXN_wr }

constructor TSJSXXN_wr.Create;
begin
  inherited;
  ftype:=SJSXXN;
end;

destructor TSJSXXN_wr.Destroy;
begin

  inherited;
end;

procedure TSJSXXN_wr.initfield;
begin
  ffields.Add(TDBField.Create('XXZQDM','C',6,0));
  ffields.Add(TDBField.Create('XXZQJC','C',8,0));
  ffields.Add(TDBField.Create('XXJCQZ','C',4,0));
  ffields.Add(TDBField.Create('XXYWJC','C',20,0));
  ffields.Add(TDBField.Create('XXJCZQ','C',6,0));
  ffields.Add(TDBField.Create('XXISIN','C',12,0));
  ffields.Add(TDBField.Create('XXHYZL','C',3,0));
  ffields.Add(TDBField.Create('XXHBZL','C',2,0));
  ffields.Add(TDBField.Create('XXMGMZ','N',7,2));
  ffields.Add(TDBField.Create('XXZFXL','N',12,0));
  ffields.Add(TDBField.Create('XXLTGS','N',12,0));
  ffields.Add(TDBField.Create('XXSNLR','N',9,4));
  ffields.Add(TDBField.Create('XXBNLR','N',9,4));
  ffields.Add(TDBField.Create('XXLJJZ','N',9,4));
  ffields.Add(TDBField.Create('XXJSFL','N',7,6));
  ffields.Add(TDBField.Create('XXYHSL','N',7,6));
  ffields.Add(TDBField.Create('XXGHFL','N',7,6));
  ffields.Add(TDBField.Create('XXSSRQ','D',8,0));
  ffields.Add(TDBField.Create('XXQXRQ','D',8,0));
  ffields.Add(TDBField.Create('XXDJRQ','D',8,0));
  ffields.Add(TDBField.Create('XXJYDW','N',4,0));
  ffields.Add(TDBField.Create('XXBLDW','N',6,0));
  ffields.Add(TDBField.Create('XXSLDW','N',6,0));
  ffields.Add(TDBField.Create('XXMBXL','N',9,0));
  ffields.Add(TDBField.Create('XXJGDW','N',5,3));
  ffields.Add(TDBField.Create('XXJHCS','N',7,3));
  ffields.Add(TDBField.Create('XXLXCS','N',7,3));
  ffields.Add(TDBField.Create('XXXJXZ','N',1,0));
  ffields.Add(TDBField.Create('XXZTJG','N',9,3));
  ffields.Add(TDBField.Create('XXDTJG','N',9,3));
  ffields.Add(TDBField.Create('XXJGSX','N',9,3));
  ffields.Add(TDBField.Create('XXJGXX','N',9,3));
  ffields.Add(TDBField.Create('XXZHBL','N',5,2));
  ffields.Add(TDBField.Create('XXDBZSL','N',5,2));
  ffields.Add(TDBField.Create('XXRZBD','C',1,0));
  ffields.Add(TDBField.Create('XXRQBD','C',1,0));
  ffields.Add(TDBField.Create('XXCFBZ','C',1,0));
  ffields.Add(TDBField.Create('XXZSBZ','C',1,0));
  ffields.Add(TDBField.Create('XXSCDM','C',2,0));
  ffields.Add(TDBField.Create('XXZQLB','C',4,0));
  ffields.Add(TDBField.Create('XXZQJB','C',1,0));
  ffields.Add(TDBField.Create('XXZQZT','C',1,0));
  ffields.Add(TDBField.Create('XXJYLX','C',1,0));
  ffields.Add(TDBField.Create('XXJYJD','C',1,0));
  ffields.Add(TDBField.Create('XXTPBZ','C',1,0));
  ffields.Add(TDBField.Create('XXRZZT','C',1,0));
  ffields.Add(TDBField.Create('XXRQZT','C',1,0));
  ffields.Add(TDBField.Create('XXRQJX','C',1,0));
  ffields.Add(TDBField.Create('XXWLTP','C',1,0));
  ffields.Add(TDBField.Create('XXYWZT','C',8,0));
  ffields.Add(TDBField.Create('XXGXSJ','C',6,0));
  ffields.Add(TDBField.Create('XXMARK','C',12,0));
  ffields.Add(TDBField.Create('XXBYBZ','C',1,0));
end;

procedure TSJSXXN_wr.init_data;
var
  dbfread: IDBFRead;
  readtrue: Boolean;
begin
  fFilename := fpath + '\sjsxxn.dbf';
  if FileExists(ffileName) then
  begin
      //∂¡»°hq◊÷∂Œ
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
