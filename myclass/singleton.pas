unit singleton;

interface
uses
 Windows,Classes, SysUtils,StdCtrls,ComCtrls,ComObj,Messages,Vcl.Dialogs;
const
  WRITE_LOG_DIR = 'log\'; //��¼��־Ĭ��Ŀ¼
  WRITE_LOG_MIN_LEVEL = 2; //��¼��־����ͼ���С�ڴ˼���ֻ��ʾ����¼
  WRITE_LOG_ADD_TIME = True; //��¼��־�Ƿ����ʱ��
  WRITE_LOG_TIME_FORMAT = 'hh:nn:ss.zzz';//��¼��־���ʱ��ĸ�ʽ
  SHOW_LOG_ADD_TIME = True; //��־��ʾ�����Ƿ����ʱ��
  SHOW_LOG_TIME_FORMAT = 'yyyy/mm/dd hh:nn:ss.zzz'; //��־��ʾ���ʱ��ĸ�ʽ
  SHOW_LOG_CLEAR_COUNT = 1000; //��־��ʾ���������ʾ����

type
  imy1=interface
      procedure showjl;
      procedure setjlstr(str1:string);
  end;
  imy2=interface
      procedure show;
      procedure setstr(str1:string);
  end;
  ILogger=interface
    function GetLogDir:string;
    function GetLogshower:TComponent;
    function GetAppName:string;
    procedure SetLogDir(const Value: string);
    procedure SetLogShower(const Value: TComponent);
    procedure SetAppName(const Value:string);
    procedure WriteLog(Log:String; const LogLevel:Integer = 0); overload;
    procedure WriteLog(Log:String; const Args: array of const; const LogLevel:Integer = 0);overload;
    // ��־�ļ�Ŀ¼,Ĭ�ϵ�ǰĿ¼��LogĿ¼
    property LogFileDir: string read GetLogDir write SetLogDir;
    // ��ʾ��־�����
    property LogShower: TComponent read GetLogShower write SetLogShower;
    property AppName:string read GetAppName write SetAppName;

  end;
TLogger = class(TInterfacedObject,ILogger)
  private
    class var FInstance: Tlogger;
    class var isfree:Boolean;
    FCSLock: TRTLCriticalSection; //�ٽ���
    FLogFile: TextFile; //�ļ���
    FLogShower: TComponent; //��־��ʾ����
    FLogDir: String; //��־Ŀ¼
    FLogName: String; //��־����
    FwriteFile:Boolean;  //�Ƿ�д��־
    FLogOpened:Boolean;  //��־�ļ��Ƿ��Ѵ�
    FAppName:string;
    class constructor Create;
    class destructor Destroy;
    constructor Create;
  protected
    procedure ShowLog(Log:String; const LogLevel:Integer = 0);
  public
    class function Instance: Tlogger;
    function GetLogDir:string;
    function GetLogshower:TComponent;
    function GetAppName:string;
    procedure SetLogDir(const Value: string);
    procedure SetLogShower(const Value: TComponent);
    procedure SetAppName(const Value:string);
    procedure WriteLog(Log:String; const LogLevel:Integer = 0); overload;
    procedure WriteLog(Log:String; const Args: array of const; const LogLevel:Integer = 0);overload;
    property LogFileDir: string read GetLogDir write SetLogDir;
    // ��ʾ��־�����
    property LogShower: TComponent read GetLogShower write SetLogShower;
    property AppName:string read GetAppName write SetAppName;
    destructor Destroy; override;
end;
  TmyTest=class(TInterfacedObject,imy1)
    private
      stri:TStringList;
      type
        Tclassname = class
        private
          class var Finstance:TmyTest;
          class var isfree:Boolean;
          class constructor Create;
          class destructor Destroy;
        { private declarations }
        end;
      constructor Create;
   public
    class function GetInstance: TmyTest;
    destructor Destroy;override;
      procedure showjl;
      procedure setjlstr(str1:string);
  end;

  TTestClass = class(TInterfacedObject,imy2)
  private
    class var FInstance: TTestClass;
    class var isfree:Boolean;
    st:string;
    stl:TStringList;
    class constructor Create;
    class destructor Destroy;
    constructor Create;
  public
    class function GetInstance: TTestClass;
    destructor Destroy;override;
    procedure show;
    procedure setstr(str1:string);
  end;

{ TTestClass }

implementation

class constructor TTestClass.Create;
begin
  TTestClass.FInstance:=TTestClass.Create;
  TTestClass.isfree:=True;
end;

constructor TTestClass.Create;
begin
  inherited;
  st:='��ʼ�ɹ�';
  stl:=TStringList.Create;
  stl.Add(st);
  ShowMessage(stl[0]);
end;



destructor TTestClass.Destroy;
begin
  if not TTestClass.isfree then
    begin
      stl.Free;
    end;
  inherited;
end;

class destructor TTestClass.Destroy;
begin
  ShowMessage('����ʵ��ɾ��');
    TTestClass.isfree:=False;
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
 end;

class function TTestClass.GetInstance: TTestClass;
begin
  Result := FInstance;
end;


procedure TTestClass.setstr(str1: string);
begin
  st:=str1;
  stl[0]:=str1;
end;

procedure TTestClass.show;
begin
  ShowMessage(stl[0]);
end;


{ TmyTest }

constructor TmyTest.Create;
begin
  inherited;
  stri:=TStringList.Create;
  stri.Add('');
  ShowMessage('���ഴ��');
end;

destructor TmyTest.Destroy;
begin
  if TmyTest.Tclassname.isfree then
  begin
  ShowMessage('����ɾ��');
  stri.Free;
  end;
  inherited;
end;

class function TmyTest.GetInstance: TmyTest;
begin
   Result:=Tclassname.Finstance;
end;

procedure TmyTest.setjlstr(str1: string);
begin
  stri[0]:=str1;
end;

procedure TmyTest.showjl;
begin
  ShowMessage(stri[0]);
end;

{ TmyTest.Tclassname }

class constructor TmyTest.Tclassname.Create;
begin
   tmytest.Tclassname.isfree:=False;
   TmyTest.Tclassname.Finstance:=TmyTest.Create;
end;

class destructor TmyTest.Tclassname.Destroy;
begin
  TmyTest.Tclassname.isfree:=True;
  if Assigned(Tclassname.Finstance) then FreeAndNil(Tclassname.Finstance);
end;

{ TLogger }

class constructor TLogger.Create;
begin
  TLogger.FInstance:=TLogger.Create;
  TLogger.isfree:=False;
end;

constructor TLogger.Create;
begin
  inherited Create;
  InitializeCriticalSection(FCSLock);
  FLogShower := nil;
  FwriteFile:=False;
  FLogOpened:=False;
  FAppName := ChangeFileExt(ExtractFileName(ParamStr(0)),'');
  SetLogDir('');
end;

destructor TLogger.Destroy;
begin
  if isfree then
  begin
    if FLogOpened then
      CloseFile(FLogFile);
    DeleteCriticalSection(FCSLock);
  end;
  inherited Destroy;

end;

function TLogger.GetAppName: string;
begin
  Result:=FAppName;
end;

function TLogger.GetLogDir: string;
begin
  Result:=FLogDir;
end;

function TLogger.GetLogshower: TComponent;
begin
  Result:=FLogShower;
end;

class destructor TLogger.Destroy;
begin
  TLogger.isfree:=True;
  if Assigned(TLogger.FInstance) then FreeAndNil(TLogger.FInstance);
end;

procedure TLogger.WriteLog(Log: string; const Args: array of const; const
  LogLevel: Integer = 0);
begin
  WriteLog(Format(Log, args), LogLevel);
end;

procedure TLogger.WriteLog(Log: string; const LogLevel: Integer = 0);
var
  logName: string;
  fMode: Word;
  filename: string;
begin
  EnterCriticalSection(FCSLock);
  try
    ShowLog(Log, LogLevel); //��ʾ��־������
    if (LogLevel >= WRITE_LOG_MIN_LEVEL) and FwriteFile then
    begin
      logName := FormatDateTime('yyyymmdd', Now) + '.log';
      if FLogName <> logName then
      begin
        FLogName := logName;
        if FLogOpened then
          CloseFile(FLogFile);
        FLogOpened := False;
      end;
      filename := FLogDir + FAppName + FLogName;
      if not FLogOpened then
      begin
        Assignfile(FLogFile, fileName);
        try
          if FileExists(fileName) then
            append(FLogFile)
          else
            rewrite(FLogFile);
          FLogOpened := True;
        except
          // ����޷�����־�ļ�
          FLogOpened := False;
          //������CloseFile������쳣
          //CloseFile(FLogFile);
          exit;
        end;
      end;
      if FLogOpened then
      begin
        case LogLevel of
          0:
            Log := '[Information] ' + Log;
          1:
            Log := '[Notice] ' + Log;
          2:
            Log := '[Warning] ' + Log;
          3:
            Log := '[Error] ' + Log;
        end;
        if WRITE_LOG_ADD_TIME then
          Log := FormatDateTime(WRITE_LOG_TIME_FORMAT, Now) + ' ' + Log;
        try
          Writeln(FLogFile, Log);
          Flush(FLogFile);
        except
        end;
      end;
    end;
  finally
    LeaveCriticalSection(FCSLock);
  end;
end;

procedure TLogger.SetAppName(const Value: string);
begin
  FAppName:=Value;
end;

procedure TLogger.SetLogDir(const Value: string);
begin
  if Trim(Value) = '' then
    FLogDir := ExtractFilePath(ParamStr(0)) + WRITE_LOG_DIR
  else
    FLogDir := Value;
  if not DirectoryExists(FLogDir) then
  if not ForceDirectories(FLogDir) then
  begin
    FwriteFile:=False;
    Exit;
  end;
  FwriteFile:=True;
end;

procedure TLogger.SetLogShower(const Value: TComponent);
begin
  if (Value is TMemo) or (Value is TListBox) or (Value is TListView) then
    FLogShower:=Value;
end;

procedure TLogger.ShowLog(Log:String; const LogLevel:Integer = 0);
  var
    lineCount: Integer;
    listItem: TListItem;
  begin
    if FLogShower = nil then Exit;
    if (FLogShower is TMemo) then
    begin
      if SHOW_LOG_ADD_TIME then
      Log := FormatDateTime(SHOW_LOG_TIME_FORMAT, Now) + ' '+ Log;
      lineCount := TMemo(FLogShower).Lines.Add(Log);
      //���������һ��
      SendMessage(TMemo(FLogShower).Handle,WM_VSCROLL,SB_LINEDOWN,0);
      if lineCount >= SHOW_LOG_CLEAR_COUNT then
        TMemo(FLogShower).Clear;
    end
    else if (FLogShower is TListBox) then
    begin
      if SHOW_LOG_ADD_TIME then
      Log := FormatDateTime(SHOW_LOG_TIME_FORMAT, Now) + ' '+ Log;
      lineCount := TListBox(FLogShower).Items.Add(Log);
      SendMessage(TListBox(FLogShower).Handle,WM_VSCROLL,SB_LINEDOWN,0);
      if lineCount >= SHOW_LOG_CLEAR_COUNT then
        TListBox(FLogShower).Clear;
    end
    else if (FLogShower is TListView) then
    begin
      ListItem := TListView(FLogShower).Items.Add;
      if SHOW_LOG_ADD_TIME then
      ListItem.Caption := FormatDateTime(SHOW_LOG_TIME_FORMAT, Now);
      if Assigned(TListView(FLogShower).SmallImages) and
       (TListView(FLogShower).SmallImages.Count - 1 >= LogLevel) then
      ListItem.ImageIndex := LogLevel; //���Ը��ݲ�ͬ�ȼ���ʾ��ͬͼƬ
      ListItem.SubItems.Add(Log);
      SendMessage(TListView(FLogShower).Handle,WM_VSCROLL,SB_LINEDOWN,0);
      if TListView(FLogShower).Items.Count >= SHOW_LOG_CLEAR_COUNT then
        TListView(FLogShower).Items.Clear;
    end
    else
      raise Exception.Create('��־�������Ͳ�֧��:' + FLogShower.ClassName);
  end;


class function TLogger.Instance: Tlogger;
begin
  Result:=FInstance;
end;

end.
