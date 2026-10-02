object FrmImpressaoOS: TFrmImpressaoOS
  Left = 0
  Top = 0
  Caption = 'FrmImpressaoOS'
  ClientHeight = 441
  ClientWidth = 795
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object rlRelatorio: TRLReport
    Left = 0
    Top = 0
    Width = 794
    Height = 1123
    DataSource = dsRelatorio
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ShowProgress = False
    Title = 'Ordens de Servi'#231'o'
    object bandTitulo: TRLBand
      Left = 38
      Top = 38
      Width = 718
      Height = 50
      BandType = btTitle
      object lblTitulo: TRLLabel
        Left = 0
        Top = 8
        Width = 294
        Height = 22
        Caption = 'Relat'#243'rio de Ordens de Servi'#231'o'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -19
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object grupoStatus: TRLGroup
      Left = 38
      Top = 88
      Width = 718
      Height = 110
      DataFields = 'STATUS'
      object bandStatus: TRLBand
        Left = 0
        Top = 0
        Width = 718
        Height = 28
        BandType = btHeader
        object lblStatusTitulo: TRLLabel
          Left = 0
          Top = 6
          Width = 42
          Height = 16
          Caption = 'Status'
        end
        object txtStatus: TRLDBText
          Left = 60
          Top = 6
          Width = 56
          Height = 16
          DataField = 'STATUS'
          DataSource = dsRelatorio
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          ParentFont = False
          Text = ''
        end
      end
      object bandColunas: TRLBand
        Left = 0
        Top = 28
        Width = 718
        Height = 24
        BandType = btColumnHeader
        object lblColOS: TRLLabel
          Left = 0
          Top = 4
          Width = 23
          Height = 16
          Caption = 'OS'
        end
        object lblColCliente: TRLLabel
          Left = 60
          Top = 4
          Width = 44
          Height = 16
          Caption = 'Cliente'
        end
        object lblColAbertura: TRLLabel
          Left = 350
          Top = 4
          Width = 53
          Height = 16
          Caption = 'Abertura'
        end
        object lblColPrevisao: TRLLabel
          Left = 450
          Top = 4
          Width = 53
          Height = 16
          Caption = 'Previs'#227'o'
        end
        object lblColValor: TRLLabel
          Left = 560
          Top = 4
          Width = 66
          Height = 16
          Caption = 'Valor Total'
        end
      end
      object bandDetalhe: TRLBand
        Left = 0
        Top = 52
        Width = 718
        Height = 22
        object txtOS: TRLDBText
          Left = 0
          Top = 2
          Width = 55
          Height = 16
          DataField = 'ID'
          DataSource = dsRelatorio
          Text = ''
        end
        object txtCliente: TRLDBText
          Left = 60
          Top = 2
          Width = 280
          Height = 16
          DataField = 'CLIENTE_NOME'
          DataSource = dsRelatorio
          Text = ''
        end
        object txtAbertura: TRLDBText
          Left = 350
          Top = 2
          Width = 95
          Height = 16
          DataField = 'DATA_ABERTURA'
          DataSource = dsRelatorio
          Text = ''
        end
        object txtPrevisao: TRLDBText
          Left = 450
          Top = 2
          Width = 95
          Height = 16
          DataField = 'DATA_PREVISTA'
          DataSource = dsRelatorio
          Text = ''
        end
        object txtValor: TRLDBText
          Left = 550
          Top = 2
          Width = 160
          Height = 16
          Alignment = taRightJustify
          DataField = 'VALOR_TOTAL'
          DataSource = dsRelatorio
          Text = ''
        end
      end
      object bandSubtotal: TRLBand
        Left = 0
        Top = 74
        Width = 718
        Height = 36
        BandType = btSummary
        Borders.Sides = sdCustom
        Borders.DrawLeft = False
        Borders.DrawTop = False
        Borders.DrawRight = False
        Borders.DrawBottom = True
        Borders.Color = clSilver
        object lblQuantidadeStatus: TRLLabel
          Left = 0
          Top = 6
          Width = 145
          Height = 16
          AutoSize = False
          Caption = 'Quantidade de OS:'
        end
        object resQuantidadeStatus: TRLDBResult
          Left = 150
          Top = 6
          Width = 46
          Height = 16
          DataField = 'ID'
          DataSource = dsRelatorio
          DisplayMask = '0'
          Info = riCount
          ResetAfterPrint = True
          Text = ''
        end
        object lblSubtotalStatus: TRLLabel
          Left = 430
          Top = 6
          Width = 76
          Height = 16
          Caption = 'Subtotal R$:'
        end
        object resSubtotalStatus: TRLDBResult
          Left = 550
          Top = 6
          Width = 160
          Height = 16
          Alignment = taRightJustify
          AutoSize = False
          DataField = 'VALOR_TOTAL'
          DataSource = dsRelatorio
          DisplayMask = '#,##0.00'
          Info = riSum
          ResetAfterPrint = True
          Text = ''
        end
      end
    end
    object bandTotalGeral: TRLBand
      Left = 38
      Top = 198
      Width = 718
      Height = 36
      BandType = btSummary
      object lblQuantidadeGeral: TRLLabel
        Left = 0
        Top = 8
        Width = 77
        Height = 16
        Caption = 'Total de OS:'
      end
      object resQuantidadeGeral: TRLDBResult
        Left = 150
        Top = 8
        Width = 49
        Height = 16
        DataField = 'ID'
        DataSource = dsRelatorio
        DisplayMask = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        Info = riCount
        ParentFont = False
        ResetAfterPrint = True
        Text = ''
      end
      object lblTotalGeral: TRLLabel
        Left = 430
        Top = 8
        Width = 91
        Height = 16
        Caption = 'Total Geral R$:'
      end
      object resTotalGeral: TRLDBResult
        Left = 550
        Top = 8
        Width = 160
        Height = 16
        Alignment = taRightJustify
        AutoSize = False
        DataField = 'VALOR_TOTAL'
        DataSource = dsRelatorio
        DisplayMask = '#,##0.00'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        Info = riSum
        ParentFont = False
        ResetAfterPrint = True
        Text = ''
      end
    end
    object bandRodape: TRLBand
      Left = 38
      Top = 234
      Width = 718
      Height = 24
      BandType = btFooter
      object lblGeradoEm: TRLLabel
        Left = 0
        Top = 4
        Width = 72
        Height = 16
        Caption = 'Gerado em:'
      end
      object infoGeracao: TRLSystemInfo
        Left = 85
        Top = 4
        Width = 37
        Height = 16
        Info = itNow
        Text = ''
      end
      object lblPagina: TRLLabel
        Left = 590
        Top = 4
        Width = 48
        Height = 16
        Caption = 'P'#225'gina:'
      end
      object infoPagina: TRLSystemInfo
        Left = 650
        Top = 4
        Width = 87
        Height = 16
        Info = itPageNumber
        Text = ''
      end
    end
  end
  object dsRelatorio: TDataSource
    AutoEdit = False
    Left = 40
    Top = 384
  end
  object pdfRelatorio: TRLPDFFilter
    DocumentInfo.Creator = 
      'FortesReport Community Edition v4.0.1.2 \251 Copyright '#169' 1999-20' +
      '21 Fortes Inform'#225'tica'
    DisplayName = 'Documento PDF'
    Left = 112
    Top = 384
  end
end
