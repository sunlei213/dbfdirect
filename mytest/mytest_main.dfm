object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 281
  ClientWidth = 418
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
  object edt1: TEdit
    Left = 80
    Top = 40
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '1'
  end
  object btn1: TButton
    Left = 64
    Top = 192
    Width = 75
    Height = 25
    Caption = 'btn1'
    TabOrder = 1
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 176
    Top = 192
    Width = 75
    Height = 25
    Caption = 'btn2'
    TabOrder = 2
    OnClick = btn2Click
  end
  object mmo1: TMemo
    Left = 64
    Top = 72
    Width = 313
    Height = 97
    Lines.Strings = (
      'mmo1')
    TabOrder = 3
  end
  object btn3: TButton
    Left = 288
    Top = 192
    Width = 75
    Height = 25
    Caption = 'btn3'
    TabOrder = 4
    OnClick = btn3Click
  end
end
