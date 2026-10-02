unit Sky.Controller.Clientes;

interface

uses
  System.SysUtils,
  Data.DB, Sky.Controller.Interfaces,
  Sky.Model.Entity.Interfaces,
  Sky.Model.DAO.Interfaces,
  Sky.Model.Connection.Interfaces;

type
  TControllerCliente = class(TInterfacedObject, iControllerCliente)
  private
    FConexao: iConexao;
    FDAOListagem: iDAOCliente;
    FDAOCadastro: iDAOCliente;
    FCliente: iCliente;

    procedure VerificarConexao;
    function NormalizarTelefone(const ATelefone: string): string;
  public
    constructor Create(const aConexao:iConexao;
                       const aDAOListagem: iDAOCliente;
                       const aDAOCadastro:iDAOCliente);
    destructor Destroy; override;
    class function New(const aConexao:iConexao;
                       const aDAOListagem: iDAOCliente;
                       const aDAOCadastro:iDAOCliente): iControllerCliente;
    procedure Pesquisar(
      ACampo: TCampoPesquisaCliente;
      const ATermo: string;
      ASituacao: TSituacaoPesquisaCliente);
    procedure Novo;
    procedure Carregar(const AID: Integer);
    function Dados: TDadosCliente;
    function PodeEditar: Boolean;
    procedure Salvar(const ADados: TDadosCliente);
    procedure Limpar;
    function DataSet: TDataSet;
  end;

implementation

{ TControllerCliente }

uses
  Sky.Model.Entity,
  Sky.Service.Log;

procedure TControllerCliente.Carregar(const AID: Integer);
var
  Consulta: TDataSet;
  Cliente: iCliente;
begin
  VerificarConexao;

  FDAOCadastro.BuscarPorId(AID);
  Consulta := FDAOCadastro.DataSet;

  if Consulta = nil then
    raise Exception.Create('Consulta de cliente indisponivel.');

  if not Consulta.Active then
    raise Exception.Create('Consulta de cliente fechada.');

  if Consulta.IsEmpty then
    raise EOperacaoRecusada.Create('Cliente nao encontrado.');

  Cliente := TEntidade.New.Cliente;

  Cliente.ID(
    Consulta.FieldByName('ID').AsInteger);

  Cliente.Nome(
    Consulta.FieldByName('NOME').AsString);

  Cliente.Documento(
    Consulta.FieldByName('DOCUMENTO').AsString);

  Cliente.Email(
    Consulta.FieldByName('EMAIL').AsString);

  Cliente.Telefone(
    Consulta.FieldByName('TELEFONE').AsString);

  Cliente.DataCadastro(
    Consulta.FieldByName('DATA_CADASTRO').AsDateTime);

  Cliente.Ativo(
    Consulta.FieldByName('ATIVO').AsInteger = 1);

  FCliente := Cliente;
end;

constructor TControllerCliente.Create(const aConexao:iConexao;
                                      const aDAOListagem: iDAOCliente;
                                      const aDAOCadastro:iDAOCliente);
begin
  inherited Create;

  if AConexao = nil then
    raise Exception.Create('Conexao nao informada.');

  if ADAOListagem = nil then
    raise Exception.Create('DAO de listagem nao informado.');

  if ADAOCadastro = nil then
    raise Exception.Create('DAO de cadastro nao informado.');

  if ADAOListagem = ADAOCadastro then
    raise Exception.Create(
      'Listagem e cadastro devem utilizar DAOs distintos.');

  FConexao := AConexao;
  FDAOListagem := ADAOListagem;
  FDAOCadastro := ADAOCadastro;
end;

destructor TControllerCliente.Destroy;
begin

  inherited;
end;

procedure TControllerCliente.Limpar;
begin
  FCliente := nil;
end;

class function TControllerCliente.New(const aConexao:iConexao;
                       const aDAOListagem: iDAOCliente;
                       const aDAOCadastro:iDAOCliente): iControllerCliente;
begin
  Result := Self.Create(aConexao, aDAOListagem, aDAOCadastro);
end;

function TControllerCliente.Dados: TDadosCliente;
begin
  Result.ID := 0;
  Result.Nome := '';
  Result.Documento := '';
  Result.Email := '';
  Result.Telefone := '';
  Result.Ativo := False;

  if FCliente = nil then
    Exit;

  Result.ID := FCliente.ID;
  Result.Nome := FCliente.Nome;
  Result.Documento := FCliente.Documento;
  Result.Email := FCliente.Email;
  Result.Telefone := FCliente.Telefone;
  Result.Ativo := FCliente.Ativo;
end;

function TControllerCliente.DataSet: TDataSet;
begin
  Result := FDAOListagem.DataSet;
end;

procedure TControllerCliente.Pesquisar(
      ACampo: TCampoPesquisaCliente;
      const ATermo: string;
      ASituacao: TSituacaoPesquisaCliente);
var
  Filtros: TFiltros;
  Campo: string;
  Termo: string;
  Indice: Integer;
begin
  VerificarConexao;
  case ACampo of
    pcNome: Campo := 'Nome';
    pcDocumento: Campo := 'Documento';
    pcTelefone: Campo := 'Telefone';
    pcEmail: Campo := 'Email';
  else
    raise Exception.Create('Criterio de pesquisa invalido.');
  end;

  SetLength(Filtros, 0);
  Termo := Trim(ATermo);

  case ACampo of
    pcNome:
      Termo := UpperCase(Termo);

    pcTelefone:
      if Termo <> '' then
        Termo := NormalizarTelefone(Termo);

    pcEmail:
      Termo := LowerCase(Termo);
  end;

  if Termo <> '' then
  begin
    SetLength(Filtros, 1);

    Filtros[0].Campo := Campo;

    if ACampo = pcNome then
      Filtros[0].Operador := ofContem
    else
      Filtros[0].Operador := ofIgual;

    Filtros[0].Valor := Termo;
  end;

  case ASituacao of
    scTodos:
      begin
        { Nao restringe a situacao. }
      end;

    scAtivos, scInativos:
      begin
        Indice := Length(Filtros);
        SetLength(Filtros, Indice + 1);

        Filtros[Indice].Campo := 'Ativo';
        Filtros[Indice].Operador := ofIgual;

        if ASituacao = scAtivos then
          Filtros[Indice].Valor := 1
        else
          Filtros[Indice].Valor := 0;
      end;
  else
    raise Exception.Create('Situacao de pesquisa invalida.');
  end;

  FDAOListagem.BuscarPor(Filtros);
end;

function TControllerCliente.PodeEditar: Boolean;
begin
  Result := False;

  if FCliente = nil then
    Exit;

  Result := FCliente.ID <> 1;
end;

function TControllerCliente.NormalizarTelefone(const ATelefone: string): string;
var
  I: Integer;
  Digito: Char;
begin
  Result := '';

  for I := 1 to Length(ATelefone) do
  begin
    Digito := ATelefone[I];

    if (Digito >= '0') and (Digito <= '9') then
      Result := Result + Digito
    else if not (
      (Digito = ' ') or
      (Digito = '(') or
      (Digito = ')') or
      (Digito = '-')
    ) then
      raise Exception.Create(
        'Telefone deve conter somente numeros e a formatacao permitida.');
  end;

  if Result = '' then
    Exit;

  if (Length(Result) <> 10) and
     (Length(Result) <> 11) then
    raise EOperacaoRecusada.Create(
      'Informe o telefone com DDD, contendo 10 ou 11 digitos.');

  if Length(Result) = 11 then
    if Result[3] <> '9' then
      raise EOperacaoRecusada.Create(
        'O celular deve iniciar com 9 apos o DDD.');
end;

procedure TControllerCliente.Novo;
var
  Cliente: iCliente;
begin
  Cliente := TEntidade.New.Cliente;

  Cliente.ID(0);
  Cliente.DataCadastro(Now);
  Cliente.Ativo(True);

  FCliente := Cliente;
end;

procedure TControllerCliente.Salvar(const aDados: TDadosCliente);
var
  ClienteGravacao: iCliente;
begin
  if FCliente = nil then
    raise EOperacaoRecusada.Create(
      'Selecione um cliente ou inicie um novo cadastro.');

  if not PodeEditar then
    raise EOperacaoRecusada.Create(
      'O cliente CLIENTE NAO IDENTIFICADO nao pode ser alterado.');

  if ADados.ID <> FCliente.ID then
    raise Exception.Create(
      'Os dados nao correspondem ao cliente em manutencao.');

  VerificarConexao;

  if FConexao.EmTransacao then
    raise Exception.Create(
      'Existe uma transacao em andamento.');

  ClienteGravacao := TEntidade.New.Cliente;

  { Identificacao e data permanecem sob controle do controller. }
  ClienteGravacao.ID(FCliente.ID);
  ClienteGravacao.DataCadastro(FCliente.DataCadastro);

  ClienteGravacao.Nome(UpperCase(ADados.Nome));
  ClienteGravacao.Documento(ADados.Documento);
  ClienteGravacao.Email(LowerCase(ADados.Email));
  ClienteGravacao.Telefone(NormalizarTelefone(ADados.Telefone));
  ClienteGravacao.Ativo(ADados.Ativo);

  FConexao.IniciarTransacao;
  try
    if ClienteGravacao.ID = 0 then
      FDAOCadastro.Inserir(ClienteGravacao)
    else
      FDAOCadastro.Atualizar(ClienteGravacao);

    FConexao.ConfirmarTransacao;
  except
    on E: Exception do
    begin
      try
        if FConexao.EmTransacao then
          FConexao.DesfazerTransacao;
      except
        on ERollback: Exception do
          raise Exception.CreateFmt(
            'Falha ao salvar: %s. Falha ao desfazer: %s.',
            [E.Message, ERollback.Message]);
      end;

      raise;
    end;
  end;

  FCliente := ClienteGravacao;
  TLog.Registrar(llInfo, 'Cliente.Salvar', 'CLIENTE_ID=' +
    IntToStr(FCliente.ID), 'Cliente Gravado');
end;

procedure TControllerCliente.VerificarConexao;
begin
  if not FConexao.Conectada then
    raise Exception.Create('Conexao fechada.');
end;

end.
