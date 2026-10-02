unit Sky.View.Relatorios;

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
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.CheckLst,
  Sky.Controller.Interfaces;

type
  TFrmRelatoriosOS = class(TForm)
    pnlContainer: TPanel;
    pbRelatorio: TProgressBar;
    btnVisualizar: TButton;
    btnExportarPDF: TButton;
    btnFechar: TButton;
    groupFiltros: TGroupBox;
    checkPeriodo: TCheckBox;
    dtpInicial: TDateTimePicker;
    lblAte: TLabel;
    dtpFinal: TDateTimePicker;
    lblCliente: TLabel;
    editCliente: TEdit;
    lblStatus: TLabel;
    clbStatus: TCheckListBox;
  private
    FController: iControllerRelatoriosOS;

    function LerFiltro: TFiltroRelatoriosOS;
    procedure checkPeriodoClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnVisualizarClick(Sender: TObject);
    procedure btnExportarPDFClick(Sender: TObject);
    procedure AtualizarProgresso(AAtual, ATotal: Integer);
  public
    procedure Inicializar(const AController: iControllerRelatoriosOS);
  end;

var
  FrmRelatoriosOS: TFrmRelatoriosOS;

implementation

uses
  Sky.View.ImpressaoOS;

{$R *.dfm}

{ TFrmRelatoriosOS }

procedure TFrmRelatoriosOS.AtualizarProgresso(AAtual, ATotal: Integer);
begin
  if ATotal <= 0 then
    Exit;

  pbRelatorio.Style := pbstNormal;
  pbRelatorio.Min := 0;
  pbRelatorio.Max := ATotal;
  pbRelatorio.Position := AAtual;
  pbRelatorio.Update;
end;

procedure TFrmRelatoriosOS.btnExportarPDFClick(Sender: TObject);
var
  Filtro: TFiltroRelatoriosOS;
  Dialogo: TSaveDialog;
  Arquivo: string;
  Impressao: TFrmImpressaoOS;
begin
  try
    if FController = nil then
      raise Exception.Create(
        'Controller do relatorio nao informado.');

    Filtro := LerFiltro;

    Dialogo := TSaveDialog.Create(Self);
    try
      Dialogo.Title := 'Exportar relatorio de OS';
      Dialogo.Filter := 'Arquivo PDF (*.pdf)|*.pdf';
      Dialogo.DefaultExt := 'pdf';
      Dialogo.FileName := 'Relatorio_OS.pdf';
      Dialogo.Options := [
        ofOverwritePrompt,
        ofHideReadOnly,
        ofPathMustExist,
        ofNoChangeDir
      ];

      if not Dialogo.Execute then
        Exit;

      Arquivo := Dialogo.FileName;
    finally
      Dialogo.Free;
    end;

    if not SameText(ExtractFileExt(Arquivo), '.pdf') then
      raise Exception.Create(
        'Informe um arquivo com extensao .pdf.');

    groupFiltros.Enabled := False;
    btnVisualizar.Enabled := False;
    btnExportarPDF.Enabled := False;
    btnFechar.Enabled := False;

    pbRelatorio.Style := pbstMarquee;
    pbRelatorio.Visible := True;
    pbRelatorio.Update;

    try
      FController.Pesquisar(Filtro);

      Impressao := TFrmImpressaoOS.Create(Self);
      try
        Impressao.Preparar(FController.DataSet, AtualizarProgresso);
        Impressao.ExportarPDF(Arquivo);
        pbRelatorio.Style := pbstMarquee;
        pbRelatorio.Update;
      finally
        Impressao.Free;
      end;
    finally
      pbRelatorio.Visible := False;
      pbRelatorio.Style := pbstNormal;

      groupFiltros.Enabled := True;
      btnVisualizar.Enabled := True;
      btnExportarPDF.Enabled := True;
      btnFechar.Enabled := True;
    end;

    ShowMessage('PDF exportado para:' + sLineBreak + Arquivo);
  except
    on E: Exception do
      begin
        ShowMessage(
          'Nao foi possivel exportar o PDF: ' +
          E.Message);
      end;
  end;
end;

procedure TFrmRelatoriosOS.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmRelatoriosOS.btnVisualizarClick(Sender: TObject);
var
  Filtro: TFiltroRelatoriosOS;
  Impressao: TFrmImpressaoOS;
begin
  try
    if FController = nil then
      raise Exception.Create(
        'Controller do relatorio nao informado.');

    Filtro := LerFiltro;

    groupFiltros.Enabled := False;
    btnVisualizar.Enabled := False;
    btnExportarPDF.Enabled := False;
    btnFechar.Enabled := False;

    pbRelatorio.Style := pbstMarquee;
    pbRelatorio.Visible := True;
    pbRelatorio.Update;

    try
      FController.Pesquisar(Filtro);

      Impressao := TFrmImpressaoOS.Create(Self);
      try
        Impressao.Preparar(FController.DataSet, AtualizarProgresso);

        // A geracao terminou; agora abrimos a previa.
        pbRelatorio.Visible := False;
        Impressao.Visualizar;
      finally
        Impressao.Free;
      end;
    finally
      pbRelatorio.Visible := False;
      pbRelatorio.Style := pbstNormal;

      groupFiltros.Enabled := True;
      btnVisualizar.Enabled := True;
      btnExportarPDF.Enabled := True;
      btnFechar.Enabled := True;
    end;
  except
    on E: Exception do
      begin
        ShowMessage(
          'Nao foi possivel visualizar o relatorio: ' +
          E.Message);
      end;
  end;
end;

procedure TFrmRelatoriosOS.checkPeriodoClick(Sender: TObject);
begin
  dtpInicial.Enabled := checkPeriodo.Checked;
  dtpFinal.Enabled := checkPeriodo.Checked;
  lblAte.Enabled := checkPeriodo.Checked;
end;

procedure TFrmRelatoriosOS.Inicializar(
  const AController: iControllerRelatoriosOS);
var
  I: Integer;
begin
  if AController = nil then
    raise Exception.Create(
      'Controller do relatorio nao informado.');

  FController := AController;

  checkPeriodo.OnClick := checkPeriodoClick;
  btnFechar.OnClick := btnFecharClick;

  checkPeriodo.Checked := False;

  dtpInicial.Format := 'dd/MM/yyyy';
  dtpFinal.Format := 'dd/MM/yyyy';
  dtpInicial.Date := Date;
  dtpFinal.Date := Date;

  editCliente.Clear;

  for I := 0 to clbStatus.Items.Count - 1 do
    clbStatus.Checked[I] := False;

  pbRelatorio.Position := 0;
  pbRelatorio.Visible := False;

  btnVisualizar.Caption := 'Visualizar';
  lblStatus.Caption := 'Status: nenhum marcado = todos';

  btnVisualizar.OnClick := btnVisualizarClick;
  btnVisualizar.Enabled := True;

  btnExportarPDF.OnClick := btnExportarPDFClick;
  btnExportarPDF.Enabled := True;

  checkPeriodoClick(nil);
end;

function TFrmRelatoriosOS.LerFiltro: TFiltroRelatoriosOS;
begin
  Result.FiltraPeriodo := checkPeriodo.Checked;
  Result.DataInicial := Trunc(dtpInicial.Date);
  Result.DataFinal := Trunc(dtpFinal.Date);
  Result.NomeCliente := Trim(editCliente.Text);
  Result.StatusSelecionados := [];

  if Result.FiltraPeriodo then
    if Result.DataInicial > Result.DataFinal then
    begin
      dtpInicial.SetFocus;
      raise Exception.Create(
        'Data inicial posterior a data final.');
    end;

  if clbStatus.Items.Count <> 4 then
    raise Exception.Create(
      'A lista de status deve conter os quatro status da OS.');

  if clbStatus.Checked[0] then
    Include(Result.StatusSelecionados, soAberta);

  if clbStatus.Checked[1] then
    Include(Result.StatusSelecionados, soEmAndamento);

  if clbStatus.Checked[2] then
    Include(Result.StatusSelecionados, soConcluida);

  if clbStatus.Checked[3] then
    Include(Result.StatusSelecionados, soCancelada);
end;

end.
