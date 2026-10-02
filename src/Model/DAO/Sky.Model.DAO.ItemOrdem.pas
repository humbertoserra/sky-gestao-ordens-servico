unit Sky.Model.DAO.ItemOrdem;

interface

uses
  System.SysUtils,
  Sky.Model.DAO,
  Sky.Model.DAO.Interfaces,
  Sky.Model.Entity.Interfaces,
  Sky.Model.Connection.Interfaces;

type
  TModelDAOItemOrdem = class(
    TModelDAO, iDAOItemOrdem)
  private
    procedure Validar(const AItem: iItemOrdem);
    procedure PreencherParametros(const AItem: iItemOrdem);
  protected
    function SQLConsulta: string; override;

    function ColunaFiltro(const ACampo: string;
      out ATexto: Boolean): string; override;
  public
    class function New(
      const AConexao: iConexao;
      const AConsulta: iQuery;
      const AComando: iQuery): iDAOItemOrdem;

    procedure Inserir(const AItem: iItemOrdem);
    procedure Atualizar(const AItem: iItemOrdem);
    procedure Excluir(const AID: Integer);
  end;

implementation

uses
  Sky.Service.Log;

class function TModelDAOItemOrdem.New(
  const AConexao: iConexao;
  const AConsulta: iQuery;
  const AComando: iQuery): iDAOItemOrdem;
begin
  Result := Self.Create(AConexao, AConsulta, AComando);
end;

function TModelDAOItemOrdem.SQLConsulta: string;
begin
  Result :=
    'SELECT I.ID, I.ORDEM_ID, I.DESCRICAO, ' +
    'I.QUANTIDADE, I.VALOR_UNITARIO, I.ATIVO ' +
    'FROM ITEM_ORDEM I';
end;

function TModelDAOItemOrdem.ColunaFiltro(
  const ACampo: string;
  out ATexto: Boolean): string;
begin
  Result := MapearCampo(
    ACampo,
    ['ID', 'OrdemID', 'Descricao',
     'Quantidade', 'ValorUnitario', 'Ativo'],
    ['I.ID', 'I.ORDEM_ID', 'I.DESCRICAO',
     'I.QUANTIDADE', 'I.VALOR_UNITARIO', 'I.ATIVO']);

  ATexto := SameText(ACampo, 'Descricao');
end;

procedure TModelDAOItemOrdem.Validar(
  const AItem: iItemOrdem);
begin
  if AItem = nil then
    raise Exception.Create('Item nao informado.');

  ValidarID(AItem.OrdemID);

  ValidarTexto(
    AItem.Descricao,
    'Descricao do item',
    200,
    True);

  if not (AItem.Quantidade > 0) then
    raise EOperacaoRecusada.Create(
      'Quantidade deve ser maior que zero.');

  if AItem.ValorUnitario < 0 then
    raise EOperacaoRecusada.Create(
      'Valor unitario nao pode ser negativo.');
end;

procedure TModelDAOItemOrdem.PreencherParametros(
  const AItem: iItemOrdem);
begin
  FComando.Parametro('ORDEM_ID', AItem.OrdemID);
  FComando.Parametro('DESCRICAO', AItem.Descricao);
  FComando.Parametro('QUANTIDADE', AItem.Quantidade);
  FComando.Parametro('VALOR_UNITARIO', AItem.ValorUnitario);
  FComando.Parametro('ATIVO', Ord(AItem.Ativo));
end;

procedure TModelDAOItemOrdem.Inserir(
  const AItem: iItemOrdem);
var
  NovoID: Integer;
begin
  Validar(AItem);

  if AItem.ID <> 0 then
    raise Exception.Create(
      'Uma inclusao exige item sem ID.');

  NovoID := GerarID('GEN_ITEM_ORDEM_ID');

  FComando.SQL(
    'INSERT INTO ITEM_ORDEM ' +
    '(ID, ORDEM_ID, DESCRICAO, QUANTIDADE, ' +
    'VALOR_UNITARIO, ATIVO) ' +
    'VALUES ' +
    '(:ID, :ORDEM_ID, :DESCRICAO, :QUANTIDADE, ' +
    ':VALOR_UNITARIO, :ATIVO)');

  FComando.Parametro('ID', NovoID);
  PreencherParametros(AItem);

  ExecutarComando;

  AItem.ID(NovoID);
end;

procedure TModelDAOItemOrdem.Atualizar(
  const AItem: iItemOrdem);
begin
  Validar(AItem);

  VerificarRegistro('ITEM_ORDEM', AItem.ID);

  FComando.SQL(
    'UPDATE ITEM_ORDEM SET ' +
    'ORDEM_ID = :ORDEM_ID, ' +
    'DESCRICAO = :DESCRICAO, ' +
    'QUANTIDADE = :QUANTIDADE, ' +
    'VALOR_UNITARIO = :VALOR_UNITARIO, ' +
    'ATIVO = :ATIVO ' +
    'WHERE ID = :ID');

  FComando.Parametro('ID', AItem.ID);
  PreencherParametros(AItem);

  ExecutarComando;
end;

procedure TModelDAOItemOrdem.Excluir(
  const AID: Integer);
begin
  VerificarRegistro('ITEM_ORDEM', AID);

  FComando.SQL(
    'DELETE FROM ITEM_ORDEM WHERE ID = :ID');

  FComando.Parametro('ID', AID);

  ExecutarComando;
end;

end.
