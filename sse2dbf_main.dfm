object Form2: TForm2
  Left = 0
  Top = 0
  Caption = #34892#24773#25968#25454#33853#22320
  ClientHeight = 478
  ClientWidth = 466
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
  object Label1: TLabel
    Left = 72
    Top = 27
    Width = 57
    Height = 13
    Caption = 'Fast'#30446#24405#65306
  end
  object Label2: TLabel
    Left = 72
    Top = 56
    Width = 49
    Height = 13
    Caption = 'fjy'#30446#24405#65306
  end
  object Label3: TLabel
    Left = 72
    Top = 83
    Width = 40
    Height = 13
    Caption = 'dbf'#30446#24405
  end
  object lbl1: TLabel
    Left = 72
    Top = 139
    Width = 3
    Height = 13
  end
  object lbl2: TLabel
    Left = 144
    Top = 27
    Width = 16
    Height = 13
    Caption = 'lbl2'
  end
  object lbl3: TLabel
    Left = 143
    Top = 56
    Width = 16
    Height = 13
    Caption = 'lbl2'
  end
  object lbl4: TLabel
    Left = 143
    Top = 83
    Width = 16
    Height = 13
    Caption = 'lbl2'
  end
  object freq_1: TLabel
    Left = 72
    Top = 115
    Width = 65
    Height = 13
    Caption = #21047#26032#39057#29575'(s):'
  end
  object lbl5: TLabel
    Left = 143
    Top = 115
    Width = 16
    Height = 13
    Caption = 'lbl2'
  end
  object tran_start: TButton
    Left = 96
    Top = 416
    Width = 75
    Height = 25
    Caption = #36716#25442#24320#22987
    TabOrder = 0
    OnClick = tran_startClick
  end
  object tran_stop: TButton
    Left = 278
    Top = 416
    Width = 75
    Height = 25
    Caption = #36716#25442#20572#27490
    TabOrder = 1
    OnClick = tran_stopClick
  end
  object mmo1: TMemo
    Left = 32
    Top = 232
    Width = 393
    Height = 161
    Lines.Strings = (
      'mmo1')
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object set_btn1: TButton
    Left = 192
    Top = 184
    Width = 75
    Height = 25
    Caption = #35774#32622#21442#25968
    TabOrder = 3
    OnClick = set_btn1Click
  end
  object tmr1: TTimer
    Enabled = False
    Interval = 30000
    OnTimer = tmr1Timer
    Left = 432
    Top = 416
  end
end
