unit Sky.View.Clientes;

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
  Vcl.Grids,
  Vcl.DBGrids,
  Vcl.ExtCtrls,
  Sky.Controller.Interfaces;

type
  TFrmClientes = class(TForm)
    pnlContainer: TPanel;
    groupListaClientes: TGroupBox;
    groupFIltros: TGroupBox;
    groupListagem: TGroupBox;
    gridClientes: TDBGrid;
    groupCadastro: TGroupBox;
    lblNumeroOS: TLabel;
    groupClientes: TGroupBox;
    lblClienteTitulo: TLabel;
    btnNovo: TButton;
    btnSalvar: TButton;
    lblOS: TLabel;
    editNome: TEdit;
    Label1: TLabel;
    editEmail: TEdit;
    Label2: TLabel;
    EditDocumento: TEdit;
    Label3: TLabel;
    editTelefone: TEdit;
    checkAtivo: TCheckBox;
    btnLimpar: TButton;
    btnFiltrar: TButton;
    lblPesquisa: TLabel;
    cbxFiltroPesquisa: TComboBox;
    lblTermo: TLabel;
    editTermo: TEdit;
    lblPesquisaStatus: TLabel;
    cbxFiltroSituacao: TComboBox;
    btnFechar: TButton;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnFiltrarClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure editTelefoneKeyPress(Sender: TObject; var Key: Char);
    procedure editTelefoneExit(Sender: TObject);
    procedure editTermoKeyPress(Sender: TObject; var Key: Char);
    procedure cbxFiltroPesquisaChange(Sender: TObject);
    procedure editTermoExit(Sender: TObject);
  private
    FUltimoClienteSalvoID: integer;
    FController: iControllerCliente;
    FDataSource: TDataSource;

    procedure CMChildKey(
      var Message: TCMChildKey); message CM_CHILDKEY;
    procedure Pesquisar;
    procedure ExibirCliente;
    procedure CarregarSelecionado;
    procedure GridClientesDblClick(Sender: TObject);
    procedure GridClientesKeyDown(
      Sender: TObject; var Key: Word; Shift: TShiftState);
    function PodeDescartarEdicao: Boolean;
    procedure ConsultarFechamento(Sender: TObject; var CanClose: Boolean);
    procedure CarregarCombo;
    procedure TelefoneGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure ConfigurarFiltro;
  public
    procedure Inicializar(
      const AController: iControllerCliente;
      aNovo: Boolean = False;
      aClienteID: integer = 0);
    destructor Destroy; override;
    property UltimoClienteSalvoID: Integer read FUltimoClienteSalvoID;
  end;

var
  FrmClientes: TFrmClientes;

implementation

uses
  Sky.Service.Utils,
  Sky.Service.Log;

{$R *.dfm}

procedure TFrmClientes.btnFiltrarClick(Sender: TObject);
begin
  try
    Pesquisar;
  except
    on E: Exception do
    begin
      TLog.Excecao(llError, 'Clientes.btnFiltrarClick',
        'Pesquisa de clientes', E);

      ShowMessage(E.Message);
    end;
  end;
end;

procedure TFrmClientes.btnLimparClick(Sender: TObject);
begin
  editTermo.Clear;
  cbxFiltroPesquisa.ItemIndex := 0;
  cbxFiltroSituacao.ItemIndex := 0;

  ConfigurarFiltro;
  btnFiltrarClick(Sender);
end;

procedure TFrmClientes.btnNovoClick(Sender: TObject);
begin
  if not PodeDescartarEdicao then
    Exit;

  FController.Novo;
  ExibirCliente;
  editNome.SetFocus;
end;

procedure TFrmClientes.btnSalvarClick(Sender: TObject);
var
  Dados: TDadosCliente;
begin
  try
    Dados := FController.Dados;

    Dados.Nome := editNome.Text;
    Dados.Documento := EditDocumento.Text;
    Dados.Email := editEmail.Text;
    Dados.Telefone := editTelefone.Text;
    Dados.Ativo := checkAtivo.Checked;

    FController.Salvar(Dados);

    { Guarda o ID confirmado antes de limpar o cadastro. }
    Dados := FController.Dados;
    FUltimoClienteSalvoID := Dados.ID;

    FController.Limpar;
    ExibirCliente;
    ActiveControl := gridClientes;
  except
    on E: Exception do
    begin
      TLog.Excecao(llError, 'Clientes.btnSalvarClick',
        'Gravacao do cliente e atualizacao do formulario', E);

      ShowMessage(E.Message);
      Exit;
    end;
  end;

  try
    Pesquisar;
  except
    on E: Exception do
    begin
      TLog.Excecao(llError, 'Clientes.btnSalvarClick',
        'Atualizacao da lista apos cliente gravado', E);

      ShowMessage('Cliente salvo, mas a lista nao foi atualizada: ' +
        E.Message);
    end;
  end;
end;

procedure TFrmClientes.CarregarCombo;
begin
  //Filtro pesquisar por
  cbxFiltroPesquisa.Items.Clear;
  cbxFiltroPesquisa.Items.Add('Nome');
  cbxFiltroPesquisa.Items.Add('Documento');
  cbxFiltroPesquisa.Items.Add('Telefone');
  //cbxFiltroPesquisa.Items.Add('Email');
  cbxFiltroPesquisa.ItemIndex := 0;

  //Filtro situacao
  cbxFiltroSituacao.Items.Clear;
  cbxFiltroSituacao.Items.Add('Todos');
  cbxFiltroSituacao.Items.Add('Ativos');
  cbxFiltroSituacao.Items.Add('Inativos');
  cbxFiltroSituacao.ItemIndex := 0;

  ConfigurarFiltro;
end;

procedure TFrmClientes.CarregarSelecionado;
var
  Consulta: TDataSet;
begin
  Consulta := FController.DataSet;

  if Consulta = nil then
    Exit;

  if not Consulta.Active then
    Exit;

  if Consulta.IsEmpty then
    Exit;

  if not PodeDescartarEdicao then
    Exit;

  FController.Carregar(
    Consulta.FieldByName('ID').AsInteger);

  ExibirCliente;

  if FController.PodeEditar then
    ActiveControl := editNome
  else
    ActiveControl := gridClientes;
end;

procedure TFrmClientes.cbxFiltroPesquisaChange(Sender: TObject);
begin
  ConfigurarFiltro;
  editTermo.SetFocus;
end;

procedure TFrmClientes.CMChildKey(var Message: TCMChildKey);
begin
  if TratarNavegacao(Self, Message.CharCode) then
  begin
    Message.Result := 1;
    Exit;
  end;

  inherited;
end;

procedure TFrmClientes.ConfigurarFiltro;
begin
  editTermo.Clear;
  editTermo.CharCase := ecNormal;

  case cbxFiltroPesquisa.ItemIndex of
    0: // Nome
      begin
        editTermo.CharCase := ecUpperCase;
        editTermo.MaxLength := 120;
      end;

    1: // Documento
      editTermo.MaxLength := 20;

    2: // Telefone
      editTermo.MaxLength := 30;

   { 3: // Email
      begin
        editTermo.CharCase := ecLowerCase;
        editTermo.MaxLength := 120;
      end; }
  end;
end;

procedure TFrmClientes.ConsultarFechamento(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := PodeDescartarEdicao;
end;

destructor TFrmClientes.Destroy;
var
  Campo: TField;
begin
  if FDataSource <> nil then
  begin
    if FDataSource.DataSet <> nil then
    begin
      Campo := FDataSource.DataSet.FindField('TELEFONE');

      if Campo <> nil then
        Campo.OnGetText := nil;
    end;

    FDataSource.DataSet := nil;
  end;

  FController := nil;

  inherited Destroy;
end;

procedure TFrmClientes.editTelefoneExit(Sender: TObject);
begin
  editTelefone.Text := FormatarTelefone(editTelefone.Text);
end;

procedure TFrmClientes.editTelefoneKeyPress(Sender: TObject; var Key: Char);
begin
  { Preserva teclas de controle, incluindo copiar e colar. }
  if Key < #32 then
    Exit;

  if not ((Key >= '0') and (Key <= '9')) then
    Key := #0;
end;

procedure TFrmClientes.editTermoExit(Sender: TObject);
begin
  if cbxFiltroPesquisa.ItemIndex = 2 then
    editTermo.Text := FormatarTelefone(editTermo.Text);
end;

procedure TFrmClientes.editTermoKeyPress(Sender: TObject; var Key: Char);
begin
  if cbxFiltroPesquisa.ItemIndex <> 2 then
    Exit;

  if Key < #32 then
    Exit;

  if not ((Key >= '0') and (Key <= '9')) then
    Key := #0;
end;

procedure TFrmClientes.ExibirCliente;
var
  Dados: TDadosCliente;
  Editavel: Boolean;
begin
  Dados := FController.Dados;
  Editavel := FController.PodeEditar;

  if Dados.ID > 0 then
    lblNumeroOS.Caption := Format('%.7d', [Dados.ID])
  else if Editavel then
    lblNumeroOS.Caption := 'Novo'
  else
    lblNumeroOS.Caption := '';

  editNome.Text := Dados.Nome;
  EditDocumento.Text := Dados.Documento;
  editEmail.Text := Dados.Email;
  editTelefone.Text := FormatarTelefone(Dados.Telefone);
  checkAtivo.Checked := Dados.Ativo;

  editNome.ReadOnly := not Editavel;
  EditDocumento.ReadOnly := not Editavel;
  editEmail.ReadOnly := not Editavel;
  editTelefone.ReadOnly := not Editavel;

  checkAtivo.Enabled := Editavel;
  btnSalvar.Enabled := Editavel;

  { Desabilita Novo somente durante uma inclusao. }
  btnNovo.Enabled := not (Editavel and (Dados.ID = 0));

  if (Dados.ID > 0) and not Editavel then
    groupCadastro.Caption := '  Cadastro - somente leitura  '
  else
    groupCadastro.Caption := '  Cadastro  ';
end;

procedure TFrmClientes.FormCreate(Sender: TObject);
begin
  CarregarCombo;
end;

procedure TFrmClientes.GridClientesDblClick(Sender: TObject);
begin
  try
    CarregarSelecionado;
  except
    on E: Exception do
    begin
      TLog.Excecao(llError, 'Clientes.GridClientesDblClick',
        'Carregamento do cliente selecionado', E);

      ShowMessage(E.Message);
    end;
  end;
end;

procedure TFrmClientes.GridClientesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    Key := 0;
    GridClientesDblClick(Sender);
  end;
end;

procedure TFrmClientes.Inicializar(const AController: iControllerCliente;
      aNovo: Boolean = False; aClienteID: integer = 0);
begin
  if AController = nil then
    raise Exception.Create('Controller nao informado.');

  if FController <> nil then
    raise Exception.Create('Formulario ja inicializado.');

  if AClienteID < 0 then
    raise Exception.Create('Identificador de cliente invalido.');

  if ANovo and (AClienteID > 0) then
    raise Exception.Create(
      'Informe um cliente existente ou inicie um novo cadastro.');

  FController := AController;
  FUltimoClienteSalvoID := 0;

  FDataSource := TDataSource.Create(Self);
  FDataSource.AutoEdit := False;
  FDataSource.DataSet := FController.DataSet;

  gridClientes.DataSource := FDataSource;
  gridClientes.ReadOnly := True;

  gridClientes.Options :=
    (gridClientes.Options - [dgEditing, dgAlwaysShowEditor]) +
    [dgRowSelect, dgAlwaysShowSelection];

  gridClientes.OnDblClick := GridClientesDblClick;
  gridClientes.OnKeyDown := GridClientesKeyDown;

  OnCloseQuery := ConsultarFechamento;

  editNome.MaxLength := 120;
  EditDocumento.MaxLength := 20;
  editEmail.MaxLength := 120;
  editTelefone.MaxLength := 30;

  gridClientes.Columns.Clear;

  with gridClientes.Columns.Add do
  begin
    FieldName := 'ID';
    Title.Caption := '#';
    Title.Alignment := taCenter;
    Width := 40;
  end;

  with gridClientes.Columns.Add do
  begin
    FieldName := 'NOME';
    Title.Caption := 'Nome';
    Width := 200;
  end;

  with gridClientes.Columns.Add do
  begin
    FieldName := 'TELEFONE';
    Title.Caption := 'Telefone';
    Title.Alignment := taCenter;
    Width := 105;
  end;

  Pesquisar;

  if AClienteID > 0 then
  begin
    FController.Carregar(AClienteID);
    FController.DataSet.Locate('ID', AClienteID, []);
  end
  else if ANovo then
    FController.Novo;

  ExibirCliente;

  if ANovo or (AClienteID > 0) then
  begin
    if FController.PodeEditar then
      ActiveControl := editNome
    else
      ActiveControl := gridClientes;
  end
  else
    ActiveControl := editTermo;
end;

procedure TFrmClientes.Pesquisar;
var
  Campo: TCampoPesquisaCliente;
  Situacao: TSituacaoPesquisaCliente;
begin
  case cbxFiltroPesquisa.ItemIndex of
    0: Campo := pcNome;
    1: Campo := pcDocumento;
    2: Campo := pcTelefone;
    3: Campo := pcEmail;
  else
    raise EOperacaoRecusada.Create('Selecione o criterio de pesquisa.');
  end;

  case cbxFiltroSituacao.ItemIndex of
    0: Situacao := scTodos;
    1: Situacao := scAtivos;
    2: Situacao := scInativos;
  else
    raise EOperacaoRecusada.Create('Selecione a situacao.');
  end;

  FController.Pesquisar(Campo, editTermo.Text, Situacao);

  FController.DataSet.FieldByName('TELEFONE').OnGetText :=
    TelefoneGetText;
end;

function TFrmClientes.PodeDescartarEdicao: Boolean;
var
  Dados: TDadosCliente;
  Alterado: Boolean;
begin
  Result := True;

  if FController = nil then
    Exit;

  if not FController.PodeEditar then
    Exit;

  Dados := FController.Dados;

  Alterado :=
    (UpperCase(editNome.Text) <> UpperCase(Dados.Nome)) or
    (EditDocumento.Text <> Dados.Documento) or
    (LowerCase(editEmail.Text) <> LowerCase(Dados.Email)) or
    (SomenteDigitos(editTelefone.Text) <> SomenteDigitos(Dados.Telefone)) or
    (checkAtivo.Checked <> Dados.Ativo);

  if Alterado then
    Result := MessageDlg(
      'Descartar as alteracoes nao salvas?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

procedure TFrmClientes.TelefoneGetText(Sender: TField; var Text: string;
  DisplayText: Boolean);
begin
  if DisplayText then
    Text := FormatarTelefone(Sender.AsString)
  else
    Text := Sender.AsString;
end;

end.
