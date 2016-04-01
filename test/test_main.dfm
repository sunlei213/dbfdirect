object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 550
  ClientWidth = 586
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 32
    Top = 24
    Width = 60
    Height = 13
    Caption = #32593#20851#22320#22336#65306
  end
  object lbl2: TLabel
    Left = 32
    Top = 59
    Width = 48
    Height = 13
    Caption = #31471#21475#21495#65306
  end
  object lbl3: TLabel
    Left = 32
    Top = 91
    Width = 48
    Height = 13
    Caption = #29992#25143#21517#65306
  end
  object lbl4: TLabel
    Left = 32
    Top = 128
    Width = 36
    Height = 13
    Caption = #23494#30721#65306
  end
  object btn1: TButton
    Left = 80
    Top = 192
    Width = 75
    Height = 25
    Caption = 'btn1'
    TabOrder = 0
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 232
    Top = 192
    Width = 75
    Height = 25
    Caption = 'btn2'
    TabOrder = 1
    OnClick = btn2Click
  end
  object edt1: TEdit
    Left = 98
    Top = 21
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '192.168.90.222'
  end
  object edt2: TEdit
    Left = 98
    Top = 56
    Width = 121
    Height = 21
    TabOrder = 3
    Text = '8017'
  end
  object edt3: TEdit
    Left = 98
    Top = 88
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'at002'
  end
  object edt4: TEdit
    Left = 98
    Top = 125
    Width = 121
    Height = 21
    TabOrder = 5
    Text = 'at002'
  end
  object strngrd1: TStringGrid
    Left = 272
    Top = 21
    Width = 217
    Height = 120
    ColCount = 3
    TabOrder = 6
  end
  object btn3: TButton
    Left = 384
    Top = 192
    Width = 75
    Height = 25
    Caption = 'btn3'
    Enabled = False
    TabOrder = 7
    OnClick = btn3Click
  end
  object mmo1: TMemo
    Left = 24
    Top = 240
    Width = 545
    Height = 297
    TabOrder = 8
  end
  object tmr1: TTimer
    Enabled = False
    OnTimer = tmr1Timer
    Left = 72
    Top = 240
  end
end
