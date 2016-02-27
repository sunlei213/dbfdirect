unit mystock.commands;

interface
uses
  mystock.types,mystock.interfaces,Generics.Collections, ArrayEx, System.SysUtils, System.Variants, System.Classes,system.Math;
type
  TNoCmd=class(TInterfacedObject, Idata_CMD )
  public
    procedure run_command(map:TDictionary<string,TArrayEx<Variant>>);
  end;
implementation

{ TNoCmd }

procedure TNoCmd.run_command(map: TDictionary<string, TArrayEx<Variant>>);
begin

end;

end.
