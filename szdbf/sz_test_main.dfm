object MYform: TMYform
  Left = 0
  Top = 0
  Caption = 'MYform'
  ClientHeight = 361
  ClientWidth = 690
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 72
    Top = 248
    Width = 60
    Height = 13
    Caption = #32593#20851#22320#22336#65306
  end
  object lbl2: TLabel
    Left = 304
    Top = 248
    Width = 60
    Height = 13
    Caption = #32593#20851#31471#21475#65306
  end
  object btn1: TButton
    Left = 72
    Top = 313
    Width = 75
    Height = 25
    Caption = 'btn1'
    TabOrder = 0
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 184
    Top = 313
    Width = 75
    Height = 25
    Caption = 'btn1'
    TabOrder = 1
    OnClick = btn2Click
  end
  object mmo1: TMemo
    Left = 24
    Top = 16
    Width = 658
    Height = 193
    Lines.Strings = (
      'mmo1')
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object edt1: TEdit
    Left = 128
    Top = 245
    Width = 153
    Height = 21
    TabOrder = 3
    Text = '127.0.0.1'
  end
  object edt2: TEdit
    Left = 360
    Top = 245
    Width = 121
    Height = 21
    TabOrder = 4
    Text = '8016'
  end
  object idtcpclnt1: TIdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
  end
end
