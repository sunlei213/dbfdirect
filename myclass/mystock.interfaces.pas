unit mystock.interfaces;

interface
uses
  Generics.Collections, ArrayEx, System.SysUtils, System.Variants, System.Classes,system.Math,
  mystock.types,IdGlobal, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,SyncObjs;

type
  Ivisiter=interface
    procedure update(ls:TDictionary<Integer,Integer>);
  end;

  Ilocker=interface
    procedure Lock;
    procedure UnLock;
  end;

  Iwrite=interface
    procedure update;
    procedure write;
    function getmap:TDictionary<string,tarrayex<variant>>;
    function gettype:Dbf_Type;
    function getlock:TCriticalSection;
    property map:TDictionary<string,tarrayex<variant>> read getmap;
    property w_type:Dbf_Type read gettype;
    property MyLock:TCriticalSection read getlock;
  end;

  Idata_CMD= interface
    function run_command(regs:TList<Iwrite>):Enum_CMD;
  end;

  Idata_recive=interface
    function start:Boolean;
    function stop:Boolean;
    function getstatus:rec_stat;
    function make_command:Idata_CMD;
    procedure vi_reg(vi:ivisiter);
  end;

  Idata_make=interface
    function Serial: Idata_CMD;
    function getdate(body_ln: UInt32): Boolean;
  end;

  Idata_trans = interface
    function cover_data(d_map:TDictionary<string,tarrayex<variant>>;queue:TQueue<tarrayex<Variant>>):Integer;
    function  write_dbf(filename:string):Boolean;
  end;


  IDBField=interface
    function GetName:AnsiString;
	  function GetType:ansichar;
	  function GetLength:Byte;
	  function GetDeci:Byte;
	  function format(obj:variant):string;
    function unformatValue(st:string):Variant;
	  function parse(s:string):variant;
	  procedure SetName(na:AnsiString);
	  procedure SetType(ty:ansichar);
	  procedure SetLength(le:Byte);
	  procedure SetDeci(deci:Byte);
    property name:AnsiString read GetName write SetName;
    property Field_type:AnsiChar read GetType write SetType;
    property length:Byte read GetLength write SetLength;
    property dec:Byte read GetDeci write SetDeci;

  end;

  IDBFRead=interface
    function initStream2Head:Integer;
    function readRecord(recnum:Integer):tarrayex<variant>;
    function ReadFile2Stream(filename:string):Boolean;
    procedure SetEncoder(encode:TEncoding);
  end;

  IDBFwrite=interface
    procedure initHead2Stream(recCount:integer);
    procedure addRecord(delflag:boolean;objs:tarrayex<variant>);
    procedure addRecord0(delflag:boolean;objs:tarrayex<variant>);
    procedure wirteStream2File(filename:string);
    procedure SetEncode(encode:TEncoding);
  end;




  Tstock = class(TInterfacedObject, Idata_make)
  private

  protected
    tby: TIdBytes;
    AClient: TIdTCPClient;
    chk: UInt32;
    data_stream: TArrayEx<Variant>;
    procedure recvbuff;
  public
    constructor Create(AClient: TIdTCPClient; msg_type: UInt32);
    function Serial: Idata_CMD;virtual; abstract;
    function getdate(body_ln: UInt32): Boolean; virtual; abstract;
  end;
implementation
{ Tstock }


constructor Tstock.Create(AClient: TIdTCPClient; msg_type: UInt32);
var
  il: uin32;
begin
  Self.AClient := AClient;
  il.i32 := msg_type;
  chk := il.by32[3] + il.by32[2] + il.by32[1] + il.by32[0];
end;


procedure Tstock.recvbuff;
var
  I, j: Integer;
begin
  j := Length(self.tby);
  Self.AClient.IOHandler.ReadBytes(self.tby, j, False);
  for I := 0 to j - 1 do
    Self.chk := Self.chk + self.tby[i];
end;


end.
