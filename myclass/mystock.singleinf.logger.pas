unit mystock.singleinf.logger;

interface
uses
 Windows,Classes, SysUtils,StdCtrls,ComCtrls,ComObj,Messages,Vcl.Dialogs,Vcl.Forms;
const
  WRITE_LOG_DIR = 'log\'; //��¼��־Ĭ��Ŀ¼
  WRITE_LOG_MIN_LEVEL = 2; //��¼��־����ͼ���С�ڴ˼���ֻ��ʾ����¼
  WRITE_LOG_ADD_TIME = True; //��¼��־�Ƿ����ʱ��
  WRITE_LOG_TIME_FORMAT = 'hh:nn:ss.zzz';//��¼��־���ʱ��ĸ�ʽ
  SHOW_LOG_ADD_TIME = True; //��־��ʾ�����Ƿ����ʱ��
  SHOW_LOG_TIME_FORMAT = 'yyyy/mm/dd hh:nn:ss.zzz'; //��־��ʾ���ʱ��ĸ�ʽ
  SHOW_LOG_CLEAR_COUNT = 1000; //��־��ʾ���������ʾ����

type
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


{ TTestClass }
 function GetLogInterface(path:string=''):ILogger;

implementation
const
{$J+}  localInstance:ILogger=nil; {$J-}

type
TLogger = class(TInterfacedObject,ILogger)
  private
    FCSLock: TRTLCriticalSection; //�ٽ���
    FLogFile: TextFile; //�ļ���
    FLogShower: TComponent; //��־��ʾ����
    FLogDir: String; //��־Ŀ¼
    FLogName: String; //��־����
    FwriteFile:Boolean;  //�Ƿ�д��־
    FLogOpened:Boolean;  //��־�ļ��Ƿ��Ѵ�
    FAppName:string;
  protected
    procedure ShowLog(Log:String; const LogLevel:Integer = 0);
  public
    constructor Create(path:string);
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

function GetLogInterface(path:string=''):ILogger;
begin
  if not Assigned(localInstance) then
    begin
      System.TMonitor.Enter(Application);
      if not Assigned(localInstance) then
        localInstance:=TLogger.Create(path);
      System.TMonitor.Exit(Application);
    end;

  Result:=localInstance;
end;

{ TLogger }


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

  if FLogOpened then
   CloseFile(FLogFile);
  DeleteCriticalSection(FCSLock);
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



end.
