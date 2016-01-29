unit sse2dbf_set;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.StdCtrls,System.IOUtils;

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
    dlgOpen1: TOpenDialog;
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
    isok:boolean;{ Public declarations }
  end;


implementation

{$R *.dfm}

procedure Tsettaskentry.btn1Click(Sender: TObject);
begin
  dlgOpen1.Title:='选择fast目录';
  if dlgOpen1.Execute then fastdir.Text:=TPath.GetDirectoryName(dlgOpen1.FileName);
end;

procedure Tsettaskentry.btn2Click(Sender: TObject);
begin
  dlgOpen1.Title:='选择fjy目录';
  if dlgOpen1.Execute then fjydir.Text:=TPath.GetDirectoryName(dlgOpen1.FileName);
end;

procedure Tsettaskentry.btn3Click(Sender: TObject);
begin
  dlgOpen1.Title:='选择show2003目录';
  if dlgOpen1.Execute then dbfdir.Text:=TPath.GetDirectoryName(dlgOpen1.FileName);
end;

procedure Tsettaskentry.btn_btn1Click(Sender: TObject);
begin
   isok:=True;
   Self.fast:=fastdir.Text;
   fjy:=fjydir.Text;
   dbfd:=dbfdir.Text;
   frg:=freq_set.Text;
   Self.Close;
end;

procedure Tsettaskentry.btn_btn2Click(Sender: TObject);
begin
   isok:=False;
   Self.Close;
end;

procedure Tsettaskentry.FormShow(Sender: TObject);
begin
   isok:=False;
   fastdir.Text:=Self.fast;
   fjydir.Text:=fjy;
   dbfdir.Text:=dbfd;
   freq_set.Text:=frg;
end;

end.
