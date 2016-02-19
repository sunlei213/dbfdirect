unit singleton;

interface
uses
 Windows,Classes, SysUtils,StdCtrls,ComCtrls,ComObj,Messages,Vcl.Dialogs;
type
  TTestClass = class
  private
    class var FInstance: TTestClass;
    st:string;
    stl:TStringList;
    class constructor Create;
    class destructor Destroy;
    constructor Create;
  public
    class function GetInstance: TTestClass;
    procedure show;
    procedure setstr(str1:string);
  end;

{ TTestClass }

implementation

class constructor TTestClass.Create;
begin
  TTestClass.FInstance:=TTestClass.Create
end;

constructor TTestClass.Create;
begin
  inherited;
  st:='��ʼ�ɹ�';
  stl:=TStringList.Create;
  stl.Add(st);
  ShowMessage(stl[0]);
end;



class destructor TTestClass.Destroy;
begin
  ShowMessage('����ʵ��ɾ��');
    stl.Free;
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
 end;

class function TTestClass.GetInstance: TTestClass;
begin
  Result := FInstance;
end;


procedure TTestClass.setstr(str1: string);
begin
  st:=str1;
  stl[0]:=str1;
end;

procedure TTestClass.show;
begin
  ShowMessage(stl[0]);
end;

end.
