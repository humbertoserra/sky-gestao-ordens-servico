unit Sky.View.Principal;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
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
    itemMenuClientes: TMenuItem;
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
    cbxCliente: TComboBox;
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
    lblStatus: TLabel;
    cbxStatusOS: TComboBox;
    lblSomenteConsulta: TLabel;
    menuOS: TMenuItem;
    itemMenuExcluirOS: TMenuItem;
    itemMenuOrdemServico: TMenuItem;

    procedure menuSairClick(Sender: TObject);
    procedure btnNovoClienteClick(Sender: TObject);
    procedure itemMenuClientesClick(Sender: TObject);
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure btnNovoItemClick(Sender: TObject);
    procedure btnExcluiItemClick(Sender: TObject);
    procedure btnNovaOSClick(Sender: TObject);
    procedure btnSalvarOSClick(Sender: TObject);
    procedure btnDescartarOSClick(Sender: TObject);
    procedure checkFiltroAberturaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure itemMenuExcluirOSClick(Sender: TObject);
    procedure itemMenuOrdemServicoClick(Sender: TObject);
  private
    FControllerFactory: iControllerFactory;
    FController: iControllerOrdemServico;
    FDataSourceOS: TDataSource;
    FDataSourceItens: TDataSource;
    FStatusDisponiveis: array of TStatusOrdemServico;
    FAtualizandoItensView: Boolean;

    procedure AtualizarApresentacaoItens;
    procedure ItensDataChange(Sender: TObject; Field: TField);
    procedure ItensStateChange(Sender: TObject);
    procedure ConfirmarEdicaoItem;
    procedure CarregarStatusOS;
    procedure CMChildKey(
      var Message: TCMChildKey); message CM_CHILDKEY;

    procedure VerificarInicializacao;
    procedure AbrirCadastroCliente(const aNovo: Boolean;
      const AClienteID: Integer = 0);
    procedure CarregarCombo;
    procedure ConfigurarGridOS;
    procedure ConfigurarGridItens;
    procedure CarregarClientes;
    procedure AtualizarIndicadores;
    procedure Pesquisar;

    function ClienteSelecionadoID: Integer;
    function LerFiltro: TFiltroOrdemServico;
    procedure ExibirOrdem;
    procedure CarregarOrdemSelecionada;
    procedure gridOSDblClick(Sender: TObject);
    procedure gridOSKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure gridItemOrdemColExit(Sender: TObject);
    procedure gridItemOrdemKeyDown(
      Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure gridOSDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure TratarExcecaoAplicacao(Sender: TObject; E: Exception);
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
  Sky.Service.Utils,
  Sky.View.Relatorios,
  Sky.Service.Log;


procedure TFrmPrincipal.TratarExcecaoAplicacao(Sender: TObject; E: Exception);
var
  Contexto: string;
begin
  if E is EAbort then
    exit;

  Contexto := 'Excecao nao tratada';

  TLog.Excecao(llError, 'Aplicacao.OnException', Contexto, E);

  Application.ShowException(E);
end;

destructor TFrmPrincipal.Destroy;
begin
  Application.OnException := nil;

  if FDataSourceItens <> nil then
    FDataSourceItens.DataSet := nil;

  if FDataSourceOS <> nil then
    FDataSourceOS.DataSet := nil;

  FController := nil;
  FControllerFactory := nil;

  inherited Destroy;
end;

procedure TFrmPrincipal.ExibirOrdem;
var
  Dados: TDadosOrdemServico;
  Editavel: Boolean;
  TemOrdem: Boolean;
begin
  VerificarInicializacao;

  Dados := FController.Dados;
  Editavel := FController.PodeEditar;
  TemOrdem := Editavel or (Dados.ID > 0);

  if Dados.ID > 0 then
    lblNumeroOS.Caption := Format('%.7d', [Dados.ID])
  else if Editavel then
    lblNumeroOS.Caption := 'Nova'
  else
    lblNumeroOS.Caption := '';

  cbxCliente.ItemIndex :=
    cbxCliente.Items.IndexOfObject(
      TObject(Dados.ClienteID));

  editProblema.Text := Dados.Problema;

  if TemOrdem then
  begin
    dtpAbertura.Date := Dados.DataAbertura;
    dtpPrevista.Date := Dados.DataPrevista;
  end
  else
  begin
    dtpAbertura.Date := Date;
    dtpPrevista.Date := Date;
  end;

  lblStatus.Caption := 'Status';
  lblStatus.FocusControl := cbxStatusOS;
  CarregarStatusOS;

  lblTotal.Caption :=
    FormatFloat('R$ #,##0.00', Dados.ValorTotal);

  cbxCliente.Enabled := Editavel;
  btnNovoCliente.Enabled := Editavel;
  dtpAbertura.Enabled := Editavel;
  dtpPrevista.Enabled := Editavel;

  editProblema.ReadOnly := not Editavel;

  AtualizarApresentacaoItens;

  btnSalvarOS.Enabled := Editavel;
  btnDescartarOS.Enabled := TemOrdem;

  groupOS.Caption := '  Ordem de Servico  ';
  lblSomenteConsulta.Visible := TemOrdem and not Editavel;
  itemMenuExcluirOS.Enabled := Editavel and (Dados.ID > 0);
end;

procedure TFrmPrincipal.AbrirCadastroCliente(
  const aNovo: Boolean; const AClienteID: Integer = 0);
var
  Formulario: TFrmClientes;
  ControllerCliente: iControllerCliente;
  ClienteSalvoID: Integer;
  SelecionarAoRetornar: Boolean;
begin
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
      TLog.Excecao(llError, 'Principal.AbrirCadastroCliente',
        'Abertura do cadastro de clientes', E);

      ShowMessage('Nao foi possivel abrir o cadastro de clientes: ' +
        E.Message);
      Exit;
    end;
  end;

  try
    CarregarClientes;

    if SelecionarAoRetornar and (ClienteSalvoID > 0) then
      cbxCliente.ItemIndex :=
        cbxCliente.Items.IndexOfObject(
          TObject(ClienteSalvoID));

    Pesquisar;
  except
    on E: Exception do
    begin
      TLog.Excecao(llError, 'Principal.AbrirCadastroCliente',
        'Atualizacao da tela apos cadastro de clientes', E);

      ShowMessage('Nao foi possivel atualizar os dados da tela principal: ' +
        E.Message);
    end;
  end;
end;

procedure TFrmPrincipal.btnDescartarOSClick(Sender: TObject);
begin
  try
    VerificarInicializacao;

    if FController.PodeEditar then
      if MessageDlg(
        'Deseja descartar as alteracoes da OS? ' +
        'Os dados ja salvos permanecerao no sistema.',
        mtConfirmation,
        [mbYes, mbNo],
        0) <> mrYes then
        Exit;

    FController.Descartar;
    ExibirOrdem;

    if btnNovaOS.CanFocus then
      btnNovaOS.SetFocus;
  except
    on E: Exception do
    begin
      TLog.Excecao(llError, 'Principal.AbrirCadastroCliente',
        'Atualizacao da tela apos cadastro de clientes', E);

      ShowMessage('Nao foi possivel descartar as alteracoes: ' + E.Message);
    end;
  end;
end;

procedure TFrmPrincipal.btnExcluiItemClick(Sender: TObject);
var
  Consulta: TDataSet;
  Indice: Integer;
begin
  try
    VerificarInicializacao;

    if not FController.PodeEditar then
      Exit;

    Consulta := FController.DataSetItens;

    if Consulta = nil then
      Exit;

    if not Consulta.Active then
      Exit;

    if Consulta.State <> dsInsert then
      if Consulta.IsEmpty then
        Exit;

    if MessageDlg(
      'Deseja remover o item selecionado? ' +
      'A remocao de um item ja salvo sera confirmada ' +
      'no banco somente ao salvar a OS.',
      mtConfirmation,
      [mbYes, mbNo],
      0) <> mrYes then
      Exit;

    if Consulta.State = dsInsert then
      Consulta.Cancel
    else
    begin
      if Consulta.State = dsEdit then
        Consulta.Cancel;

      Indice := Consulta.RecNo - 1;
      FController.ExcluirItem(Indice);
    end;

    AtualizarApresentacaoItens;

    if gridItemOrdem.CanFocus then
      gridItemOrdem.SetFocus;
  except
    on E: Exception do
    begin
      TLog.Excecao(llError, 'OS.btnExcluiItemClick',
        'Remocao de item na edicao da OS', E);

      ShowMessage('Nao foi possivel remover o item: ' + E.Message);
    end;
  end;
end;

procedure TFrmPrincipal.btnFiltrarClick(Sender: TObject);
begin
  try
    Pesquisar;
    AtualizarIndicadores;
  except
    on E: Exception do
    begin
      TLog.Excecao(llError, 'OS.btnFiltrarClick',
        'Pesquisa de ordens de servico', E);

      ShowMessage('Nao foi possivel atualizar a consulta: ' + E.Message);
    end;
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
    begin
      TLog.Excecao(llError, 'OS.btnLimparClick',
        'Limpeza dos filtros e atualizacao da consulta', E);

      ShowMessage('Nao foi possivel atualizar a consulta: ' + E.Message);
    end;
  end;
end;

procedure TFrmPrincipal.btnNovaOSClick(Sender: TObject);
begin
  try
    VerificarInicializacao;

    if FController.PodeEditar then
      if MessageDlg(
        'Deseja descartar o preenchimento atual e iniciar uma nova OS?',
        mtConfirmation,
        [mbYes, mbNo],
        0) <> mrYes then
        Exit;

    FController.Novo;
    ExibirOrdem;

    if cbxCliente.CanFocus then
      cbxCliente.SetFocus;
  except
    on E: Exception do
    begin
      TLog.Excecao(llError, 'OS.btnNovaOSClick',
        'Preparacao de uma nova OS', E);

      ShowMessage('Nao foi possivel iniciar uma nova OS: ' + E.Message);
    end;
  end;
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
  try
    VerificarInicializacao;

    if not FController.PodeEditar then
      Exit;

    ConfirmarEdicaoItem;
    FController.NovoItem;

    gridItemOrdem.SelectedIndex := 0;

    if gridItemOrdem.CanFocus then
    begin
      gridItemOrdem.SetFocus;
      gridItemOrdem.EditorMode := True;
    end;

    AtualizarApresentacaoItens;
  except
    on E: Exception do
    begin
      TLog.Excecao(llError, 'OS.btnNovoItemClick',
        'Inclusao de item na edicao da OS', E);

      ShowMessage('Nao foi possivel iniciar o item: ' + E.Message);
    end;
  end;
end;

procedure TFrmPrincipal.btnSalvarOSClick(Sender: TObject);
var
  Dados: TDadosOrdemServico;
  IndiceStatus: Integer;
begin
  try
    VerificarInicializacao;

    if not FController.PodeEditar then
      Exit;

    Dados := FController.Dados;

    Dados.ClienteID := ClienteSelecionadoID;
    Dados.DataAbertura := Trunc(dtpAbertura.Date);
    Dados.DataPrevista := Trunc(dtpPrevista.Date);
    Dados.Problema := Trim(editProblema.Text);

    if Dados.ClienteID = 0 then
    begin
      ShowMessage('Selecione o cliente da OS.');

      if cbxCliente.CanFocus then
        cbxCliente.SetFocus;

      Exit;
    end;

    IndiceStatus := cbxStatusOS.ItemIndex;

    if (IndiceStatus < 0) or
       (IndiceStatus >= Length(FStatusDisponiveis)) then
    begin
      ShowMessage('Selecione o status da OS.');

      if cbxStatusOS.CanFocus then
        cbxStatusOS.SetFocus;

      Exit;
    end;

    Dados.Status := FStatusDisponiveis[IndiceStatus];

      ConfirmarEdicaoItem;
    FController.Salvar(Dados);
  except
    on E: Exception do
    begin
      TLog.Excecao(llError, 'OS.btnSalvarOSClick',
        'Gravacao da OS e dos itens', E);

      ShowMessage('Nao foi possivel salvar a OS: ' + E.Message);
      Exit;
    end;
  end;

  try
    ExibirOrdem;

    if btnNovaOS.CanFocus then
      btnNovaOS.SetFocus;

    Pesquisar;
    AtualizarIndicadores;
  except
    on E: Exception do
    begin
      TLog.Excecao(llError, 'OS.btnSalvarOSClick',
        'Atualizacao da tela apos OS gravada', E);

      ShowMessage('A OS foi salva, mas nao foi possivel atualizar a tela. ' +
        'Atualize a consulta pelo botao Filtrar. ' +
        E.Message);
    end;
  end;
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

procedure TFrmPrincipal.CarregarOrdemSelecionada;
var
  Consulta: TDataSet;
  ConsultaItens: TDataSet;
  OrdemID: Integer;
begin
  try
    VerificarInicializacao;

    Consulta := FController.DataSetListagem;

    if Consulta = nil then
      Exit;

    if not Consulta.Active then
      Exit;

    if Consulta.IsEmpty then
      Exit;

    OrdemID := Consulta.FieldByName('ID').AsInteger;

    if FController.PodeEditar then
      if MessageDlg(
        'Deseja descartar o preenchimento atual ' +
        'e carregar a OS selecionada?',
        mtConfirmation,
        [mbYes, mbNo],
        0) <> mrYes then
        Exit;

    ConsultaItens := FController.DataSetItens;

    if ConsultaItens <> nil then
      if ConsultaItens.Active then
        if ConsultaItens.State in [dsEdit, dsInsert] then
          ConsultaItens.Cancel;

    FController.Carregar(OrdemID);
    ExibirOrdem;

    if cbxCliente.CanFocus then
      cbxCliente.SetFocus;
  except
    on E: Exception do
    begin
      TLog.Excecao(llError, 'OS.CarregarOrdemSelecionada',
        'Carregamento da OS selecionada', E);

      ShowMessage('Nao foi possivel carregar a OS: ' + E.Message);
    end;
  end;
end;

procedure TFrmPrincipal.CarregarStatusOS;
var
  Dados: TDadosOrdemServico;
  Status: TStatusOrdemServico;
  Texto: string;
  Indice: Integer;
  Editavel: Boolean;
  TemOrdem: Boolean;
begin
  Dados := FController.Dados;
  Editavel := FController.PodeEditar;
  TemOrdem := Editavel or (Dados.ID > 0);

  cbxStatusOS.Style := csDropDownList;
  cbxStatusOS.Sorted := False;

  cbxStatusOS.Items.BeginUpdate;
  try
    cbxStatusOS.ItemIndex := -1;
    cbxStatusOS.Items.Clear;
    cbxStatusOS.Text := '';
    SetLength(FStatusDisponiveis, 0);

    if TemOrdem then
      for Status := Low(TStatusOrdemServico) to
                    High(TStatusOrdemServico) do
        if (Status = Dados.Status) or (Editavel and
            FController.PodeAlterarStatus(Status)) then
        begin
          case Status of
            soAberta:
              Texto := 'Aberta';

            soEmAndamento:
              Texto := 'Em Andamento';

            soConcluida:
              Texto := 'Conclu' + #237 + 'da';

            soCancelada:
              Texto := 'Cancelada';
          else
            Texto := '';
          end;

          Indice := Length(FStatusDisponiveis);
          SetLength(FStatusDisponiveis, Indice + 1);
          FStatusDisponiveis[Indice] := Status;

          cbxStatusOS.Items.Add(Texto);

          if Status = Dados.Status then
            cbxStatusOS.ItemIndex := Indice;
        end;

    cbxStatusOS.Enabled :=
      Editavel and (cbxStatusOS.Items.Count > 1);
  finally
    cbxStatusOS.Items.EndUpdate;
  end;
end;

procedure TFrmPrincipal.ConfigurarGridItens;
begin
  gridItemOrdem.ReadOnly := True;

    gridItemOrdem.Options := (gridItemOrdem.Options -
      [dgAlwaysShowEditor, dgRowSelect]) +
      [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines];

  gridItemOrdem.Columns.BeginUpdate;
  try
    gridItemOrdem.Columns.Clear;

    with gridItemOrdem.Columns.Add do
    begin
      FieldName := 'DESCRICAO';
      Title.Caption := 'Descricao';
      Width := 180;
    end;

    with gridItemOrdem.Columns.Add do
    begin
      FieldName := 'QUANTIDADE';
      Title.Caption := 'Qtd.';
      Title.Alignment := taCenter;
      Alignment := taRightJustify;
      Width := 65;
    end;

    with gridItemOrdem.Columns.Add do
    begin
      FieldName := 'VALOR_UNITARIO';
      Title.Caption := 'Valor unit.';
      Title.Alignment := taCenter;
      Alignment := taRightJustify;
      Width := 100;
    end;
  finally
    gridItemOrdem.Columns.EndUpdate;
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

  gridOS.OnDrawColumnCell := gridOSDrawColumnCell;
end;

procedure TFrmPrincipal.ConfirmarEdicaoItem;
var
  Consulta: TDataSet;
begin
  Consulta := FController.DataSetItens;

  if Consulta = nil then
    Exit;

  if not Consulta.Active then
    Exit;

  if Consulta.State in [dsEdit, dsInsert] then
    Consulta.Post;
end;

function TFrmPrincipal.ClienteSelecionadoID: Integer;
var
  Indice: Integer;
begin
  Result := 0;
  Indice := cbxCliente.ItemIndex;

  if (Indice >= 0) and
     (Indice < cbxCliente.Items.Count) then
    Result := Integer(cbxCliente.Items.Objects[Indice]);
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

  cbxCliente.Items.BeginUpdate;
  try
    cbxCliente.Items.Clear;

    Consulta.DisableControls;
    try
      Consulta.First;

      while not Consulta.Eof do
      begin
        cbxCliente.Items.AddObject(
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

    cbxCliente.ItemIndex :=
      cbxCliente.Items.IndexOfObject(TObject(ClienteID));
  finally
    cbxCliente.Items.EndUpdate;
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

procedure TFrmPrincipal.AtualizarApresentacaoItens;
var
  Consulta: TDataSet;
  Dados: TDadosOrdemServico;
  Editavel: Boolean;
begin
  if FAtualizandoItensView then
    Exit;

  if FController = nil then
    Exit;

  if FDataSourceItens = nil then
    Exit;

  Consulta := FDataSourceItens.DataSet;

  if Consulta = nil then
    Exit;

  if not Consulta.Active then
    Exit;

  FAtualizandoItensView := True;
  try
    if Consulta.State = dsBrowse then
      FController.RecalcularTotal;

    Dados := FController.Dados;
    Editavel := FController.PodeEditar;

    lblTotal.Caption :=
      FormatFloat('R$ #,##0.00', Dados.ValorTotal);

    gridItemOrdem.ReadOnly := not Editavel;
    FDataSourceItens.AutoEdit := Editavel;

    btnNovoItem.Enabled := Editavel;

    btnExcluiItem.Enabled :=
      Editavel and
      ((Consulta.State = dsInsert) or
       (Consulta.RecordCount > 0));
  finally
    FAtualizandoItensView := False;
  end;
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
var
  Controle: TWinControl;
  Tecla: Word;
begin
  if (Message.CharCode in [VK_RETURN, VK_ESCAPE]) and
     (GetKeyState(VK_MENU) >= 0) and
     (GetKeyState(VK_CONTROL) >= 0) and
     (GetKeyState(VK_SHIFT) >= 0) then
  begin
    Controle := ActiveControl;

    while Controle <> nil do
    begin
      if Controle = gridItemOrdem then
      begin
        Tecla := Message.CharCode;
        gridItemOrdemKeyDown(gridItemOrdem, Tecla, []);
        Message.Result := 1;
        Exit;
      end;

      Controle := Controle.Parent;
    end;
  end;

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

  cbxCliente.Style := csDropDownList;
  cbxCliente.Sorted := False;

  FDataSourceOS := TDataSource.Create(Self);
  FDataSourceOS.AutoEdit := False;

  gridOS.DataSource := FDataSourceOS;
  gridOS.OnDblClick := gridOSDblClick;
  gridOS.OnKeyDown := gridOSKeyDown;

  FDataSourceItens := TDataSource.Create(Self);
  FDataSourceItens.AutoEdit := False;

  gridItemOrdem.DataSource := FDataSourceItens;

  ConfigurarGridOS;
  ConfigurarGridItens;

  FDataSourceItens.OnDataChange := ItensDataChange;
  FDataSourceItens.OnStateChange := ItensStateChange;

  gridItemOrdem.OnColExit := gridItemOrdemColExit;
  gridItemOrdem.OnKeyDown := gridItemOrdemKeyDown;

  gridItemOrdem.Options := gridItemOrdem.Options + [dgTabs];
end;

procedure TFrmPrincipal.gridItemOrdemColExit(Sender: TObject);
begin
  AtualizarApresentacaoItens;
end;

procedure TFrmPrincipal.gridItemOrdemKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Tecla: Word;
begin
  if Shift <> [] then
    Exit;

  if not (Key in [VK_RETURN, VK_ESCAPE]) then
    Exit;

  Tecla := Key;
  Key := 0;

  if gridItemOrdem.Columns.Count = 0 then
    Exit;

  try
    if Tecla = VK_RETURN then
    begin
      if gridItemOrdem.SelectedIndex < gridItemOrdem.Columns.Count - 1 then
        gridItemOrdem.SelectedIndex := gridItemOrdem.SelectedIndex + 1
      else
        Perform(WM_NEXTDLGCTL, 0, 0);
    end
    else
    begin
      if gridItemOrdem.SelectedIndex > 0 then
        gridItemOrdem.SelectedIndex := gridItemOrdem.SelectedIndex - 1
      else
        Perform(WM_NEXTDLGCTL, 1, 0);
    end;

    AtualizarApresentacaoItens;
  except
    on E: Exception do
    begin
      TLog.Excecao(llError, 'OS.gridItemOrdemKeyDown',
        'Edicao dos itens da OS', E);

      ShowMessage(E.Message);
    end;
  end;
end;

procedure TFrmPrincipal.gridOSDblClick(Sender: TObject);
begin
  CarregarOrdemSelecionada;
end;

procedure TFrmPrincipal.gridOSDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Atrasada: Boolean;
begin
  Atrasada := False;

  if FController <> nil then
    Atrasada := FController.ListagemEmAtraso;

  gridOS.Canvas.Font.Assign(gridOS.Font);

  if gdSelected in State then
  begin
    gridOS.Canvas.Brush.Color := clHighlight;
    gridOS.Canvas.Font.Color := clHighlightText;
  end
  else
  begin
    gridOS.Canvas.Brush.Color := gridOS.Color;
    gridOS.Canvas.Font.Color := gridOS.Font.Color;

    if Atrasada then
    begin
      gridOS.Canvas.Brush.Color := RGB(255, 248, 220);
      gridOS.Canvas.Font.Color := clMaroon;
    end;
  end;

  if Atrasada then
    gridOS.Canvas.Font.Style :=
      gridOS.Canvas.Font.Style + [fsBold];

  gridOS.Canvas.FillRect(Rect);
  gridOS.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TFrmPrincipal.gridOSKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (Shift = []) then
  begin
    Key := 0;
    CarregarOrdemSelecionada;
  end;
end;

procedure TFrmPrincipal.Inicializar(const aFactory: iControllerFactory);
begin
  Application.OnException := TratarExcecaoAplicacao;

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
    FDataSourceItens.DataSet := FController.DataSetItens;

    if FDataSourceItens.DataSet = nil then
      raise Exception.Create(
        'Tabela dos itens indisponivel.');

    if not FDataSourceItens.DataSet.Active then
      raise Exception.Create(
        'Tabela dos itens fechada.');

    CarregarClientes;
    Pesquisar;
    AtualizarIndicadores;
    ExibirOrdem;
  except
    FDataSourceItens.DataSet := nil;
    FDataSourceOS.DataSet := nil;
    cbxCliente.Items.Clear;

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

procedure TFrmPrincipal.itemMenuClientesClick(Sender: TObject);
begin
  AbrirCadastroCliente(False);
end;

procedure TFrmPrincipal.itemMenuExcluirOSClick(Sender: TObject);
var
  Dados: TDadosOrdemServico;
begin
  try
    VerificarInicializacao;

    if not FController.PodeEditar then
      Exit;

    Dados := FController.Dados;

    if Dados.ID <= 0 then
      Exit;

    if MessageDlg(
      Format(
        'Deseja excluir a OS %.7d da listagem? ' +
        'O registro e seus itens serao preservados no banco. ' +
        'Alteracoes ainda nao salvas serao descartadas.',
        [Dados.ID]),
      mtConfirmation,
      [mbYes, mbNo],
      0) <> mrYes then
      Exit;

    FController.Excluir;
  except
    on E: Exception do
    begin
      TLog.Excecao(llError, 'OS.itemMenuExcluirOSClick', 'Exclusao da OS', E);

      ShowMessage('Nao foi possivel excluir a OS: ' + E.Message);
      Exit;
    end;
  end;

  try
    ExibirOrdem;

    if btnNovaOS.CanFocus then
      btnNovaOS.SetFocus;

    Pesquisar;
    AtualizarIndicadores;
  except
    on E: Exception do
    begin
      TLog.Excecao(llError, 'OS.itemMenuExcluirOSClick',
        'Atualizacao da tela apos OS excluida', E);

      ShowMessage('A OS foi excluida, mas nao foi possivel ' +
        'atualizar a tela. Utilize o botao Filtrar. ' + E.Message);
    end;
  end;
end;

procedure TFrmPrincipal.itemMenuOrdemServicoClick(Sender: TObject);
var
  Formulario: TFrmRelatoriosOS;
begin
  try
    VerificarInicializacao;

    Formulario := TFrmRelatoriosOS.Create(Self);
    try
      Formulario.Inicializar(
        FControllerFactory.RelatorioOS);

      Formulario.ShowModal;
    finally
      Formulario.Free;
    end;
  except
    on E: Exception do
    begin
      TLog.Excecao(llError, 'OS.CarregarOrdemSelecionada',
        'Carregamento da OS selecionada', E);

      ShowMessage('Nao foi possivel abrir o relatorio: ' + E.Message);
    end;
  end;
end;

procedure TFrmPrincipal.ItensDataChange(
  Sender: TObject; Field: TField);
begin
  AtualizarApresentacaoItens;
end;

procedure TFrmPrincipal.ItensStateChange(Sender: TObject);
begin
  AtualizarApresentacaoItens;
end;

procedure TFrmPrincipal.menuSairClick(Sender: TObject);
begin
  Close;
end;

end.
