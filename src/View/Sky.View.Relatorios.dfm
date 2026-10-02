object FrmRelatoriosOS: TFrmRelatoriosOS
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '  Relat'#243'rio de Ordens de Servi'#231'o'
  ClientHeight = 240
  ClientWidth = 640
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object pnlContainer: TPanel
    Left = 0
    Top = 0
    Width = 640
    Height = 240
    Align = alClient
    BevelOuter = bvNone
    Padding.Left = 10
    Padding.Top = 10
    Padding.Right = 10
    Padding.Bottom = 10
    TabOrder = 0
    object pbRelatorio: TProgressBar
      Left = 10
      Top = 166
      Width = 620
      Height = 16
      TabOrder = 0
      Visible = False
    end
    object btnVisualizar: TButton
      Left = 286
      Top = 198
      Width = 100
      Height = 25
      Caption = '&Visualizar'
      TabOrder = 1
    end
    object btnExportarPDF: TButton
      Left = 398
      Top = 198
      Width = 100
      Height = 25
      Caption = '&Exportar PDF'
      TabOrder = 2
    end
    object btnFechar: TButton
      Left = 530
      Top = 198
      Width = 100
      Height = 25
      Caption = '&Fechar'
      TabOrder = 3
    end
    object groupFiltros: TGroupBox
      Left = 10
      Top = 10
      Width = 620
      Height = 143
      Align = alTop
      Caption = '  Filtros  '
      DefaultHeaderFont = False
      HeaderFont.Charset = DEFAULT_CHARSET
      HeaderFont.Color = clWindowText
      HeaderFont.Height = -13
      HeaderFont.Name = 'Segoe UI'
      HeaderFont.Style = [fsBold]
      TabOrder = 4
      object lblAte: TLabel
        Left = 103
        Top = 48
        Width = 16
        Height = 15
        Caption = 'at'#233
        Enabled = False
      end
      object lblCliente: TLabel
        Left = 17
        Top = 89
        Width = 194
        Height = 15
        Caption = 'Cliente: [Nome ou parte do nome ...]'
      end
      object lblStatus: TLabel
        Left = 309
        Top = 21
        Width = 178
        Height = 15
        Caption = 'Status: nunhum marcado = todos'
      end
      object checkPeriodo: TCheckBox
        Left = 17
        Top = 22
        Width = 129
        Height = 17
        Caption = 'Filtrar &por abertura'
        TabOrder = 0
      end
      object dtpInicial: TDateTimePicker
        Left = 17
        Top = 44
        Width = 80
        Height = 23
        Date = 46291.000000000000000000
        Time = 0.679869502317160400
        Enabled = False
        TabOrder = 1
      end
      object dtpFinal: TDateTimePicker
        Left = 127
        Top = 44
        Width = 80
        Height = 23
        Date = 46291.000000000000000000
        Time = 0.679869502317160400
        Enabled = False
        TabOrder = 2
      end
      object editCliente: TEdit
        Left = 17
        Top = 106
        Width = 280
        Height = 23
        CharCase = ecUpperCase
        TabOrder = 3
      end
      object clbStatus: TCheckListBox
        Left = 309
        Top = 44
        Width = 296
        Height = 85
        ItemHeight = 17
        Items.Strings = (
          'Aberta'
          'Em Andamento'
          'Conclu'#237'da'
          'Cancelada')
        TabOrder = 4
      end
    end
  end
end
