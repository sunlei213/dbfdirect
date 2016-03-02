unit mystock.singleinf.locker;

interface
uses
  System.Classes,mystock.interfaces,Generics.Collections;

  function GetLocker(ty:Integer):Ilocker;
implementation

uses
 SyncObjs;
const
 {$J+} lockinterface:TList<Ilocker>=nil; {$J-}
type
TLocker = class(TInterfacedObject,Ilocker)
private
  FCSLock: TCriticalSection;
public
 constructor Create;
 destructor Destroy; override;
    procedure Lock;
    procedure UnLock;
end;

{ TLocker }

constructor TLocker.Create;
begin
  inherited;
  FCSLock:=TCriticalSection.Create;
end;

destructor TLocker.Destroy;
begin
  FCSLock.Free;
  inherited;
end;

procedure TLocker.Lock;
begin
  FCSLock.Enter;
end;

procedure TLocker.UnLock;
begin
  FCSLock.Leave;
end;

function GetLocker(ty:Integer):Ilocker;
begin
  if(lockinterface.Count<3) then
  begin
   MonitorEnter(lockinterface);
   try
     if(lockinterface.Count<3) then
      lockinterface.Count:=3;
   finally
   MonitorExit(lockinterface);
   end;
  end;
  if Assigned(lockinterface[ty]) then
  begin
   MonitorEnter(lockinterface);
   try
     if Assigned(lockinterface[ty]) then
      lockinterface[ty]:=TLocker.Create;
   finally
   MonitorExit(lockinterface);
   end;
   Result:=lockinterface[ty];
  end;
end;
initialization
  lockinterface:=TList<Ilocker>.Create;
finalization
  lockinterface.Clear;
  lockinterface.Free;
end.
