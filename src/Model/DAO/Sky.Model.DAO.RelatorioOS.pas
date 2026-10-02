unit Sky.Model.DAO.RelatorioOS;

interface

uses
  System.SysUtils,
  System.Variants,
  Data.DB,
  Sky.Model.Connection.Interfaces,
  Sky.Model.DAO.Interfaces;

type
  TModelDAORelatorioOS = class(TInterfacedObject, iDAORelatorioOS)
  private
    FConsulta: iQuery;
  public
    constructor Create(const AConsulta: iQuery);
    class function New(const AConsulta: iQuery): iDAORelatorioOS;
    procedure Pesquisar(
      const AFiltrarPeriodo: Boolean;
      const ADataInicial, ADataFinal: TDateTime;
      const ANomeCliente: string;
      const AStatus: array of string);
    function DataSet: TDataSet;
  end;

implementation

{ TModelDAORelatorioOS }

constructor TModelDAORelatorioOS.Create(const AConsulta: iQuery);
begin
  inherited Create;

  if AConsulta = nil then
    raise Exception.Create(
      'Consulta do relatorio nao informada.');

  FConsulta := AConsulta;
end;

class function TModelDAORelatorioOS.New(const AConsulta: iQuery):
  iDAORelatorioOS;
begin
  Result := Self.Create(aConsulta);
end;

function TModelDAORelatorioOS.DataSet: TDataSet;
begin
  Result := FConsulta.DataSet;
end;

procedure TModelDAORelatorioOS.Pesquisar(const AFiltrarPeriodo: Boolean;
  const ADataInicial, ADataFinal: TDateTime; const ANomeCliente: string;
  const AStatus: array of string);
var
  TextoSQL: string;
  NomeCliente: string;
  I: Integer;
begin
  if AFiltrarPeriodo then
    if Trunc(ADataInicial) > Trunc(ADataFinal) then
      raise Exception.Create(
        'Data inicial posterior a data final.');

  for I := 0 to High(AStatus) do
    if (AStatus[I] <> 'Aberta') and
       (AStatus[I] <> 'Em Andamento') and
       (AStatus[I] <> 'Concluida') and
       (AStatus[I] <> 'Cancelada') then
      raise Exception.Create(
        'Status do relatorio invalido.');

  NomeCliente := Trim(ANomeCliente);

  TextoSQL :=
    'SELECT O.ID, O.CLIENTE_ID, O.CLIENTE_NOME, ' +
    'O.DATA_ABERTURA, O.DATA_PREVISTA, ' +
    'O.DATA_FECHAMENTO, O.STATUS, O.VALOR_TOTAL, ' +
    'O.EM_ATRASO ' +
    'FROM VW_OS_RESUMO O ' +
    'WHERE 1 = 1';

  if AFiltrarPeriodo then
    TextoSQL := TextoSQL +
      ' AND O.DATA_ABERTURA >= :DATA_INICIAL' +
      ' AND O.DATA_ABERTURA <= :DATA_FINAL';

  if NomeCliente <> '' then
    TextoSQL := TextoSQL +
      ' AND O.CLIENTE_NOME CONTAINING :NOME_CLIENTE';

  if Length(AStatus) > 0 then
  begin
    TextoSQL := TextoSQL + ' AND O.STATUS IN (';

    for I := 0 to High(AStatus) do
    begin
      if I > 0 then
        TextoSQL := TextoSQL + ', ';

      TextoSQL := TextoSQL + ':STATUS_' + IntToStr(I);
    end;

    TextoSQL := TextoSQL + ')';
  end;

  TextoSQL := TextoSQL +
    ' ORDER BY O.STATUS, O.DATA_ABERTURA, O.ID';

  FConsulta.SQL(TextoSQL);

  if AFiltrarPeriodo then
  begin
    FConsulta.Parametro(
      'DATA_INICIAL',
      VarFromDateTime(Trunc(ADataInicial)));

    FConsulta.Parametro(
      'DATA_FINAL',
      VarFromDateTime(Trunc(ADataFinal)));
  end;

  if NomeCliente <> '' then
    FConsulta.Parametro('NOME_CLIENTE', NomeCliente);

  for I := 0 to High(AStatus) do
    FConsulta.Parametro(
      'STATUS_' + IntToStr(I), AStatus[I]);

  FConsulta.Abrir;
end;

end.
