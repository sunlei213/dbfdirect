unit mystock.commands;

interface
uses
  mystock.types,mystock.interfaces,Generics.Collections, ArrayEx, System.SysUtils, System.Variants, System.Classes,system.Math;
type
  TNoCmd=class(TInterfacedObject, Idata_CMD )
  public
    procedure run_command(regs:TList<Iwrite>);
  end;

{ TSZHQCmd }

  TSZHQCmd = class(TInterfacedObject, Idata_CMD)
  private

  protected

  public
    constructor Create;
    destructor Destroy; override;
    procedure run_command(regs:TList<Iwrite>);

  end;
{ TSZZSCmd }

  TSZZSCmd = class(TInterfacedObject, Idata_CMD)
  private

  protected

  public
    constructor Create;
    destructor Destroy; override;
    procedure run_command(regs:TList<Iwrite>);

  end;
{ TSZXXCmd }

  TSZXXCmd = class(TInterfacedObject, Idata_CMD)
  private

  protected

  public
    constructor Create;
    destructor Destroy; override;
    procedure run_command(regs:TList<Iwrite>);

  end;
{ TShowCmd }

  TShowCmd = class(TInterfacedObject, Idata_CMD)
  private

  protected

  public
    constructor Create;
    destructor Destroy; override;
    procedure run_command(regs:TList<Iwrite>);

  end;

implementation

{ TNoCmd }

procedure TNoCmd.run_command(regs:TList<Iwrite>);
begin

end;

{ TSZHQCmd }

constructor TSZHQCmd.Create;
begin

end;

destructor TSZHQCmd.Destroy;
begin

  inherited;
end;

procedure TSZHQCmd.run_command(regs: TList<Iwrite>);
begin

end;

{ TSZZSCmd }

constructor TSZZSCmd.Create;
begin

end;

destructor TSZZSCmd.Destroy;
begin

  inherited;
end;

procedure TSZZSCmd.run_command(regs: TList<Iwrite>);
begin

end;

{ TSZXXCmd }

constructor TSZXXCmd.Create;
begin

end;

destructor TSZXXCmd.Destroy;
begin

  inherited;
end;

procedure TSZXXCmd.run_command(regs: TList<Iwrite>);
begin

end;

{ TShowCmd }

constructor TShowCmd.Create;
begin

end;

destructor TShowCmd.Destroy;
begin

  inherited;
end;

procedure TShowCmd.run_command(regs: TList<Iwrite>);
begin

end;

end.
