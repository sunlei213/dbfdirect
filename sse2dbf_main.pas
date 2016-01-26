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
    logger:tstringlist;
    constructor Create;
    constructor Destory;
    property fast:string read getfast write ffastpath;
    property show:string read getshow write fshow2003path;
    property fjy:string read getfjy write ffjypath;
    property freg:integer read getfreg write ffreg;
  end;
  TaskRunThread = class(tthread)
  private
    entry:taskentry;
    jydate:string;
    isclose:boolean;
    freg:integer;
    T1IOPVMap,IOPVMap:TDictionary<string,string>;
    datamap:TDictionary<string,tarrayex<variant>>;
    procedure wirteDBF;
    procedure wirteFJY2Show;
    procedure wirteMktdt2Show;
    procedure convertMktdtRecord2Map(rec:String);
    procedure convertFJYRecord2Map(rec:String;map:TDictionary<string,tarrayex<variant>>);
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

constructor TaskEntry.Create;
begin
  logger:=tstringlist.Create;
end;

constructor TaskEntry.Destory;
begin
  logger.Free;
end;

function TaskEntry.getfast: string;
begin
  Result:=trim(self.ffastpath)+'\\mktdt00.txt';
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
  Result:=trim(self.fshow2003path)+'\\show2003.dbf';
end;

{ TaskRunThread }


procedure TaskRunThread.convertFJYRecord2Map(rec: String;
  map: TDictionary<string, tarrayex<variant>>);
var
sl1,cast:tstringlist;
obj:tarrayex<variant>;
s1,id,type1:string;
i:Integer;
begin
  if Trim(rec)='' then Exit;
  sl1:=TStringList.Create;
  sl1.Delimiter:='|';
  sl1.DelimitedText:=rec;
  for I := 0 to sl1.Count-1 do sl1[i]:=Trim(sl1[i]);
  obj:=tarrayex<Variant>.Create(['','','0.0','0.0','0',
                                '0.0','0.0','0.0','0.0','0.0',
                                '0',null,'0','0.0','0','0.0',
                                '0','0','0.0','0','0.0',
                                '0','0.0','0','0.0','0','0.0',
                                '0','0.0','0']);
  type1:=sl1[5];
  id:=sl1[1];
  obj[0]:=id;
  obj[1]:=sl1[2];
  if (sl1[6]<>'') and  (AnsiCompareStr(self.jydate,sl1[6])>0) then
     obj[11]:=True
  else if (sl1[7]<>'') and  (AnsiCompareStr(self.jydate,sl1[7])>0) then
     obj[11]:=True;
  cast:=TStringList.Create;
  cast.Add('IN'); //0
  cast.Add('IS'); //1
  cast.Add('PH'); //2
  cast.Add('KK'); //3
  cast.Add('HK'); //4
  cast.Add('R1'); //5
  cast.Add('R2'); //6
  cast.Add('R3'); //7
  cast.Add('R4'); //8
  cast.Add('FS'); //9
  cast.Add('FC'); //10
  cast.Add('CV'); //11
  cast.Add('CR'); //12
  cast.Add('OC'); //13
  cast.Add('OR'); //14
  cast.Add('OS'); //15
  cast.Add('OT'); //16
  cast.Add('OD'); //17
  cast.Add('OV'); //18
  cast.Add('BD'); //19
  cast.Add('BW'); //20
  cast.Add('EC'); //21
  cast.Add('ER'); //22
  cast.Add('EZ'); //23
  case cast.IndexOf(type1) of
  0,1,9,10,12: obj[2]:=sl1[11];
  2,3,4   :
           begin
             obj[2]:=sl1[11];
             obj[11]:=True;
           end;
  5,6,7,8 :
           begin
             obj[2]:=sl1[11];
             obj[3]:=obj[2];
           end;
  11:      obj[2]:='100.000';
  13,14   :
           begin
             obj[2]:=sl1[24];
             obj[7]:=sl1[25];
           end;
  15,19,20:obj[2]:='1.000';
  16,17,18:obj[2]:='0.000';
  21,22   :
           begin
             s1:=Self.T1IOPVMap.Items[sl1[3]];
             if s1<>null then
             obj[2]:=s1;
             s1:=Self.IOPVMap.Items[sl1[3]];
             if s1<>null then
             obj[7]:=s1;
           end;
  23      :obj[11]:=True;
  else
          begin
            if (id='799988') or (id='799996') or (id='799998') or (id='799999') or (id='939988') then
            obj[2]:='1.000';
          end;
  end;
  map.AddOrSetValue(sl1[1],obj);
end;

procedure TaskRunThread.convertMktdtRecord2Map(rec: String);
var
sl1:tstringlist;
obj:tarrayex<variant>;
s1,type1:string;
i:Integer;
begin
  if Trim(rec)='' then Exit;
  sl1:=TStringList.Create;
  sl1.Delimiter:='|';
  sl1.DelimitedText:=rec;
  for I := 0 to sl1.Count-1 do sl1[i]:=Trim(sl1[i]);
  type1:=sl1[0];
  if type1='TRAILER' then Exit;
  obj.SetLen(30);
  if type1='MD0001' then
    begin
      obj[0]:=sl1[1];
      obj[1]:=sl1[2];
      obj[2]:=sl1[5];
      obj[3]:=sl1[6];
      s1:=BcdToStr(BCDRoundTo(strtobcd(sl1[4]),0));
      if Length(Trim(s1))>12 then
      s1:='999999999999';
      obj[4]:=s1;
      obj[5]:=sl1[7];
      obj[6]:=sl1[8];
      obj[7]:=TExtFuns.IfThen(Self.isclose,sl1[10],sl1[9]);
      obj[10]:= sl1[3];;
      obj[11]:=True;
    end
  else
    begin
      obj[0]:=sl1[1];
      obj[1]:=sl1[2];
      obj[2]:=sl1[5];
      obj[3]:=sl1[6];
      s1:=BcdToStr(BCDRoundTo(strtobcd(sl1[4]),0));
      if Length(Trim(s1))>12 then
      s1:='999999999999';
      obj[4]:=s1;
      obj[5]:=sl1[7];
      obj[6]:=sl1[8];
      obj[7]:=TExtFuns.IfThen(Self.isclose,sl1[10],sl1[9]);
      obj[8]:=sl1[11];
      obj[9]:=sl1[13];
      obj[10]:= sl1[3];;
      s1:=TExtFuns.IfThen(type1='MD004',sl1[33],sl1[31]);
      obj[11]:=TExtFuns.IfThen(((Copy(s1,0,1)<>'P') and (Copy(s1,2,1)='1')),False,True);
      obj[12]:=sl1[12];
      obj[13]:=sl1[15];
      obj[14]:=sl1[16];
      obj[15]:=sl1[19];
      obj[16]:=sl1[20];
      obj[17]:=sl1[14];
      obj[18]:=sl1[17];
      obj[19]:=sl1[18];
      obj[20]:=sl1[21];
      obj[21]:=sl1[22];
      obj[23]:=sl1[24];
      obj[24]:=sl1[27];
      obj[25]:=sl1[28];
      obj[26]:=sl1[25];
      obj[27]:=sl1[26];
      obj[28]:=sl1[29];
      obj[29]:=sl1[30];
    end;
  if type1='MD004' then
  begin
    Self.T1IOPVMap.AddOrSetValue(sl1[1],sl1[31]);
    Self.IOPVMap.AddOrSetValue(sl1[1],sl1[32]);
  end;
  Self.datamap.AddOrSetValue(sl1[1],obj);
end;

constructor TaskRunThread.Create(tasken: taskentry);
begin
  self.entry:=tasken;
  self.freg:=tasken.freg;
  Self.datamap:=TDictionary<string,TArrayEx<Variant>>.Create;
  inherited Create(True);
end;

procedure TaskRunThread.Execute;
var
start,hlong,j,k,l:integer;
begin
  inherited;
  while NOT self.Terminated do
  begin
     try
       begin
         start:=gettickcount;
         wirteMktdt2Show;
         wirteFJY2Show;
         wirteDBF;
         hlong:=gettickcount-start;
         j:=self.freg-hlong;
         l:=100;
         k:=TExtFuns.IfThen((j>0),j,l);
         sleep(k);
       end;
     except on E: Exception do self.entry.logger.Add(e.Message)
     end;
  end;
end;

function TaskRunThread.firstRecValFormat(
  headVals: array of string): tarrayex<variant>;
begin

end;

function TaskRunThread.initHead: Tlist<TDBfield>;
var
fdl:TList<TDBField>;
begin
  fdl:=TList<TDBField>.Create;
  fdl.Add(TDBField.Create('S1', 'C', 6, 0));
  fdl.Add(TDBField.Create('S2', 'C', 8, 0));
  fdl.Add(TDBField.Create('S3', 'N', 8, 3));
  fdl.Add(TDBField.Create('S4', 'N', 8, 3));
  fdl.Add(TDBField.Create('S5', 'N', 12, 0));
  fdl.Add(TDBField.Create('S6', 'N', 8, 3));
  fdl.Add(TDBField.Create('S7', 'N', 8, 3));
  fdl.Add(TDBField.Create('S8', 'N', 8, 3));
  fdl.Add(TDBField.Create('S9', 'N', 8, 3));
  fdl.Add(TDBField.Create('S10', 'N', 8, 3));
  fdl.Add(TDBField.Create('S11', 'N', 10, 0));
  fdl.Add(TDBField.Create('S13', 'N', 8, 3));
  fdl.Add(TDBField.Create('S15', 'N', 10, 0));
  fdl.Add(TDBField.Create('S16', 'N', 8, 3));
  fdl.Add(TDBField.Create('S17', 'N', 10, 0));
  fdl.Add(TDBField.Create('S18', 'N', 8, 3));
  fdl.Add(TDBField.Create('S19', 'N', 10, 0));
  fdl.Add(TDBField.Create('S21', 'N', 10, 0));
  fdl.Add(TDBField.Create('S22', 'N', 8, 3));
  fdl.Add(TDBField.Create('S23', 'N', 10, 0));
  fdl.Add(TDBField.Create('S24', 'N', 8, 3));
  fdl.Add(TDBField.Create('S25', 'N', 10, 0));
  fdl.Add(TDBField.Create('S26', 'N', 8, 3));
  fdl.Add(TDBField.Create('S27', 'N', 10, 0));
  fdl.Add(TDBField.Create('S28', 'N', 8, 3));
  fdl.Add(TDBField.Create('S29', 'N', 10, 0));
  fdl.Add(TDBField.Create('S30', 'N', 8, 3));
  fdl.Add(TDBField.Create('S31', 'N', 10, 0));
  fdl.Add(TDBField.Create('S32', 'N', 8, 3));
  fdl.Add(TDBField.Create('S33', 'N', 10, 0));
  Result:=fdl;
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
