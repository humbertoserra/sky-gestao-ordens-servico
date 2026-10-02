object FrmClientes: TFrmClientes
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = '  Cadastro de Clientes'
  ClientHeight = 492
  ClientWidth = 845
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object pnlContainer: TPanel
    Left = 0
    Top = 0
    Width = 845
    Height = 492
    Align = alClient
    BevelOuter = bvNone
    Padding.Left = 10
    Padding.Top = 10
    Padding.Right = 10
    Padding.Bottom = 10
    TabOrder = 0
    object groupListaClientes: TGroupBox
      Left = 10
      Top = 10
      Width = 419
      Height = 432
      Margins.Top = 16
      Caption = '  Lista de Clientes  '
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
      TabOrder = 0
      object groupFIltros: TGroupBox
        Left = 10
        Top = 25
        Width = 399
        Height = 135
        Align = alTop
        Caption = '  Filtros de Pesquisa  '
        TabOrder = 0
        object lblPesquisa: TLabel
          Left = 12
          Top = 22
          Width = 74
          Height = 15
          Caption = 'Pesquisar por:'
        end
        object lblTermo: TLabel
          Left = 124
          Top = 22
          Width = 76
          Height = 15
          Caption = 'Digite o termo'
        end
        object lblPesquisaStatus: TLabel
          Left = 12
          Top = 74
          Width = 45
          Height = 15
          Caption = 'Situa'#231#227'o'
        end
        object btnLimpar: TButton
          Left = 327
          Top = 94
          Width = 60
          Height = 25
          Caption = '&Limpar'
          TabOrder = 4
          OnClick = btnLimparClick
        end
        object btnFiltrar: TButton
          Left = 258
          Top = 94
          Width = 60
          Height = 25
          Caption = '&Filtrar'
          TabOrder = 3
          OnClick = btnFiltrarClick
        end
        object cbxFiltroPesquisa: TComboBox
          Left = 12
          Top = 43
          Width = 97
          Height = 23
          Style = csDropDownList
          TabOrder = 0
          OnChange = cbxFiltroPesquisaChange
        end
        object editTermo: TEdit
          Left = 124
          Top = 43
          Width = 263
          Height = 23
          TabOrder = 1
          OnExit = editTermoExit
          OnKeyPress = editTermoKeyPress
        end
        object cbxFiltroSituacao: TComboBox
          Left = 12
          Top = 95
          Width = 97
          Height = 23
          Style = csDropDownList
          TabOrder = 2
        end
      end
      object groupListagem: TGroupBox
        Left = 10
        Top = 170
        Width = 399
        Height = 252
        Align = alBottom
        Anchors = [akLeft, akTop, akRight, akBottom]
        Padding.Left = 10
        Padding.Right = 10
        Padding.Bottom = 10
        TabOrder = 1
        object gridClientes: TDBGrid
          Left = 12
          Top = 17
          Width = 375
          Height = 223
          Align = alClient
          TabOrder = 0
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
    object groupCadastro: TGroupBox
      Left = 438
      Top = 10
      Width = 396
      Height = 294
      Caption = '  Cadastro  '
      DefaultHeaderFont = False
      HeaderFont.Charset = DEFAULT_CHARSET
      HeaderFont.Color = clWindowText
      HeaderFont.Height = -13
      HeaderFont.Name = 'Segoe UI'
      HeaderFont.Style = [fsBold]
      Padding.Left = 8
      Padding.Right = 8
      Padding.Bottom = 8
      TabOrder = 1
      object lblNumeroOS: TLabel
        Left = 324
        Top = 25
        Width = 49
        Height = 17
        Alignment = taRightJustify
        Caption = '0000000'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblOS: TLabel
        Left = 311
        Top = 27
        Width = 7
        Height = 15
        Caption = '#'
      end
      object groupClientes: TGroupBox
        Left = 9
        Top = 50
        Width = 376
        Height = 193
        Padding.Left = 14
        Padding.Right = 14
        TabOrder = 1
        object lblClienteTitulo: TLabel
          Left = 12
          Top = 10
          Width = 33
          Height = 15
          Caption = 'Nome'
        end
        object Label1: TLabel
          Left = 12
          Top = 106
          Width = 29
          Height = 15
          Caption = 'Email'
        end
        object Label2: TLabel
          Left = 12
          Top = 58
          Width = 63
          Height = 15
          Caption = 'Documento'
        end
        object Label3: TLabel
          Left = 193
          Top = 58
          Width = 45
          Height = 15
          Caption = 'Telefone'
        end
        object editNome: TEdit
          Left = 12
          Top = 29
          Width = 352
          Height = 23
          CharCase = ecUpperCase
          TabOrder = 0
        end
        object editEmail: TEdit
          Left = 12
          Top = 125
          Width = 352
          Height = 23
          CharCase = ecLowerCase
          TabOrder = 3
        end
        object EditDocumento: TEdit
          Left = 12
          Top = 77
          Width = 171
          Height = 23
          TabOrder = 1
        end
        object editTelefone: TEdit
          Left = 193
          Top = 77
          Width = 171
          Height = 23
          TabOrder = 2
          OnExit = editTelefoneExit
          OnKeyPress = editTelefoneKeyPress
        end
        object checkAtivo: TCheckBox
          Left = 290
          Top = 162
          Width = 69
          Height = 17
          Caption = '&Ativo'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 4
        end
      end
      object btnNovo: TButton
        Left = 199
        Top = 258
        Width = 80
        Height = 25
        Caption = '&Novo'
        TabOrder = 0
        OnClick = btnNovoClick
      end
      object btnSalvar: TButton
        Left = 285
        Top = 258
        Width = 80
        Height = 25
        Caption = '&Salvar'
        TabOrder = 2
        OnClick = btnSalvarClick
      end
      object btnFechar: TButton
        Left = 21
        Top = 258
        Width = 80
        Height = 25
        Caption = 'F&echar'
        ModalResult = 2
        TabOrder = 3
      end
    end
    object GroupBox1: TGroupBox
      Left = 10
      Top = 451
      Width = 825
      Height = 31
      Align = alBottom
      TabOrder = 2
      object Label5: TLabel
        Left = 769
        Top = 9
        Width = 32
        Height = 13
        Alignment = taRightJustify
        Caption = 'fechar'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object Label6: TLabel
        Left = 730
        Top = 9
        Width = 32
        Height = 13
        Alignment = taRightJustify
        Caption = 'Alt+E:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label7: TLabel
        Left = 604
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
        Left = 630
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
        Left = 466
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
        Left = 503
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
end
