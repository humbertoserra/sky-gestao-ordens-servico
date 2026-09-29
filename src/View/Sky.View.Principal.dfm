object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'SKY - Gest'#227'o de Ordens de Servi'#231'o'
  ClientHeight = 641
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object pnlContainer: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 641
    Align = alClient
    BevelOuter = bvNone
    Padding.Left = 10
    Padding.Top = 10
    Padding.Right = 10
    Padding.Bottom = 10
    TabOrder = 0
    object groupListaOS: TGroupBox
      Left = 10
      Top = 50
      Width = 435
      Height = 539
      Margins.Top = 16
      Caption = '  Lista de OS  '
      DefaultHeaderFont = False
      HeaderFont.Charset = DEFAULT_CHARSET
      HeaderFont.Color = clWindowText
      HeaderFont.Height = -13
      HeaderFont.Name = 'Segoe UI'
      HeaderFont.Style = [fsBold]
      Padding.Left = 8
      Padding.Top = 8
      Padding.Right = 8
      Padding.Bottom = 8
      TabOrder = 1
      object groupFIltros: TGroupBox
        Left = 10
        Top = 25
        Width = 415
        Height = 169
        Align = alTop
        Caption = '  Filtros de Pesquisa  '
        TabOrder = 0
        object lblPesquisaCliente: TLabel
          Left = 16
          Top = 24
          Width = 194
          Height = 15
          Caption = 'Cliente: [Nome ou parte do nome ...]'
        end
        object lblPesquisaStatus: TLabel
          Left = 244
          Top = 74
          Width = 32
          Height = 15
          Caption = 'Status'
        end
        object lblAte: TLabel
          Left = 102
          Top = 99
          Width = 16
          Height = 15
          Caption = 'at'#233
          Enabled = False
        end
        object editPesquisa: TEdit
          Left = 16
          Top = 45
          Width = 387
          Height = 23
          TabOrder = 0
        end
        object dtpDataInicial: TDateTimePicker
          Left = 16
          Top = 95
          Width = 80
          Height = 23
          Date = 46291.000000000000000000
          Time = 0.679869502317160400
          Enabled = False
          TabOrder = 2
        end
        object dtpDataFinal: TDateTimePicker
          Left = 126
          Top = 95
          Width = 80
          Height = 23
          Date = 46291.000000000000000000
          Time = 0.679869502317160400
          Enabled = False
          TabOrder = 3
        end
        object cbxFiltroStatus: TComboBox
          Left = 244
          Top = 95
          Width = 159
          Height = 23
          Style = csDropDownList
          TabOrder = 4
        end
        object btnFiltrar: TButton
          Left = 274
          Top = 131
          Width = 60
          Height = 25
          Caption = '&Filtrar'
          TabOrder = 5
          OnClick = btnFiltrarClick
        end
        object btnLimpar: TButton
          Left = 343
          Top = 131
          Width = 60
          Height = 25
          Caption = '&Limpar'
          TabOrder = 6
          OnClick = btnLimparClick
        end
        object checkFiltroAbertura: TCheckBox
          Left = 16
          Top = 74
          Width = 129
          Height = 17
          Caption = 'Filtrar &por abertura'
          TabOrder = 1
          OnClick = checkFiltroAberturaClick
        end
      end
      object groupListagem: TGroupBox
        Left = 10
        Top = 202
        Width = 415
        Height = 327
        Align = alBottom
        Anchors = [akLeft, akTop, akRight, akBottom]
        Padding.Left = 10
        Padding.Right = 10
        Padding.Bottom = 10
        TabOrder = 1
        object gridOS: TDBGrid
          Left = 12
          Top = 17
          Width = 391
          Height = 298
          Align = alClient
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
          Columns = <
            item
              Expanded = False
              Visible = True
            end>
        end
      end
    end
    object groupOS: TGroupBox
      Left = 454
      Top = 50
      Width = 436
      Height = 539
      Caption = '  Ordem de Servi'#231'o  '
      DefaultHeaderFont = False
      HeaderFont.Charset = DEFAULT_CHARSET
      HeaderFont.Color = clWindowText
      HeaderFont.Height = -13
      HeaderFont.Name = 'Segoe UI'
      HeaderFont.Style = [fsBold]
      Padding.Left = 8
      Padding.Right = 8
      Padding.Bottom = 8
      TabOrder = 2
      object lblOS: TLabel
        Left = 323
        Top = 26
        Width = 35
        Height = 15
        Caption = 'OS N'#186' '
      end
      object lblNumeroOS: TLabel
        Left = 371
        Top = 25
        Width = 42
        Height = 17
        Alignment = taRightJustify
        Caption = '000000'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblStatus: TLabel
        Left = 248
        Top = 25
        Width = 38
        Height = 17
        Alignment = taRightJustify
        Caption = 'Status'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object groupClientes: TGroupBox
        Left = 11
        Top = 50
        Width = 414
        Height = 66
        Padding.Left = 8
        Padding.Right = 8
        TabOrder = 1
        object lblClienteTitulo: TLabel
          Left = 12
          Top = 10
          Width = 37
          Height = 15
          Caption = 'Cliente'
        end
        object comboCliente: TComboBox
          Left = 12
          Top = 31
          Width = 299
          Height = 23
          TabOrder = 0
        end
        object btnNovoCliente: TBitBtn
          Left = 322
          Top = 31
          Width = 80
          Height = 25
          Caption = 'Clien&te...'
          TabOrder = 1
          OnClick = btnNovoClienteClick
        end
      end
      object groupDatas: TGroupBox
        Left = 11
        Top = 123
        Width = 414
        Height = 70
        Padding.Left = 8
        Padding.Right = 8
        TabOrder = 2
        object lblDataAbertura: TLabel
          Left = 12
          Top = 10
          Width = 73
          Height = 15
          Caption = 'Data Abertura'
        end
        object lblDataPrevista: TLabel
          Left = 112
          Top = 10
          Width = 68
          Height = 15
          Caption = 'Data Prevista'
        end
        object dtpAbertura: TDateTimePicker
          Left = 12
          Top = 31
          Width = 90
          Height = 23
          Date = 46291.000000000000000000
          Time = 0.679869502317160400
          TabOrder = 0
        end
        object dtpPrevista: TDateTimePicker
          Left = 112
          Top = 31
          Width = 90
          Height = 23
          Date = 46291.000000000000000000
          Time = 0.679869502317160400
          TabOrder = 1
        end
      end
      object groupItemOrdem: TGroupBox
        Left = 12
        Top = 308
        Width = 414
        Height = 172
        Caption = '  Itens da Ordem  '
        DefaultHeaderFont = False
        HeaderFont.Charset = DEFAULT_CHARSET
        HeaderFont.Color = clWindowText
        HeaderFont.Height = -12
        HeaderFont.Name = 'Segoe UI'
        HeaderFont.Style = [fsBold]
        Padding.Left = 14
        Padding.Top = 8
        Padding.Right = 14
        Padding.Bottom = 14
        TabOrder = 4
        object lblTotalTitle: TLabel
          Left = 11
          Top = 140
          Width = 34
          Height = 15
          Caption = 'TOTAL'
        end
        object lblTotal: TLabel
          Left = 54
          Top = 139
          Width = 44
          Height = 17
          Caption = 'R$ 0,00'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object gridItemOrdem: TDBGrid
          Left = 11
          Top = 23
          Width = 390
          Height = 100
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
        object btnNovoItem: TButton
          Left = 240
          Top = 135
          Width = 75
          Height = 25
          Caption = 'Novo &Item'
          TabOrder = 1
          OnClick = btnNovoItemClick
        end
        object btnExcluiItem: TButton
          Left = 326
          Top = 135
          Width = 75
          Height = 25
          Caption = '&Exclui Item'
          TabOrder = 2
          OnClick = btnExcluiItemClick
        end
      end
      object btnNovaOS: TButton
        Left = 22
        Top = 504
        Width = 75
        Height = 25
        Caption = '&Nova OS'
        TabOrder = 0
        OnClick = btnNovaOSClick
      end
      object btnSalvarOS: TButton
        Left = 252
        Top = 504
        Width = 75
        Height = 25
        Caption = 'Sal&var OS'
        TabOrder = 5
        OnClick = btnSalvarOSClick
      end
      object btnDescartarOS: TButton
        Left = 338
        Top = 504
        Width = 75
        Height = 25
        Caption = '&Descartar'
        TabOrder = 6
        OnClick = btnDescartarOSClick
      end
      object groupProblema: TGroupBox
        Left = 11
        Top = 192
        Width = 414
        Height = 110
        Caption = '  Problema Relatado  '
        DefaultHeaderFont = False
        HeaderFont.Charset = DEFAULT_CHARSET
        HeaderFont.Color = clWindowText
        HeaderFont.Height = -12
        HeaderFont.Name = 'Segoe UI'
        HeaderFont.Style = [fsBold]
        Padding.Left = 10
        Padding.Top = 6
        Padding.Right = 10
        Padding.Bottom = 10
        TabOrder = 3
        object editProblema: TMemo
          Left = 12
          Top = 23
          Width = 390
          Height = 75
          Align = alClient
          TabOrder = 0
        end
      end
    end
    object groupIndicadores: TGroupBox
      Left = 10
      Top = 10
      Width = 880
      Height = 40
      Margins.Bottom = 16
      Align = alTop
      DefaultHeaderFont = False
      HeaderFont.Charset = DEFAULT_CHARSET
      HeaderFont.Color = clWindowText
      HeaderFont.Height = -12
      HeaderFont.Name = 'Segoe UI'
      HeaderFont.Style = [fsBold]
      TabOrder = 0
      object lblAbertas: TLabel
        Left = 16
        Top = 13
        Width = 40
        Height = 15
        Caption = 'Abertas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblAbertasControle: TLabel
        Left = 72
        Top = 13
        Width = 7
        Height = 15
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblAndamento: TLabel
        Left = 144
        Top = 13
        Width = 83
        Height = 15
        Caption = 'Em Andamento'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblAndamentoControle: TLabel
        Left = 241
        Top = 13
        Width = 7
        Height = 15
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblConcluidas: TLabel
        Left = 313
        Top = 13
        Width = 59
        Height = 15
        Caption = 'Conclu'#237'das'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblConcluidasControle: TLabel
        Left = 388
        Top = 13
        Width = 7
        Height = 15
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblAtrasadas: TLabel
        Left = 460
        Top = 13
        Width = 51
        Height = 15
        Caption = 'Atrasadas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblAtrasadasControle: TLabel
        Left = 530
        Top = 13
        Width = 7
        Height = 15
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object GroupBox1: TGroupBox
      Left = 10
      Top = 600
      Width = 880
      Height = 31
      Align = alBottom
      TabOrder = 3
      object Label7: TLabel
        Left = 753
        Top = 9
        Width = 19
        Height = 13
        Alignment = taRightJustify
        Caption = 'Esc:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label8: TLabel
        Left = 779
        Top = 9
        Width = 78
        Height = 13
        Alignment = taRightJustify
        Caption = 'campo anterior'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object Label9: TLabel
        Left = 615
        Top = 10
        Width = 30
        Height = 13
        Alignment = taRightJustify
        Caption = 'Enter:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label10: TLabel
        Left = 652
        Top = 10
        Width = 79
        Height = 13
        Alignment = taRightJustify
        Caption = 'pr'#243'ximo campo'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
    end
  end
  object MainMenu: TMainMenu
    Left = 648
    Top = 16
    object menuCadastro: TMenuItem
      Caption = '&Cadastro'
      object menuClientes: TMenuItem
        Caption = 'C&lientes'
        OnClick = menuClientesClick
      end
    end
    object Relatrios1: TMenuItem
      Caption = '&Relat'#243'rios'
    end
    object menuSair: TMenuItem
      Caption = '&Sair'
      OnClick = menuSairClick
    end
  end
end
