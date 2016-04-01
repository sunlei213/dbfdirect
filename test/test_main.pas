unit test_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.TypInfo,System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,System.Generics.Collections,mystock.types,
  mystock.interfaces,ArrayEx, Vcl.ExtCtrls, Vcl.Grids;

type
  TMyThread = class(TThread)
  private
    write_dbfs:TList<Iwrite>;
    frecive:Idata_recive;

  protected
    constructor Create(writ:TList<Iwrite>;rec:Idata_recive);
    procedure Execute; override;
  end;

  TMyVisiter=class(TInterfacedObject, Ivisiter)
  private
    fgrd:TStringGrid;
  public
    procedure update(ls:TDictionary<Integer,Integer>);
    property grd:TStringGrid write fgrd;
  end;

  TForm1 = class(TForm)
    btn1: TButton;
    btn2: TButton;
    lbl1: TLabel;
    tmr1: TTimer;
    lbl2: TLabel;
    edt1: TEdit;
    edt2: TEdit;
    lbl3: TLabel;
    lbl4: TLabel;
    edt3: TEdit;
    strngrd1: TStringGrid;
    edt4: TEdit;
    btn3: TButton;
    mmo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure btn3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses
  mystock.dbfclass,mystock.writer,mystock.classes,mystock.singleinf.logger;
{$R *.dfm}
var
  writes:TList<Iwrite>;
  thread:TMyThread;
  logger:ILogger;
procedure TForm1.btn1Click(Sender: TObject);
var
  rec:Trecive_net;
  vis:TMyVisiter;
begin
  vis:=TMyVisiter.Create;
  vis.grd:=Form1.strngrd1;
  rec:=Trecive_net.Create;
  rec.ip:=edt1.Text;
  rec.port:=StrToInt(edt2.Text);
  rec.user:=edt3.Text;
  rec.passwd:=edt4.Text;
  rec.heart:=3;
  rec.vi_reg(vis);
  btn3.Enabled:=True;
  //tmr1.Enabled:=True;
  btn1.Enabled:=False;
  thread:=TMyThread.Create(writes,rec);
  thread.Start;
end;

procedure TForm1.btn2Click(Sender: TObject);
var
  map: TDictionary<string, tarrayex<Variant>>;
  readdbf: IDBFRead;
  writedbf:IDBFwrite;
  fields: TList<IDBField>;
  reccount: Integer;
  opened: Boolean;
  item: TArrayEx<Variant>;
  ids:TList<string>;
  id: string;
  I: Integer;
begin
  map := TDictionary<string, tarrayex<Variant>>.Create;
  fields := TList<IDBField>.Create;
  readdbf := TDBFWrite.Create(fields);
  writedbf:=TDBFWrite.Create(fields);
  try
    opened := readdbf.ReadFile2Stream('c:\jys\sjshq.dbf');
  except
    on E: Exception do
    begin
      opened := False;
      ShowMessage(e.Message);
    end;
  end;
  if opened then
  try
    reccount := readdbf.initStream2Head;
    opened := True;
  except
    on E: Exception do
    begin
      opened := False;
      ShowMessage(e.Message);
    end;
  end;
  if opened then
    for I := 0 to reccount - 1 do
    begin
      item := readdbf.readRecord(i);
      id := item[0];
      if id='395001' then
       Application.ProcessMessages;
      map.AddOrSetValue(id, item);
    end;
  writedbf.initHead2Stream(reccount);
  ids:=TList<string>.Create(map.Keys);
  try
    begin
      ids.Sort;
      for id in ids do
      begin
      try
        item := map.Items[id];
        if id='395001' then
           Application.ProcessMessages;
        writedbf.addRecord(False, item);
        lbl1.Caption:=id;
      except
        on E: Exception do
          ShowMessage(Format('文件%s写入失败，错误类：%s,错误原因%s', [id, e.ClassName, e.Message]));
      end;
      end;
      try
        writedbf.wirteStream2File('c:\jys\sjshqbak.dbf');
      except
        on E: Exception do
          ShowMessage(Format('文件%s写入失败，错误类：%s,错误原因%s', ['c:\jys\sjshqbak.dbf', e.ClassName, e.Message]));
      end;
    end;
//  for id in ids do .map.Items[id]:=nil;
//  .map.Clear;
  finally
    ids.Free;
  fields.Free;
  map.Free;
  end;

end;

procedure TForm1.btn3Click(Sender: TObject);
begin
  if thread<>nil then
    thread.Terminate;
  tmr1.Enabled:=False;
  btn1.Enabled:=True;
  btn3.Enabled:=False;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  mywrite:TMy_Writer;

begin
  logger:=GetLogInterface();
  logger.LogShower:=Form1.mmo1;
  logger.WriteLog('初始化',2);
  writes:=TList<Iwrite>.Create;
  mywrite:= TSJSHQ_wr.Create;
  mywrite.setpath('c:\jys');
  mywrite.freg:=3;
  mywrite.init_data(True);
  writes.Add(mywrite);
  mywrite:=TSJSZS_wr.Create;
  mywrite.setpath('c:\jys');
  mywrite.freg:=3;
  mywrite.init_data(True);
  writes.Add(mywrite);
  mywrite:=TSJSXXN_wr.Create;
  mywrite.setpath('c:\jys');
  mywrite.freg:=3;
  mywrite.init_data(True);
  writes.Add(mywrite);
  strngrd1.Cells[1,0]:='类别';
  strngrd1.Cells[2,0]:='数量';
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  writes.Clear;
  writes.Free;
end;

procedure TForm1.tmr1Timer(Sender: TObject);
var
  wr:Iwrite;
begin
  for wr in writes do
  begin
    try
    wr.write;
    except on E:Exception  do logger.WriteLog(e.ClassName+':'+e.Message,2);
    end;
  end;
end;

{ TMyThread }

constructor TMyThread.Create(writ: TList<Iwrite>; rec: Idata_recive);
begin
  inherited Create(True);
  write_dbfs:=writ;
  frecive:=rec;
end;

procedure TMyThread.Execute;
var
  status:rec_stat;
  cmd:Idata_CMD;
  noda:Integer;
  log:string;
begin
  inherited;
  noda:=0;
  FreeOnTerminate := True;
  while not Self.Terminated do
  begin
    repeat
    begin
    frecive.start;
    status:=frecive.getstatus;
    log:='状态：'+GetEnumName(TypeInfo(rec_stat),Ord(status));
    logger.WriteLog(log,2);
    Sleep(100);
    end;
    until (status=Repair) or Self.Terminated;
    while ((status=Repair) or (status=NoData) or (status=HasData)) and (not Self.Terminated) do
    begin
      cmd:=frecive.make_command;
      status:=frecive.getstatus;
      Inc(noda);
      if (noda>1000) or (status=HasData) then
      begin
        noda:=0;
        try
        if Assigned(cmd) then
          cmd.run_command(write_dbfs,True)
        else
          logger.WriteLog('cmd为空');
        except on E:Exception  do logger.WriteLog(e.ClassName+':'+e.Message,2);
        end;
      end;
    end;
    log:='状态：'+GetEnumName(TypeInfo(rec_stat),Ord(status));
    logger.WriteLog(log,2);
    frecive.stop;
  end;
end;

{ TMyVisiter }

procedure TMyVisiter.update(ls: TDictionary<Integer, Integer>);
var
  s1:TList<integer>;
  i,j:Integer;
begin
  i:=1;
  s1:=TList<Integer>.Create(ls.Keys);
  with fgrd do
    for j in s1 do
    begin
      Cells[1,i]:= j.ToString;
      Cells[2,i]:= ls[j].ToString;
      inc(i);
    end;
  s1.Free;
end;

end.
