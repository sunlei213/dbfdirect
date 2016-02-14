unit sse2dbf_set;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls,System.IOUtils,Vcl.FileCtrl;

type
  Tsettaskentry = class(TForm)
    fastdir: TEdit;
    fjydir: TEdit;
    dbfdir: TEdit;
    freq_set: TEdit;
    btn_btn1: TButton;
    btn_btn2: TButton;
    btn1: TBitBtn;
    btn2: TBitBtn;
    btn3: TBitBtn;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btn_btn1Click(Sender: TObject);
    procedure btn_btn2Click(Sender: TObject);
  private
    { Private declarations }
  public
    fast,fjy,dbfd,frg:string;
 { Public declarations }
  end;


implementation

{$R *.dfm}

procedure Tsettaskentry.btn1Click(Sender: TObject);
var
  dir:string;
begin
  if SelectDirectory('选择fast目录','',dir) then fastdir.Text:=dir;
end;

procedure Tsettaskentry.btn2Click(Sender: TObject);
var
  dir:string;
begin
  if SelectDirectory('选择fjy目录','',dir) then fjydir.Text:=dir;
end;

procedure Tsettaskentry.btn3Click(Sender: TObject);
var
  dir:string;
begin
  if SelectDirectory('选择show2003目录','',dir) then dbfdir.Text:=dir;
end;

procedure Tsettaskentry.btn_btn1Click(Sender: TObject);
begin
   Self.fast:=fastdir.Text;
   fjy:=fjydir.Text;
   dbfd:=dbfdir.Text;
   frg:=freq_set.Text;
   ModalResult := mrOK;
end;

procedure Tsettaskentry.btn_btn2Click(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure Tsettaskentry.FormShow(Sender: TObject);
begin
   fastdir.Text:=Self.fast;
   fjydir.Text:=fjy;
   dbfdir.Text:=dbfd;
   freq_set.Text:=frg;
end;

end.
