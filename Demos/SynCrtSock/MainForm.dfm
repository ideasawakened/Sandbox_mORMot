object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'SynCrtSock testing on Windows'
  ClientHeight = 596
  ClientWidth = 739
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 32
    Top = 16
    Width = 32
    Height = 13
    Caption = 'Server'
  end
  object Label2: TLabel
    Left = 32
    Top = 75
    Width = 36
    Height = 26
    Caption = 'Return Code'
    WordWrap = True
  end
  object Label3: TLabel
    Left = 32
    Top = 107
    Width = 40
    Height = 13
    Caption = 'Headers'
    WordWrap = True
  end
  object Label4: TLabel
    Left = 32
    Top = 246
    Width = 24
    Height = 13
    Caption = 'Body'
    WordWrap = True
  end
  object labElapsedTime: TLabel
    Left = 408
    Top = 81
    Width = 13
    Height = 13
    Caption = 'ms'
  end
  object butSimpleHTTP: TButton
    Left = 80
    Top = 44
    Width = 98
    Height = 25
    Caption = 'TSimpleHttpClient'
    TabOrder = 1
    OnClick = butSimpleHTTPClick
  end
  object memHeaders: TMemo
    Left = 80
    Top = 104
    Width = 629
    Height = 133
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 5
  end
  object edtReturnCode: TEdit
    Left = 80
    Top = 77
    Width = 313
    Height = 21
    TabOrder = 4
  end
  object memBody: TMemo
    Left = 80
    Top = 243
    Width = 629
    Height = 330
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 6
  end
  object butWinHTTP: TButton
    Left = 188
    Top = 44
    Width = 98
    Height = 25
    Caption = 'TWinHTTP'
    TabOrder = 2
    OnClick = butWinHTTPClick
  end
  object butLibcurl: TButton
    Left = 295
    Top = 44
    Width = 98
    Height = 25
    Caption = 'TCurlHTTP'
    TabOrder = 3
    OnClick = butLibcurlClick
  end
  object cboURI: TComboBox
    Left = 80
    Top = 12
    Width = 313
    Height = 21
    ItemIndex = 0
    TabOrder = 0
    Text = 'http://edn.embarcadero.com'
    Items.Strings = (
      'http://edn.embarcadero.com'
      'https://edn.embarcadero.com'
      'https://www.google.com'
      'https://www.ideasawakened.com/blog')
  end
end
