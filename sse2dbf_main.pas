unit sse2dbf_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,Generics.Collections,
  arrayex,fmtbcd,DBFdirect;

type
  TaskEntry = class
  private
    ffastpath,fshow2003path,ffjypath:string;
    ffreg:integer;
    function getfast: string;
    function getshow: string;
    function getfjy: string;
    function getfreg:integer;
  public
    property fast:string read getfast write ffastpath;
    property show:string read getshow write fshow2003path;
    property fjy:string read getfjy write ffjypath;
    property freg:integer read getfreg write ffreg;
  end;
  TaskRunThread = class(tthread)
  private
    entry:taskentry;
    loger:tstringlist;
    jydate:string;
    isclose:boolean;
    freg:integer;
    T1IOPVMap,IOPVMap:TDictionary<string,string>;
    datamap:TDictionary<integer,tarrayex<variant>>;
    procedure wirteDBF;
    procedure wirteFJY2Show;
    procedure wirteMktdt2Show;
    procedure convertMktdtRecord2Map(rec:String);
    procedure convertFJYRecord2Map(rec:String);
    procedure convertMktdtRec2Map(rec:String;map:TDictionary<integer,tarrayex<variant>>);
    function setFirstRecVal(firstRec,szTradePrice,agTradePrice,bgTradePrice:string):tarrayex<variant>;
    function initHead:Tlist<TDBfield>;
    function firstRecValFormat(headVals:array of string):tarrayex<variant>;
  protected
    procedure Execute; override;
  public
    constructor Create(tasken:taskentry);
  end;
  TForm2 = class(TForm)
    Label1: TLabel;
    fastdir: TEdit;
    Label2: TLabel;
    fjydir: TEdit;
    Label3: TLabel;
    dbfdir: TEdit;
    tran_start: TButton;
    tran_stop: TButton;
    procedure tran_startClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.tran_startClick(Sender: TObject);
begin

end;

{ TaskEntry }

function TaskEntry.getfast: string;
begin
  Result:=trim(self.ffastpath)+@'\mktdt00.txt';
end;

function TaskEntry.getfjy: string;
begin
  Result:=trim(self.ffjypath)+'\\'+formatdatetime('yyyymmdd',date)+'.txt';
end;

function TaskEntry.getfreg: integer;
begin
  Result:=self.ffreg*1000;
end;

function TaskEntry.getshow: string;
begin
  Result:=trim(self.fshow2003path)+@'\show2003.dbf';
end;

{ TaskRunThread }

procedure TaskRunThread.convertFJYRecord2Map(rec: String);
begin

end;

procedure TaskRunThread.convertMktdtRec2Map(rec: String;
  map: TDictionary<integer, tarrayex<variant>>);
begin

end;

procedure TaskRunThread.convertMktdtRecord2Map(rec: String);
begin

end;

constructor TaskRunThread.Create(tasken: taskentry);
begin
  inherited;
  self.entry:=tasken;
  self.freg:=tasken.freg;
  self.loger:=tstringlist.Create;
end;

procedure TaskRunThread.Execute;
var
start,hlong,j,k:integer;
begin
  inherited;
  while NOT self.Terminated do
  begin
    try
     try
       begin
         start:=gettickcount;
         wirteMktdt2Show;
         wirteFJY2Show;
         wirteDBF;
         hlong:=gettickcount-start;
         j:=self.freg-hlong;
         sleep(TExtFuns.IfThen(j>0,j,100));
       end;
     except on E: Exception do loger.Add(e.Message)
     end;
    finally
      begin
        if loger.Count>0 then loger.SaveToFile('log.txt',tencoding.Default);
        loger.Clear;
      end;
    end;
  end;
end;

function TaskRunThread.firstRecValFormat(
  headVals: array of string): tarrayex<variant>;
begin

end;

function TaskRunThread.initHead: Tlist<TDBfield>;
begin

end;

function TaskRunThread.setFirstRecVal(firstRec, szTradePrice, agTradePrice,
  bgTradePrice: string): tarrayex<variant>;
begin

end;

procedure TaskRunThread.wirteDBF;
begin

end;

procedure TaskRunThread.wirteFJY2Show;
begin

end;

procedure TaskRunThread.wirteMktdt2Show;
begin

end;

end.
