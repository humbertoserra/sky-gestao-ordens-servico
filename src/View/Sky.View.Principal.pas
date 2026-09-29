unit Sky.View.Principal;

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
  Data.DB,
  Vcl.StdCtrls,
  Vcl.DBCtrls,
  Vcl.Mask,
  Vcl.ExtCtrls,
  Vcl.Buttons,
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.Menus,
  Vcl.ComCtrls,
  Sky.Controller.Interfaces;

type
  TFrmPrincipal = class(TForm)
    MainMenu: TMainMenu;
    menuCadastro: TMenuItem;
    menuClientes: TMenuItem;
    menuSair: TMenuItem;
    Relatrios1: TMenuItem;
    pnlContainer: TPanel;
    groupListaOS: TGroupBox;
    groupFIltros: TGroupBox;
    groupListagem: TGroupBox;
    groupOS: TGroupBox;
    groupIndicadores: TGroupBox;
    lblAbertas: TLabel;
    lblAbertasControle: TLabel;
    lblAndamento: TLabel;
    lblAndamentoControle: TLabel;
    lblConcluidas: TLabel;
    lblConcluidasControle: TLabel;
    lblAtrasadas: TLabel;
    lblAtrasadasControle: TLabel;
    gridOS: TDBGrid;
    lblOS: TLabel;
    lblNumeroOS: TLabel;
    groupClientes: TGroupBox;
    lblClienteTitulo: TLabel;
    comboCliente: TComboBox;
    btnNovoCliente: TBitBtn;
    groupDatas: TGroupBox;
    lblDataAbertura: TLabel;
    dtpAbertura: TDateTimePicker;
    lblDataPrevista: TLabel;
    dtpPrevista: TDateTimePicker;
    groupItemOrdem: TGroupBox;
    gridItemOrdem: TDBGrid;
    lblTotalTitle: TLabel;
    lblTotal: TLabel;
    btnNovoItem: TButton;
    btnExcluiItem: TButton;
    btnNovaOS: TButton;
    btnSalvarOS: TButton;
    btnDescartarOS: TButton;
    lblStatus: TLabel;
    groupProblema: TGroupBox;
    editProblema: TMemo;
    lblPesquisaCliente: TLabel;
    editPesquisa: TEdit;
    dtpDataInicial: TDateTimePicker;
    dtpDataFinal: TDateTimePicker;
    lblPesquisaStatus: TLabel;
    cbxFiltroStatus: TComboBox;
    btnFiltrar: TButton;
    btnLimpar: TButton;
    lblAte: TLabel;
    checkFiltroAbertura: TCheckBox;
    GroupBox1: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;

    procedure menuSairClick(Sender: TObject);
    procedure btnNovoClienteClick(Sender: TObject);
    procedure menuClientesClick(Sender: TObject);
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure btnNovoItemClick(Sender: TObject);
    procedure btnExcluiItemClick(Sender: TObject);
    procedure btnNovaOSClick(Sender: TObject);
    procedure btnSalvarOSClick(Sender: TObject);
    procedure btnDescartarOSClick(Sender: TObject);
    procedure checkFiltroAberturaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FControllerFactory: iControllerFactory;
    FController: iControllerOrdemServico;
    FDataSourceOS: TDataSource;

    procedure CMChildKey(
      var Message: TCMChildKey); message CM_CHILDKEY;

    procedure VerificarInicializacao;
    procedure AbrirCadastroCliente(const aNovo: Boolean;
      const AClienteID: Integer = 0);
    procedure CarregarCombo;
    procedure ConfigurarGridOS;
    procedure CarregarClientes;
    procedure AtualizarIndicadores;
    procedure Pesquisar;

    function ClienteSelecionadoID: Integer;
    function LerFiltro: TFiltroOrdemServico;
  public
    destructor Destroy; override;

    procedure Inicializar(const aFactory: iControllerFactory);
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}

uses
  Sky.View.Clientes,
  Sky.Service.Utils;

destructor TFrmPrincipal.Destroy;
begin
  if FDataSourceOS <> nil then
    FDataSourceOS.DataSet := nil;

  FController := nil;
  FControllerFactory := nil;

  inherited Destroy;
end;

procedure TFrmPrincipal.AbrirCadastroCliente(
  const aNovo: Boolean; const AClienteID: Integer = 0);
var
  Formulario: TFrmClientes;
  ControllerCliente: iControllerCliente;
  ClienteSalvoID: Integer;
  SelecionarAoRetornar: Boolean;
begin
  ClienteSalvoID := 0;

  { O menu abre com False e ID zero.
    O botao da OS inicia um novo ou informa o ID selecionado. }
  SelecionarAoRetornar := ANovo or (AClienteID > 0);

  try
    if FControllerFactory = nil then
      raise Exception.Create('Aplicacao nao inicializada.');

    ControllerCliente := FControllerFactory.Cliente;

    Formulario := TFrmClientes.Create(Self);
    try
      Formulario.Inicializar(
        ControllerCliente, ANovo, AClienteID);

      Formulario.ShowModal;

      { Le o resultado antes de liberar o formulario. }
      ClienteSalvoID := Formulario.UltimoClienteSalvoID;
    finally
      Formulario.Free;
    end;
  except
    on E: Exception do
    begin
      ShowMessage(
        'Nao foi possivel abrir o cadastro de clientes: ' +
        E.Message);
      Exit;
    end;
  end;

  try
    CarregarClientes;

    if SelecionarAoRetornar and (ClienteSalvoID > 0) then
      comboCliente.ItemIndex :=
        comboCliente.Items.IndexOfObject(
          TObject(ClienteSalvoID));

    Pesquisar;
  except
    on E: Exception do
      ShowMessage(
        'Nao foi possivel atualizar os dados da tela principal: ' +
        E.Message);
  end;
end;

procedure TFrmPrincipal.btnDescartarOSClick(Sender: TObject);
begin
  ShowMessage(
    'O descarte da manutencao ainda nao foi ligado nesta etapa.');
end;

procedure TFrmPrincipal.btnExcluiItemClick(Sender: TObject);
begin
  ShowMessage(
    'A exclusao de itens ainda nao foi ligada nesta etapa.');
end;

procedure TFrmPrincipal.btnFiltrarClick(Sender: TObject);
begin
  try
    Pesquisar;
    AtualizarIndicadores;
  except
    on E: Exception do
      ShowMessage(
        'Nao foi possivel atualizar a consulta: ' +
        E.Message);
  end;
end;

procedure TFrmPrincipal.btnLimparClick(Sender: TObject);
begin
  editPesquisa.Clear;
  cbxFiltroStatus.ItemIndex := 0;
  checkFiltroAbertura.Checked := False;

  dtpDataInicial.Date := Date;
  dtpDataFinal.Date := Date;

  checkFiltroAberturaClick(checkFiltroAbertura);

  try
    Pesquisar;
    AtualizarIndicadores;
  except
    on E: Exception do
      ShowMessage(
        'Nao foi possivel atualizar a consulta: ' +
        E.Message);
  end;
end;

procedure TFrmPrincipal.btnNovaOSClick(Sender: TObject);
begin
  ShowMessage(
    'A inclusao de OS ainda nao foi ligada nesta etapa.');
end;

procedure TFrmPrincipal.btnNovoClienteClick(Sender: TObject);
var
  ClienteID: Integer;
begin
  ClienteID := ClienteSelecionadoID;

  AbrirCadastroCliente(ClienteID = 0, ClienteID);
end;

procedure TFrmPrincipal.btnNovoItemClick(Sender: TObject);
begin
  ShowMessage(
    'A inclusao de itens ainda nao foi ligada nesta etapa.');
end;

procedure TFrmPrincipal.btnSalvarOSClick(Sender: TObject);
begin
  ShowMessage(
    'O salvamento de OS ainda nao foi ligado nesta etapa.');
end;

procedure TFrmPrincipal.CarregarCombo;
begin
  cbxFiltroStatus.Items.BeginUpdate;
  try
    cbxFiltroStatus.Items.Clear;
    cbxFiltroStatus.Items.Add('Todos');
    cbxFiltroStatus.Items.Add('Aberta');
    cbxFiltroStatus.Items.Add('Em Andamento');
    cbxFiltroStatus.Items.Add('Conclu' + #237 + 'da');
    cbxFiltroStatus.Items.Add('Cancelada');

    cbxFiltroStatus.ItemIndex := 0;
  finally
    cbxFiltroStatus.Items.EndUpdate;
  end;
end;

procedure TFrmPrincipal.ConfigurarGridOS;
begin
  gridOS.ReadOnly := True;

  gridOS.Options :=
    (gridOS.Options - [dgEditing, dgAlwaysShowEditor]) +
    [dgRowSelect];

  gridOS.Columns.BeginUpdate;
  try
    gridOS.Columns.Clear;

    with gridOS.Columns.Add do
    begin
      FieldName := 'ID';
      Title.Caption := '#';
      Title.Alignment := taCenter;
      Width := 45;
    end;

    with gridOS.Columns.Add do
    begin
      FieldName := 'CLIENTE_NOME';
      Title.Caption := 'Cliente';
      Width := 200;
    end;

    with gridOS.Columns.Add do
    begin
      FieldName := 'STATUS';
      Title.Caption := 'Status';
      Title.Alignment := taCenter;
      Width := 100;
    end;

    with gridOS.Columns.Add do
    begin
      Alignment := taCenter;
      FieldName := 'DATA_ABERTURA';
      Title.Caption := 'Abertura';
      Title.Alignment := taCenter;
      Width := 80;
    end;

    with gridOS.Columns.Add do
    begin
      Alignment := taCenter;
      FieldName := 'DATA_PREVISTA';
      Title.Caption := 'Prevista';
      Title.Alignment := taCenter;
      Width := 80;
    end;

    with gridOS.Columns.Add do
    begin
      Alignment := taRightJustify;
      FieldName := 'VALOR_TOTAL';
      Title.Caption := 'Total';
      Title.Alignment := taCenter;
      Width := 90;
    end;
  finally
    gridOS.Columns.EndUpdate;
  end;
end;

function TFrmPrincipal.ClienteSelecionadoID: Integer;
var
  Indice: Integer;
begin
  Result := 0;
  Indice := comboCliente.ItemIndex;

  if (Indice >= 0) and
     (Indice < comboCliente.Items.Count) then
    Result := Integer(comboCliente.Items.Objects[Indice]);
end;

procedure TFrmPrincipal.CarregarClientes;
var
  Consulta: TDataSet;
  ClienteID: Integer;
begin
  VerificarInicializacao;

  ClienteID := ClienteSelecionadoID;

  FController.AtualizarClientes;
  Consulta := FController.DataSetClientes;

  if Consulta = nil then
    raise Exception.Create(
      'Listagem de clientes indisponivel.');

  if not Consulta.Active then
    raise Exception.Create(
      'Listagem de clientes fechada.');

  comboCliente.Items.BeginUpdate;
  try
    comboCliente.Items.Clear;

    Consulta.DisableControls;
    try
      Consulta.First;

      while not Consulta.Eof do
      begin
        comboCliente.Items.AddObject(
          Consulta.FieldByName('NOME').AsString,
          TObject(Consulta.FieldByName('ID').AsInteger)
        );

        Consulta.Next;
      end;
    finally
      try
        Consulta.First;
      finally
        Consulta.EnableControls;
      end;
    end;

    comboCliente.ItemIndex :=
      comboCliente.Items.IndexOfObject(TObject(ClienteID));
  finally
    comboCliente.Items.EndUpdate;
  end;
end;

function TFrmPrincipal.LerFiltro: TFiltroOrdemServico;
begin
  Result.NomeCliente := Trim(editPesquisa.Text);
  Result.FiltrarPeriodo := checkFiltroAbertura.Checked;
  Result.DataInicial := Trunc(dtpDataInicial.Date);
  Result.DataFinal := Trunc(dtpDataFinal.Date);
  Result.FiltrarStatus := False;
  Result.Status := soAberta;

  case cbxFiltroStatus.ItemIndex of
    0:
      Result.FiltrarStatus := False;

    1:
      begin
        Result.FiltrarStatus := True;
        Result.Status := soAberta;
      end;

    2:
      begin
        Result.FiltrarStatus := True;
        Result.Status := soEmAndamento;
      end;

    3:
      begin
        Result.FiltrarStatus := True;
        Result.Status := soConcluida;
      end;

    4:
      begin
        Result.FiltrarStatus := True;
        Result.Status := soCancelada;
      end;
  else
    raise Exception.Create(
      'Selecione um status valido para a pesquisa.');
  end;
end;

procedure TFrmPrincipal.Pesquisar;
var
  Filtro: TFiltroOrdemServico;
begin
  VerificarInicializacao;

  Filtro := LerFiltro;
  FController.Pesquisar(Filtro);
end;

procedure TFrmPrincipal.AtualizarIndicadores;
var
  Dados: TIndicadoresOrdemServico;
begin
  VerificarInicializacao;

  FController.AtualizarIndicadores;
  Dados := FController.Indicadores;

  lblAbertasControle.Caption := IntToStr(Dados.Abertas);

  lblAndamentoControle.Caption := IntToStr(Dados.EmAndamento);

  lblConcluidasControle.Caption := IntToStr(Dados.Concluidas);

  lblAtrasadasControle.Caption := IntToStr(Dados.Atrasadas);
end;

procedure TFrmPrincipal.checkFiltroAberturaClick(
  Sender: TObject);
begin
  lblAte.Enabled := checkFiltroAbertura.Checked;
  dtpDataInicial.Enabled := lblAte.Enabled;
  dtpDataFinal.Enabled := lblAte.Enabled;
end;

procedure TFrmPrincipal.CMChildKey(
  var Message: TCMChildKey);
begin
  if TratarNavegacao(Self, Message.CharCode) then
  begin
    Message.Result := 1;
    Exit;
  end;

  inherited;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  CarregarCombo;

  dtpDataInicial.Date := Date;
  dtpDataFinal.Date := Date;

  checkFiltroAberturaClick(checkFiltroAbertura);

  comboCliente.Style := csDropDownList;
  comboCliente.Sorted := False;

  FDataSourceOS := TDataSource.Create(Self);
  FDataSourceOS.AutoEdit := False;

  gridOS.DataSource := FDataSourceOS;

  ConfigurarGridOS;
end;

procedure TFrmPrincipal.Inicializar(
  const aFactory: iControllerFactory);
begin
  if aFactory = nil then
    raise Exception.Create(
      'Fabrica de controllers nao informada.');

  if FControllerFactory <> nil then
    raise Exception.Create(
      'Formulario principal ja inicializado.');

  FControllerFactory := aFactory;

  try
    FController := FControllerFactory.OrdemServico;

    if FController = nil then
      raise Exception.Create(
        'Controller de Ordem de Servico nao informado.');

    FDataSourceOS.DataSet := FController.DataSetListagem;

    CarregarClientes;
    Pesquisar;
    AtualizarIndicadores;
  except
    FDataSourceOS.DataSet := nil;
    comboCliente.Items.Clear;

    FController := nil;
    FControllerFactory := nil;

    raise;
  end;
end;

procedure TFrmPrincipal.VerificarInicializacao;
begin
  if FController = nil then
    raise Exception.Create(
      'Formulario principal nao inicializado.');
end;

procedure TFrmPrincipal.menuClientesClick(Sender: TObject);
begin
  AbrirCadastroCliente(False);
end;

procedure TFrmPrincipal.menuSairClick(Sender: TObject);
begin
  Close;
end;

end.
