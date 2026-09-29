unit Sky.Model.DAO.Cliente;

interface

uses
  System.SysUtils,
  System.Variants,
  Data.DB,
  Sky.Model.DAO,
  Sky.Model.DAO.Interfaces,
  Sky.Model.Entity.Interfaces,
  Sky.Model.Connection.Interfaces;

type
  TModelDAOCliente = class(TModelDAO, iDAOCliente)
  private
    procedure Validar(const ACliente: iCliente);
    procedure ProtegerCliente(const AID: Integer);

    procedure VerificarDesativacao(
      const AID: Integer);

    procedure PreencherParametros(
      const ACliente: iCliente);
  protected
    function SQLConsulta: string; override;

    function ColunaFiltro(
      const ACampo: string;
      out ATexto: Boolean): string; override;
  public
    class function New(
      const AConexao: iConexao;
      const AConsulta: iQuery;
      const AComando: iQuery): iDAOCliente;

    procedure Inserir(const ACliente: iCliente);
    procedure Atualizar(const ACliente: iCliente);
    procedure Excluir(const AID: Integer);
  end;

implementation

class function TModelDAOCliente.New(
  const AConexao: iConexao;
  const AConsulta: iQuery;
  const AComando: iQuery): iDAOCliente;
begin
  Result := Self.Create(
    AConexao, AConsulta, AComando);
end;

function TModelDAOCliente.SQLConsulta: string;
begin
  Result :=
    'SELECT C.ID, C.NOME, C.DOCUMENTO, C.EMAIL, ' +
    'C.TELEFONE, C.DATA_CADASTRO, C.ATIVO ' +
    'FROM CLIENTE C';
end;

function TModelDAOCliente.ColunaFiltro(
  const ACampo: string;
  out ATexto: Boolean): string;
begin
  Result := MapearCampo(
    ACampo,
    ['ID', 'Nome', 'Documento', 'Email',
     'Telefone', 'DataCadastro', 'Ativo'],
    ['C.ID', 'UPPER(C.NOME)', 'C.DOCUMENTO', 'LOWER(C.EMAIL)',
     'C.TELEFONE', 'C.DATA_CADASTRO', 'C.ATIVO']);

  ATexto :=
    SameText(ACampo, 'Nome') or
    SameText(ACampo, 'Documento') or
    SameText(ACampo, 'Email') or
    SameText(ACampo, 'Telefone');
end;

procedure TModelDAOCliente.Validar(
  const ACliente: iCliente);
begin
  if ACliente = nil then
    raise Exception.Create('Cliente nao informado.');

  ValidarTexto(ACliente.Nome, 'Nome', 120, True);
  ValidarTexto(ACliente.Documento, 'Documento', 20, False);
  ValidarTexto(ACliente.Email, 'Email', 120, False);
  ValidarTexto(ACliente.Telefone, 'Telefone', 30, False);
end;

procedure TModelDAOCliente.ProtegerCliente(
  const AID: Integer);
begin
  ValidarID(AID);

  if AID = 1 then
    raise Exception.Create(
      'O cliente CLIENTE NAO IDENTIFICADO nao pode ser alterado.');
end;

procedure TModelDAOCliente.VerificarDesativacao(
  const AID: Integer);
begin
  FComando.SQL(
    'SELECT FIRST 1 ID FROM ORDEM_SERVICO ' +
    'WHERE CLIENTE_ID = :CLIENTE_ID ' +
    'AND ATIVO = 1 ' +
    'AND STATUS IN (''Aberta'', ''Em Andamento'')');

  FComando.Parametro('CLIENTE_ID', AID);

  try
    FComando.Abrir;

    if not FComando.DataSet.IsEmpty then
      raise Exception.Create(
        'Cliente possui OS ativa aberta ou em andamento.');
  finally
    FComando.Fechar;
  end;
end;

procedure TModelDAOCliente.PreencherParametros(
  const ACliente: iCliente);
begin
  FComando.Parametro('NOME', ACliente.Nome);
  FComando.Parametro('DOCUMENTO', ACliente.Documento);
  FComando.Parametro('EMAIL', ACliente.Email);
  FComando.Parametro('TELEFONE', ACliente.Telefone);
  FComando.Parametro('ATIVO', Ord(ACliente.Ativo));

  FComando.Parametro(
    'DATA_CADASTRO',
    VarFromDateTime(ACliente.DataCadastro));
end;

procedure TModelDAOCliente.Inserir(
  const ACliente: iCliente);
var
  NovoID: Integer;
begin
  Validar(ACliente);

  if ACliente.ID <> 0 then
    raise Exception.Create(
      'Uma inclusao exige cliente sem ID.');

  NovoID := GerarID('GEN_CLIENTE_ID');

  if NovoID = 1 then
    raise Exception.Create(
      'O cliente 1 e seu generator devem ser preparados no banco.');

  FComando.SQL(
    'INSERT INTO CLIENTE ' +
    '(ID, NOME, DOCUMENTO, EMAIL, TELEFONE, ' +
    'DATA_CADASTRO, ATIVO) ' +
    'VALUES ' +
    '(:ID, :NOME, :DOCUMENTO, :EMAIL, :TELEFONE, ' +
    ':DATA_CADASTRO, :ATIVO)');

  FComando.Parametro('ID', NovoID);
  PreencherParametros(ACliente);

  ExecutarComando;

  ACliente.ID(NovoID);
end;

procedure TModelDAOCliente.Atualizar(
  const ACliente: iCliente);
begin
  if ACliente = nil then
    raise Exception.Create('Cliente nao informado.');

  ProtegerCliente(ACliente.ID);
  Validar(ACliente);

  VerificarRegistro('CLIENTE', ACliente.ID);

  if not ACliente.Ativo then
    VerificarDesativacao(ACliente.ID);

  FComando.SQL(
    'UPDATE CLIENTE SET ' +
    'NOME = :NOME, ' +
    'DOCUMENTO = :DOCUMENTO, ' +
    'EMAIL = :EMAIL, ' +
    'TELEFONE = :TELEFONE, ' +
    'DATA_CADASTRO = :DATA_CADASTRO, ' +
    'ATIVO = :ATIVO ' +
    'WHERE ID = :ID AND ID <> 1');

  FComando.Parametro('ID', ACliente.ID);
  PreencherParametros(ACliente);

  ExecutarComando;
end;

procedure TModelDAOCliente.Excluir(
  const AID: Integer);
begin
  ProtegerCliente(AID);

  VerificarRegistro('CLIENTE', AID);
  VerificarDesativacao(AID);

  FComando.SQL(
    'UPDATE CLIENTE SET ATIVO = 0 ' +
    'WHERE ID = :ID AND ID <> 1');

  FComando.Parametro('ID', AID);

  ExecutarComando;
end;

end.
