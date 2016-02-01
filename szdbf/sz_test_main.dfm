object MYform: TMYform
  Left = 0
  Top = 0
  Caption = 'MYform'
  ClientHeight = 282
  ClientWidth = 690
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
  object btn1: TButton
    Left = 80
    Top = 249
    Width = 75
    Height = 25
    Caption = 'btn1'
    TabOrder = 0
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 192
    Top = 249
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
  object idtcpclnt1: TIdTCPClient
    ConnectTimeout = 0
    IPVersion = Id_IPv4
    Port = 0
    ReadTimeout = -1
    Left = 376
    Top = 240
  end
end
