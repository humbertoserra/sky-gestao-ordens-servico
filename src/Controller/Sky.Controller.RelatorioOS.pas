unit Sky.Controller.RelatorioOS;

interface

uses
  System.SysUtils,
  Data.DB,
  Sky.Controller.Interfaces,
  Sky.Model.DAO.Interfaces;

type
  TControllerRelatorioOS = class(TInterfacedObject, iControllerRelatoriosOS)
  private
    FDAO: iDAORelatorioOS;
  public
    constructor Create(const ADAO: iDAORelatorioOS);
    class function New(const ADAO: iDAORelatorioOS): iControllerRelatoriosOS;
    procedure Pesquisar(const aFiltro: TFiltroRelatoriosOS);
    function DataSet: TDataSet;
  end;

implementation

{ TControllerRelatorioOS }

constructor TControllerRelatorioOS.Create(const ADAO: iDAORelatorioOS);
begin
  inherited Create;

  if ADAO = nil then
    raise Exception.Create(
      'DAO do relatorio nao informado.');

  FDAO := ADAO;
end;

class function TControllerRelatorioOS.New(const ADAO: iDAORelatorioOS):
  iControllerRelatoriosOS;
begin
  Result := Self.Create(ADAO);
end;

function TControllerRelatorioOS.DataSet: TDataSet;
begin
  Result := FDAO.DataSet;
end;

procedure TControllerRelatorioOS.Pesquisar(const aFiltro: TFiltroRelatoriosOS);
var
  Status: TStatusOrdemServico;
  StatusConsulta: array of string;
  TextoStatus: string;
  Indice: Integer;
begin
  if AFiltro.FiltraPeriodo then
    if Trunc(AFiltro.DataInicial) > Trunc(AFiltro.DataFinal) then
      raise Exception.Create(
        'Data inicial posterior a data final.');

  SetLength(StatusConsulta, 0);

  for Status := Low(TStatusOrdemServico) to
                High(TStatusOrdemServico) do
  begin
    if not (Status in AFiltro.StatusSelecionados) then
      Continue;

    case Status of
      soAberta:
        TextoStatus := 'Aberta';
      soEmAndamento:
        TextoStatus := 'Em Andamento';
      soConcluida:
        TextoStatus := 'Concluida';
      soCancelada:
        TextoStatus := 'Cancelada';
    else
      raise Exception.Create('Status do relatorio invalido.');
    end;

    Indice := Length(StatusConsulta);
    SetLength(StatusConsulta, Indice + 1);
    StatusConsulta[Indice] := TextoStatus;
  end;

  FDAO.Pesquisar(
    AFiltro.FiltraPeriodo,
    AFiltro.DataInicial,
    AFiltro.DataFinal,
    Trim(AFiltro.NomeCliente),
    StatusConsulta);
end;

end.
