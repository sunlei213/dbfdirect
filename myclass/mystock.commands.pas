unit mystock.commands;

interface
uses
  mystock.types,mystock.interfaces,system.Classes, Generics.Collections, ArrayEx, System.SysUtils, System.Variants,system.Math;
type

{ TSZCmd }

  TCmd = class(TInterfacedObject, Idata_CMD)
  private
    data:TArrayEx<Variant>;
  protected

  public
    constructor Create(da:TArrayEx<Variant>);
    destructor Destroy; override;
    function run_command(regs:TList<Iwrite>):Enum_CMD;virtual;abstract;
  end;

  TNoCmd=class(TInterfacedObject, Idata_CMD)
  public
    function run_command(regs:TList<Iwrite>):Enum_CMD;
  end;

{ TSZHQCmd }

  TSZHQCmd = class(TCmd)
  private

  protected

  public
    destructor Destroy; override;
    function run_command(regs:TList<Iwrite>):Enum_CMD;

  end;
{ TSZZSCmd }

  TSZZSCmd = class(TCmd)
  private

  protected

  public
    destructor Destroy; override;
    function run_command(regs:TList<Iwrite>):Enum_CMD;

  end;
{ TSZXXCmd }

  TSZXXCmd = class(TCmd)
  private

  protected

  public
    destructor Destroy; override;
    function run_command(regs:TList<Iwrite>):Enum_CMD;

  end;
{ TShowCmd }

  TShowCmd = class(TCmd)
  private

  protected

  public
    destructor Destroy; override;
    function run_command(regs:TList<Iwrite>):Enum_CMD;
  end;

implementation


{ TNoCmd }

function TNoCmd.run_command(regs: TList<Iwrite>): Enum_CMD;
begin
  Result:=SZNoData;
end;

{ TSZHQCmd }


destructor TSZHQCmd.Destroy;
begin
  inherited;
end;

function TSZHQCmd.run_command(regs: TList<Iwrite>): Enum_CMD;
var
  reg,reg1:Iwrite;
  id:string;
  I: Integer;
  haskey:Boolean;
begin
  id := data[0];
  Result := SZNoData;
  for reg in regs do
  begin
    if (reg.w_type = SJSXXN) then
    begin
      MonitorEnter(reg.map);
      try
        haskey := reg.map.ContainsKey(id);
        if haskey then
          data[1] := (reg.map[id])[1];
      finally
        MonitorExit(reg.map);
      end;
      if haskey then
        for reg1 in regs do
          if (reg1.w_type = SJSHQ) then
          begin
            MonitorExit(reg1.map);
            try
              if (reg1.map.ContainsKey(id)) then
              begin
                for I := 0 to data.Size - 1 do
                  (reg.map[id])[i] := data[i];
                Result := SZup;
              end
              else
              begin
                reg1.map.AddOrSetValue(id, data);
                Result := SZup;
              end;
            finally
              MonitorExit(reg1.map);

            end;

          end;
    end;
  end;
end;


{ TSZZSCmd }


destructor TSZZSCmd.Destroy;
begin

  inherited;
end;

function TSZZSCmd.run_command(regs: TList<Iwrite>): Enum_CMD;
var
  reg, reg1: Iwrite;
  id: string;
  I: Integer;
begin
  id := data[0];
  Result := SZNoData;
  for reg1 in regs do
    if (reg1.w_type = SJSZS) then
    begin
      MonitorEnter(reg1.map);
      try
        if (reg1.map.ContainsKey(id)) then
        begin
          data[1]:= (reg.map[id])[1];
          for I := 0 to data.Size - 1 do
            (reg.map[id])[i] := data[i];
          Result := SZup;
        end;

      finally
        MonitorExit(reg1.map);
      end;
    end;

end;


{ TSZXXCmd }


destructor TSZXXCmd.Destroy;
begin

  inherited;
end;

function TSZXXCmd.run_command(regs: TList<Iwrite>): Enum_CMD;
var
  reg: Iwrite;
  id: string;
  I: Integer;
begin
  id := data[0];
  Result := SZNoData;
  for reg in regs do
  begin
    if (reg.w_type = SJSXXN) then
    begin
      MonitorEnter(reg.map);
      try
        if (reg.map.ContainsKey(id)) then
        begin
          for I := 0 to data.Size - 1 do
            (reg.map[id])[i] := data[i];
        end
        else
        begin
          reg.map.AddOrSetValue(id, data);
        end;
        Result := SZup;

      finally
        MonitorExit(reg.map);
      end;
    end;
  end;

end;


{ TShowCmd }


destructor TShowCmd.Destroy;
begin

  inherited;
end;

function TShowCmd.run_command(regs: TList<Iwrite>): Enum_CMD;
begin

end;

{ TCmd }

constructor TCmd.Create(da: TArrayEx<Variant>);
begin
  inherited Create;
  data:=da;
end;

destructor TCmd.Destroy;
begin

  inherited;
end;

end.
