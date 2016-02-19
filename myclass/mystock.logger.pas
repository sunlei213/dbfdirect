unit mystock.logger;

//=======================================================================
//    日志类（TLoger） ver.1.0
//    PFeng  (http://www.pfeng.org / xxmc01#gmail.com)
//    2012/11/08
//    日志级别约定：
//          0 - Information
//          1 - Notice
//          2 - Warning
//          3 - Error
//    使用 Tlogger.Instance生成logger实例
//    使用releaseInstance释放logger实例
//=======================================================================
{$J+}
interface

uses Windows,Classes, SysUtils,StdCtrls,ComCtrls,ComObj,Messages;

const
  WRITE_LOG_DIR = 'log\'; //记录日志默认目录
  WRITE_LOG_MIN_LEVEL = 2; //记录日志的最低级别，小于此级别只显示不记录
  WRITE_LOG_ADD_TIME = True; //记录日志是否添加时间
  WRITE_LOG_TIME_FORMAT = 'hh:nn:ss.zzz';//记录日志添加时间的格式
  SHOW_LOG_ADD_TIME = True; //日志显示容器是否添加时间
  SHOW_LOG_TIME_FORMAT = 'yyyy/mm/dd hh:nn:ss.zzz'; //日志显示添加时间的格式
  SHOW_LOG_CLEAR_COUNT = 1000; //日志显示容器最大显示条数

type
  EnumInstance = (FreeClass, GetClass, SetNil);
TLogger = class
  private
    FCSLock: TRTLCriticalSection; //临界区
    FLogFile: TextFile; //文件流
    FLogShower: TComponent; //日志显示容器
    FLogDir: String; //日志目录
    FLogName: String; //日志名称
    FwriteFile:Boolean;  //是否写日志
    FLogOpened:Boolean;  //日志文件是否已打开
    FAppName:string;
    FInstancecou:Integer;
    procedure SetLogDir(const Value: string);
    procedure SetLogShower(const Value: TComponent);
    procedure SetAppName(const Value:string);
  protected
    constructor CreateInstance;
    class function GetInstance(regues:EnumInstance):Tlogger;
    procedure ShowLog(Log:String; const LogLevel:Integer = 0);
  public
    procedure WriteLog(Log:String; const LogLevel:Integer = 0); overload;
    procedure WriteLog(Log:String; const Args: array of const; const LogLevel:Integer = 0);overload;
    class function Instance:Tlogger;
    class procedure ReleaseInstance;
    constructor Create;
    destructor Destroy; override;
    // 日志文件目录,默认当前目录的Log目录
    property LogFileDir: string read FLogDir write SetLogDir;
    // 显示日志的组件
    property LogShower: TComponent read FLogShower write SetLogShower;
    property AppName:string read FAppName write SetAppName;
end;

implementation

constructor TLogger.Create;
begin
  inherited Create;
  raise Exception.Create('单例对象，日志类对象不能被创建');
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
    ShowLog(Log, LogLevel); //显示日志到容器
    if (LogLevel >= WRITE_LOG_MIN_LEVEL) and FwriteFile then
    begin
      logName := FormatDateTime('yyyymmdd', Now) + '.log';
      if FLogName <> logName then
        FLogName := logName;
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
          // 如果无法打开日志文件
          FLogOpened := False;
          //这里用CloseFile会出现异常
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
      //滚屏到最后一行
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
      ListItem.ImageIndex := LogLevel; //可以根据不同等级显示不同图片
      ListItem.SubItems.Add(Log);
      SendMessage(TListView(FLogShower).Handle,WM_VSCROLL,SB_LINEDOWN,0);
      if TListView(FLogShower).Items.Count >= SHOW_LOG_CLEAR_COUNT then
        TListView(FLogShower).Items.Clear;
    end
    else
      raise Exception.Create('日志容器类型不支持:' + FLogShower.ClassName);
  end;

constructor TLogger.CreateInstance;
begin
  inherited Create;
  InitializeCriticalSection(FCSLock);
  FLogShower := nil;
  FwriteFile:=False;
  FLogOpened:=False;
  FAppName := ChangeFileExt(ExtractFileName(ParamStr(0)),'');
  SetLogDir('');
  FInstancecou:=0;
end;

class function TLogger.Instance: Tlogger;
begin
  Result:=GetInstance(GetClass);
end;

destructor TLogger.Destroy;
begin
  if FLogOpened then
     CloseFile(FLogFile);
  DeleteCriticalSection(FCSLock);
  if GetInstance(FreeClass)=Self then GetInstance(SetNil);
  inherited Destroy;

end;

class function TLogger.GetInstance(regues: EnumInstance): Tlogger;
const
  FInstance:TLogger=nil;
begin
  case regues of
  FreeClass:;
  GetClass:
      if not Assigned(FInstance) then FInstance:=CreateInstance
      else Inc(FInstancecou);
  SetNil:FInstance:=nil;
  end;
  Result:=FInstance;
end;

class procedure TLogger.ReleaseInstance;
begin
  if Finstancecou>1 then
     Dec(Finstancecou)
  else
     GetInstance(FreeClass).Free;
end;

end.
