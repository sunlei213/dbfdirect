object settaskentry: Tsettaskentry
  Left = 0
  Top = 0
  Caption = #35774#32622#20219#21153#21442#25968
  ClientHeight = 281
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 49
    Top = 27
    Width = 57
    Height = 13
    Caption = 'Fast'#30446#24405#65306
  end
  object lbl2: TLabel
    Left = 49
    Top = 67
    Width = 49
    Height = 13
    Caption = 'fjy'#30446#24405#65306
  end
  object lbl3: TLabel
    Left = 49
    Top = 107
    Width = 52
    Height = 13
    Caption = 'dbf'#30446#24405#65306
  end
  object lbl4: TLabel
    Left = 49
    Top = 147
    Width = 73
    Height = 13
    Caption = #21047#26032#38388#38548'(s)'#65306
  end
  object fastdir: TEdit
    Left = 128
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'fastdir'
  end
  object fjydir: TEdit
    Left = 128
    Top = 64
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'edt1'
  end
  object dbfdir: TEdit
    Left = 128
    Top = 104
    Width = 121
    Height = 21
    TabOrder = 2
    Text = 'edt1'
  end
  object freq_set: TEdit
    Left = 128
    Top = 144
    Width = 121
    Height = 21
    TabOrder = 3
    Text = 'edt1'
  end
  object btn_btn1: TButton
    Left = 104
    Top = 216
    Width = 75
    Height = 25
    Caption = #30830#35748
    TabOrder = 4
    OnClick = btn_btn1Click
  end
  object btn_btn2: TButton
    Left = 200
    Top = 216
    Width = 75
    Height = 25
    Caption = #21462#28040
    TabOrder = 5
    OnClick = btn_btn2Click
  end
  object btn1: TBitBtn
    Left = 248
    Top = 22
    Width = 27
    Height = 25
    Caption = 'btn1'
    TabOrder = 6
    OnClick = btn1Click
  end
  object btn2: TBitBtn
    Left = 248
    Top = 62
    Width = 27
    Height = 25
    Caption = 'btn1'
    TabOrder = 7
    OnClick = btn2Click
  end
  object btn3: TBitBtn
    Left = 248
    Top = 102
    Width = 27
    Height = 25
    Caption = 'btn1'
    TabOrder = 8
    OnClick = btn3Click
  end
  object dlgOpen1: TOpenDialog
    Left = 368
    Top = 232
  end
end
