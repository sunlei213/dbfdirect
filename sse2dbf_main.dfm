object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 478
  ClientWidth = 717
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 40
    Top = 27
    Width = 57
    Height = 13
    Caption = 'Fast'#30446#24405#65306
  end
  object Label2: TLabel
    Left = 40
    Top = 56
    Width = 49
    Height = 13
    Caption = 'fjy'#30446#24405#65306
  end
  object Label3: TLabel
    Left = 40
    Top = 83
    Width = 40
    Height = 13
    Caption = 'dbf'#30446#24405
  end
  object fastdir: TEdit
    Left = 112
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'fastdir'
  end
  object fjydir: TEdit
    Left = 112
    Top = 53
    Width = 121
    Height = 21
    TabOrder = 1
    Text = 'Edit1'
  end
  object dbfdir: TEdit
    Left = 112
    Top = 80
    Width = 121
    Height = 21
    TabOrder = 2
    Text = 'Edit1'
  end
  object tran_start: TButton
    Left = 40
    Top = 368
    Width = 75
    Height = 25
    Caption = #36716#25442#24320#22987
    TabOrder = 3
    OnClick = tran_startClick
  end
  object tran_stop: TButton
    Left = 158
    Top = 368
    Width = 75
    Height = 25
    Caption = #36716#25442#20572#27490
    TabOrder = 4
    OnClick = tran_stopClick
  end
  object btn1: TBitBtn
    Left = 232
    Top = 22
    Width = 25
    Height = 25
    Caption = '...'
    TabOrder = 5
    OnClick = btn1Click
  end
  object btn2: TBitBtn
    Left = 232
    Top = 53
    Width = 25
    Height = 25
    Caption = '...'
    TabOrder = 6
    OnClick = btn2Click
  end
  object btn3: TBitBtn
    Left = 232
    Top = 80
    Width = 25
    Height = 25
    Caption = '...'
    TabOrder = 7
    OnClick = btn3Click
  end
  object mmo1: TMemo
    Left = 176
    Top = 136
    Width = 305
    Height = 185
    Lines.Strings = (
      'mmo1')
    TabOrder = 8
  end
  object dlgOpen1: TOpenDialog
    Left = 32
    Top = 304
  end
end
