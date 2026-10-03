unit Sky.Model.DAO.OrdemServico;

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
  TModelDAOOrdemServico = class(
    TModelDAO, iDAOOrdemServico)
  private
    procedure Validar(const AOrdem: iOrdemServico);
    procedure PreencherParametros(const AOrdem: iOrdemServico);
    procedure ValidarClienteAtivo(const AClienteID: integer);
  protected
    function SQLConsulta: string; override;
    function ColunaFiltro(
      const ACampo: string;
      out ATexto: Boolean): string; override;
  public
    class function New(
      const AConexao: iConexao;
      const AConsulta: iQuery;
      const AComando: iQuery): iDAOOrdemServico;
    procedure Inserir(const AOrdem: iOrdemServico);
    procedure Atualizar(const AOrdem: iOrdemServico);
    procedure Excluir(const AID: Integer);
    procedure Bloquear(const AID: Integer);
  end;

implementation

uses
  Sky.Service.Log;

class function TModelDAOOrdemServico.New(
  const AConexao: iConexao;
  const AConsulta: iQuery;
  const AComando: iQuery): iDAOOrdemServico;
begin
  Result := Self.Create(
    AConexao, AConsulta, AComando);
end;

function TModelDAOOrdemServico.SQLConsulta: string;
begin
  Result :=
    'SELECT O.ID, O.CLIENTE_ID, ' +
    'C.NOME AS CLIENTE_NOME, ' +
    'O.DATA_ABERTURA, O.DATA_PREVISTA, ' +
    'O.DATA_FECHAMENTO, O.STATUS, ' +
    'O.DESCRICAO_PROBLEMA, O.VALOR_TOTAL, O.ATIVO ' +
    'FROM ORDEM_SERVICO O ' +
    'INNER JOIN CLIENTE C ON C.ID = O.CLIENTE_ID';
end;

procedure TModelDAOOrdemServico.Bloquear(const AID: Integer);
begin
  VerificarRegistro('ORDEM_SERVICO', AID);
end;

function TModelDAOOrdemServico.ColunaFiltro(
  const ACampo: string;
  out ATexto: Boolean): string;
begin
  Result := MapearCampo(
    ACampo,
    ['ID', 'ClienteID', 'NomeCliente',
     'DataAbertura', 'DataPrevista', 'DataFechamento',
     'Status', 'Problema', 'ValorTotal', 'Ativo'],
    ['O.ID', 'O.CLIENTE_ID', 'UPPER(C.NOME)',
     'O.DATA_ABERTURA', 'O.DATA_PREVISTA', 'O.DATA_FECHAMENTO',
     'O.STATUS', 'O.DESCRICAO_PROBLEMA', 'O.VALOR_TOTAL',
     'O.ATIVO']);

  ATexto :=
    SameText(ACampo, 'NomeCliente') or
    SameText(ACampo, 'Status') or
    SameText(ACampo, 'Problema');
end;

procedure TModelDAOOrdemServico.Validar(
  const AOrdem: iOrdemServico);
begin
  if AOrdem = nil then
    raise Exception.Create('OS nao informada.');

  ValidarID(AOrdem.ClienteID);

  if Trunc(AOrdem.DataPrevista) <
     Trunc(AOrdem.DataAbertura) then
    raise EOperacaoRecusada.Create(
      'Data prevista anterior a data de abertura.');

  if AOrdem.ValorTotal < 0 then
    raise Exception.Create(
      'Valor total nao pode ser negativo.');

  if (AOrdem.Status <> 'Aberta') and
     (AOrdem.Status <> 'Em Andamento') and
     (AOrdem.Status <> 'Concluida') and
     (AOrdem.Status <> 'Cancelada') then
    raise Exception.Create('Status de OS invalido.');

  ValidarTexto(
    AOrdem.Problema,
    'Descricao do problema',
    500,
    False);
end;

procedure TModelDAOOrdemServico.ValidarClienteAtivo(const AClienteID: integer);
begin
  ValidarID(AClienteID);
  ExigirTransacao;

  FComando.SQL('SELECT ATIVO FROM CLIENTE WHERE ID = :ID WITH LOCK');

  FComando.Parametro('ID', AClienteID);

  try
    FComando.Abrir;

    if FComando.DataSet.IsEmpty then
      raise EOperacaoRecusada.Create('Cliente nao encontrado.');

    if FComando.DataSet.FieldByName('ATIVO').AsInteger <> 1 then
      raise EOperacaoRecusada.Create(
        'Cliente inativo nao pode receber uma nova OS.');
  finally
    FComando.Fechar;
  end;
end;

procedure TModelDAOOrdemServico.PreencherParametros(
  const AOrdem: iOrdemServico);
begin
  FComando.Parametro('CLIENTE_ID', AOrdem.ClienteID);

  FComando.Parametro('DATA_ABERTURA',
    VarFromDateTime(Trunc(AOrdem.DataAbertura)));

  FComando.Parametro('DATA_PREVISTA',
    VarFromDateTime(Trunc(AOrdem.DataPrevista)));

  if AOrdem.TemDataFechamento then
    FComando.Parametro('DATA_FECHAMENTO',
      VarFromDateTime(Trunc(AOrdem.DataFechamento)))
  else
    FComando.ParametroNulo('DATA_FECHAMENTO', ftDate);

  FComando.Parametro('STATUS', AOrdem.Status);

  FComando.Parametro('DESCRICAO_PROBLEMA', AOrdem.Problema);

  FComando.Parametro('VALOR_TOTAL', AOrdem.ValorTotal);

  FComando.Parametro('ATIVO', Ord(AOrdem.Ativo));
end;

procedure TModelDAOOrdemServico.Inserir(
  const AOrdem: iOrdemServico);
var
  NovoID: Integer;
begin
  Validar(AOrdem);

  if AOrdem.ID <> 0 then
    raise Exception.Create('Uma inclusao exige OS sem ID.');

  ValidarClienteAtivo(AOrdem.ClienteID);
  NovoID := GerarID('GEN_ORDEM_SERVICO_ID');

  FComando.SQL(
    'INSERT INTO ORDEM_SERVICO ' +
    '(ID, CLIENTE_ID, DATA_ABERTURA, DATA_PREVISTA, ' +
    'DATA_FECHAMENTO, STATUS, DESCRICAO_PROBLEMA, ' +
    'VALOR_TOTAL, ATIVO) ' +
    'VALUES ' +
    '(:ID, :CLIENTE_ID, :DATA_ABERTURA, :DATA_PREVISTA, ' +
    ':DATA_FECHAMENTO, :STATUS, :DESCRICAO_PROBLEMA, ' +
    ':VALOR_TOTAL, :ATIVO)');

  FComando.Parametro('ID', NovoID);
  PreencherParametros(AOrdem);

  ExecutarComando;

  AOrdem.ID(NovoID);
end;

procedure TModelDAOOrdemServico.Atualizar(
  const AOrdem: iOrdemServico);
begin
  Validar(AOrdem);

  VerificarRegistro('ORDEM_SERVICO', AOrdem.ID);

  FComando.SQL(
    'UPDATE ORDEM_SERVICO SET ' +
    'CLIENTE_ID = :CLIENTE_ID, ' +
    'DATA_ABERTURA = :DATA_ABERTURA, ' +
    'DATA_PREVISTA = :DATA_PREVISTA, ' +
    'DATA_FECHAMENTO = :DATA_FECHAMENTO, ' +
    'STATUS = :STATUS, ' +
    'DESCRICAO_PROBLEMA = :DESCRICAO_PROBLEMA, ' +
    'VALOR_TOTAL = :VALOR_TOTAL, ' +
    'ATIVO = :ATIVO ' +
    'WHERE ID = :ID');

  FComando.Parametro('ID', AOrdem.ID);
  PreencherParametros(AOrdem);

  ExecutarComando;
end;

procedure TModelDAOOrdemServico.Excluir(
  const AID: Integer);
begin
  VerificarRegistro('ORDEM_SERVICO', AID);

  FComando.SQL(
    'UPDATE ORDEM_SERVICO SET ATIVO = 0 ' +
    'WHERE ID = :ID');

  FComando.Parametro('ID', AID);

  ExecutarComando;
end;

end.
