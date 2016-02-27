unit mystock.interfaces;

interface
uses
  Generics.Collections, ArrayEx, System.SysUtils, System.Variants, System.Classes,system.Math,
  mystock.types,IdGlobal, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient;

type

  Idata_CMD= interface
    procedure run_command(map:TDictionary<string,TArrayEx<Variant>>);
  end;

  Idata_recive=interface
    function start:Boolean;
    function stop:Boolean;
    function make_command:Idata_CMD;
  end;

  Idata_make=interface
    function Serial: Idata_CMD;
    function getdate(body_ln: UInt32): Boolean;
  end;

  Idata_trans = interface
    function cover_data(d_map:TDictionary<string,tarrayex<variant>>;queue:TQueue<tarrayex<Variant>>):Integer;
    function  write_dbf(filename:string):Boolean;
  end;

  Idata_task=interface
    procedure update;
    function getmap:TDictionary<string,TArrayEx<Variant>>;
  end;

  IDBField=interface
    function GetName:AnsiString;
	  function GetType:ansichar;
	  function GetLength:Byte;
	  function GetDeci:Byte;
	  function format(obj:variant):string;
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

  Ivisiter=interface
    procedure update(ls:TStringList);
  end;

  Ttask = class(TInterfacedObject, Idata_task)
  protected
    fdbfpath:string;
    ffreg:integer;
    fmap:TDictionary<string,TArrayEx<Variant>>;
  public
    procedure update;virtual;abstract;
    function getmap:TDictionary<string,TArrayEx<Variant>>;
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



{ Ttask }

function Ttask.getmap: TDictionary<string, TArrayEx<Variant>>;
begin
  Result:=fmap;
end;

end.
