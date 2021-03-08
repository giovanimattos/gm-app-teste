object fThreads: TfThreads
  Left = 0
  Top = 0
  Caption = 'Threads'
  ClientHeight = 414
  ClientWidth = 724
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object pnlActions: TPanel
    Left = 0
    Top = 0
    Width = 241
    Height = 414
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    object lblNumeroThreads: TLabel
      Left = 8
      Top = 19
      Width = 170
      Height = 13
      Caption = 'N'#250'mero de threads a serem criadas'
    end
    object lblIntervaloThreads: TLabel
      Left = 8
      Top = 75
      Width = 228
      Height = 13
      Caption = 'Intervalo m'#225'ximo entre threads (milissegundos)'
    end
    object bCriarThreads: TButton
      Left = 8
      Top = 139
      Width = 228
      Height = 25
      Caption = 'Criar Threads'
      TabOrder = 0
      OnClick = bCriarThreadsClick
    end
    object edNumeroThreads: TSpinEdit
      Left = 8
      Top = 38
      Width = 228
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 10
    end
    object edIntervaloMaximoThreads: TSpinEdit
      Left = 8
      Top = 94
      Width = 228
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 100
    end
  end
  object pnlLogger: TPanel
    Left = 241
    Top = 0
    Width = 483
    Height = 414
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 344
    ExplicitTop = 72
    ExplicitWidth = 297
    ExplicitHeight = 177
    object ProgressBar: TProgressBar
      Left = 0
      Top = 0
      Width = 483
      Height = 17
      Align = alTop
      TabOrder = 0
      ExplicitTop = 8
      ExplicitWidth = 185
    end
    object Memo: TMemo
      Left = 0
      Top = 17
      Width = 483
      Height = 397
      Align = alClient
      TabOrder = 1
      ExplicitLeft = 112
      ExplicitTop = 88
      ExplicitWidth = 185
      ExplicitHeight = 89
    end
  end
end
