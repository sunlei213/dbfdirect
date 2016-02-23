unit mystock.interfaces;

interface
uses
  Generics.Collections, ArrayEx, System.SysUtils, System.Variants, System.Classes,system.Math,
  mystock.types,IdGlobal, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient;

type

  Idata_recive=interface

  end;

  Idata_make=interface
    function Serial(query: TQueue<tarrayex<Variant>>; body_ln: UInt32): Boolean;
    function getdate(body_ln: UInt32): Boolean;
  end;

  Idata_trans = interface
    function cover_data(d_map:TDictionary<string,tarrayex<variant>>;queue:TQueue<tarrayex<Variant>>):Integer;
    function  write_dbf(filename:string):Boolean;
  end;

  Idata_MSG= interface

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
    constructor Create(AClient: TIdTCPClient; i: UInt32);
    function Serial(query: TQueue<tarrayex<Variant>>; body_ln: UInt32): Boolean;
    function getdate(body_ln: UInt32): Boolean; virtual; abstract;
  end;
implementation

end.
