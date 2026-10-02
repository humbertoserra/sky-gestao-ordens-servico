unit Sky.View.ImpressaoOS;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  RLReport,
  RLFilters,
  RLPDFFilter,
  Data.DB;

type
  TProgressoRelatorio = procedure(
    AAtual, ATotal: Integer) of object;

  TFrmImpressaoOS = class(TForm)
    dsRelatorio: TDataSource;
    pdfRelatorio: TRLPDFFilter;
    rlRelatorio: TRLReport;
    bandTitulo: TRLBand;
    grupoStatus: TRLGroup;
    bandStatus: TRLBand;
    bandColunas: TRLBand;
    bandDetalhe: TRLBand;
    bandSubtotal: TRLBand;
    bandTotalGeral: TRLBand;
    bandRodape: TRLBand;
    lblTitulo: TRLLabel;
    lblStatusTitulo: TRLLabel;
    txtStatus: TRLDBText;
    lblColOS: TRLLabel;
    lblColCliente: TRLLabel;
    lblColAbertura: TRLLabel;
    lblColPrevisao: TRLLabel;
    lblColValor: TRLLabel;
    txtOS: TRLDBText;
    txtCliente: TRLDBText;
    txtAbertura: TRLDBText;
    txtPrevisao: TRLDBText;
    txtValor: TRLDBText;
    lblQuantidadeStatus: TRLLabel;
    resQuantidadeStatus: TRLDBResult;
    lblSubtotalStatus: TRLLabel;
    resSubtotalStatus: TRLDBResult;
    lblQuantidadeGeral: TRLLabel;
    resQuantidadeGeral: TRLDBResult;
    lblTotalGeral: TRLLabel;
    resTotalGeral: TRLDBResult;
    lblGeradoEm: TRLLabel;
    infoGeracao: TRLSystemInfo;
    lblPagina: TRLLabel;
    infoPagina: TRLSystemInfo;
  private
    FProgresso: TProgressoRelatorio;
    FTotalRegistros: Integer;
    FRegistrosProcessados: Integer;

    procedure bandDetalheAfterPrint(Sender: TObject);
  public
    procedure Preparar(const ADataSet: TDataSet;
      AProgresso: TProgressoRelatorio);
    procedure Visualizar;
    procedure ExportarPDF(const aArquivo: string);
  end;

var
  FrmImpressaoOS: TFrmImpressaoOS;

implementation

uses
  Sky.Service.Log;

{$R *.dfm}

{ TFrmImpressaoOS }

procedure TFrmImpressaoOS.bandDetalheAfterPrint(Sender: TObject);
begin
  if FRegistrosProcessados < FTotalRegistros then
    Inc(FRegistrosProcessados);

  if Assigned(FProgresso) then
    FProgresso(FRegistrosProcessados, FTotalRegistros);
end;

procedure TFrmImpressaoOS.ExportarPDF(const aArquivo: string);
begin
  if Trim(AArquivo) = '' then
    raise EOperacaoRecusada.Create('Nome do arquivo nao informado.');

  if not SameText(ExtractFileExt(AArquivo), '.pdf') then
    raise EOperacaoRecusada.Create('Informe um arquivo com extensao .pdf.');

  pdfRelatorio.ShowProgress := False;
  pdfRelatorio.FileName := AArquivo;
  pdfRelatorio.FilterPages(rlRelatorio.Pages);
end;

procedure TFrmImpressaoOS.Preparar(const ADataSet: TDataSet;
      AProgresso: TProgressoRelatorio);
begin
  if ADataSet = nil then
    raise Exception.Create('Dados do relatorio nao informados.');

  if not ADataSet.Active then
    raise Exception.Create('Consulta do relatorio fechada.');

  if ADataSet.IsEmpty then
    raise EOperacaoRecusada.Create('Nenhuma OS encontrada para os filtros.');

  FProgresso := AProgresso;
  FTotalRegistros := 0;
  FRegistrosProcessados := 0;

  // Percorre a consulta para contar inclusive registros
  // que o driver ainda nao trouxe para a memoria.
  ADataSet.DisableControls;
  try
    ADataSet.First;

    while not ADataSet.Eof do
    begin
      Inc(FTotalRegistros);
      ADataSet.Next;
    end;

    ADataSet.First;
  finally
    ADataSet.EnableControls;
  end;

  dsRelatorio.DataSet := ADataSet;

  txtAbertura.DisplayMask := 'dd/MM/yyyy';
  txtPrevisao.DisplayMask := 'dd/MM/yyyy';
  txtValor.DisplayMask := '#,##0.00';

  bandDetalhe.AfterPrint := bandDetalheAfterPrint;

  rlRelatorio.ShowProgress := False;
  rlRelatorio.ForcePrepare := False;

  if Assigned(FProgresso) then
    FProgresso(0, FTotalRegistros);

  if not rlRelatorio.Prepare then
    raise Exception.Create(
      'A preparacao do relatorio nao foi concluida.');
end;

procedure TFrmImpressaoOS.Visualizar;
begin
  rlRelatorio.PreviewModal;
end;

end.
