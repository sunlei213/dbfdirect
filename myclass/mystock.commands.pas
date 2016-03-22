unit mystock.commands;

interface
uses
  mystock.types,mystock.interfaces,system.Classes, Generics.Collections, ArrayEx, System.SysUtils, System.Variants,system.Math,mystock.singleinf.logger;
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
    function run_command(regs:TList<Iwrite>):Enum_CMD;override;

  end;
{ TSZZSCmd }

  TSZZSCmd = class(TCmd)
  private

  protected

  public
    destructor Destroy; override;
    function run_command(regs:TList<Iwrite>):Enum_CMD;override;

  end;
{ TSZXXCmd }

  TSZXXCmd = class(TCmd)
  private

  protected

  public
    destructor Destroy; override;
    function run_command(regs:TList<Iwrite>):Enum_CMD;override;

  end;
{ TShowCmd }

  TShowCmd = class(TCmd)
  private

  protected

  public
    destructor Destroy; override;
    function run_command(regs:TList<Iwrite>):Enum_CMD;override;
  end;

{ TfastwCmd }

  TfastCmd = class(TCmd)
  private

  protected

  public
    destructor Destroy; override;
    function run_command(regs:TList<Iwrite>):Enum_CMD;override;
  end;

  { TfjywCmd }

  TfjyCmd = class(TCmd)
  private

  protected

  public
    destructor Destroy; override;
    function run_command(regs:TList<Iwrite>):Enum_CMD;override;
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
  item:Variant;
  ui:Int64;
  f:Double;
  flogger:ILogger;
begin
  flogger:=GetLogInterface;
  id := data[0];
  Result := SZNoData;
  for reg in regs do
  begin
    if (reg.w_type = SJSXXN) then
    begin
      reg.MyLock.Enter;
      try
        haskey := reg.map.ContainsKey(id);
        if haskey then
          data[1] := (reg.map[id])[1];
      finally
        reg.MyLock.Leave;
      end;
      if haskey then
        for reg1 in regs do
          if (reg1.w_type = SJSHQ) then
          begin
            reg1.MyLock.Enter;
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
              reg1.MyLock.Leave;

            end;

          end;
    end;
  end;
  id:='行情:';
  for item in data do
  begin
    case VarType(item) of
    varString,varUString:id:=id+item+'|';
    varInt64,varUInt64:
                      begin
                        ui:=item;
                        id:=id+ui.ToString+'|';
                      end;
    varInteger,varWord,varByte:
                      begin
                        I:=item;
                        id:=id+I.ToString+'|';
                      end;
    varSingle,varDouble:
                      begin
                        f:=item;
                        id:=id+f.ToString+'|';
                      end;
    end;
  end;
  flogger.WriteLog(id,2);
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
  item:Variant;
  ui:Int64;
  f:Double;
  flogger:ILogger;
begin
  flogger:=GetLogInterface;
  id := data[0];
  Result := SZNoData;
  for reg1 in regs do
    if (reg1.w_type = SJSZS) then
    begin
      reg1.MyLock.Enter;
      try
        if (reg1.map.ContainsKey(id)) then
        begin
          data[1]:= (reg.map[id])[1];
          for I := 0 to data.Size - 1 do
            (reg.map[id])[i] := data[i];
          Result := SZup;
        end;

      finally
        reg1.MyLock.Leave;
      end;
    end;
  id:='指数:';
  for item in data do
  begin
    case VarType(item) of
    varString,varUString:id:=id+item+'|';
    varInt64,varUInt64:
                      begin
                        ui:=item;
                        id:=id+ui.ToString+'|';
                      end;
    varInteger,varWord,varByte:
                      begin
                        I:=item;
                        id:=id+I.ToString+'|';
                      end;
    varSingle,varDouble:
                      begin
                        f:=item;
                        id:=id+f.ToString+'|';
                      end;
    end;
  end;
  flogger.WriteLog(id,2);

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
  item:Variant;
  ui:Int64;
  f:Double;
  flogger:ILogger;
begin
  flogger:=GetLogInterface;
  id := data[0];
  Result := SZNoData;
  for reg in regs do
  begin
    if (reg.w_type = SJSXXN) then
    begin
      reg.MyLock.Enter;
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
        reg.MyLock.Leave;
      end;
    end;
  end;
  id:='信息:';
  for item in data do
  begin
    case VarType(item) of
    varString,varUString:id:=id+item+'|';
    varInt64,varUInt64:
                      begin
                        ui:=item;
                        id:=id+ui.ToString+'|';
                      end;
    varInteger,varWord,varByte:
                      begin
                        I:=item;
                        id:=id+I.ToString+'|';
                      end;
    varSingle,varDouble:
                      begin
                        f:=item;
                        id:=id+f.ToString+'|';
                      end;
    end;
  end;
  flogger.WriteLog(id,2);

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

{ TfastCmd }

destructor TfastCmd.Destroy;
begin

  inherited;
end;

function TfastCmd.run_command(regs: TList<Iwrite>): Enum_CMD;
begin

end;

{ TfjyCmd }

destructor TfjyCmd.Destroy;
begin

  inherited;
end;

function TfjyCmd.run_command(regs: TList<Iwrite>): Enum_CMD;
begin

end;

end.
