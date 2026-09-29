unit Sky.Model.Entity.OrdemServico;

interface

uses
  Sky.Model.Entity.Interfaces;

type
  TModelEntidadeOrdemServico = class(TInterfacedObject, iOrdemServico)
  private
    FID: Integer;
    FClienteID: Integer;
    FDataAbertura: TDateTime;
    FDataPrevista: TDateTime;
    FDataFechamento: TDateTime;
    FTemDataFechamento: Boolean;
    FProblema: string;
    FValorTotal: Currency;
    FStatus: string;
    FAtivo: Boolean;
  public
    class function New: iOrdemServico;
    function ID: Integer; overload;
    function ID(Value: Integer): iOrdemServico; overload;
    function ClienteID: Integer; overload;
    function ClienteID(Value: Integer): iOrdemServico; overload;
    function DataAbertura: TDateTime; overload;
    function DataAbertura(Value: TDateTime): iOrdemServico; overload;
    function DataPrevista: TDateTime; overload;
    function DataPrevista(Value: TDateTime): iOrdemServico; overload;
    function DataFechamento: TDateTime; overload;
    function DataFechamento(Value: TDateTime): iOrdemServico; overload;
    function TemDataFechamento: Boolean;
    function LimparDataFechamento: iOrdemServico;
    function Problema: string; overload;
    function Problema(Value: string): iOrdemServico; overload;
    function ValorTotal: Currency; overload;
    function ValorTotal(Value: Currency): iOrdemServico; overload;
    function Status: string; overload;
    function Status(Value: string): iOrdemServico; overload;
    function Ativo: Boolean; overload;
    function Ativo(Value: Boolean): iOrdemServico; overload;
  end;

implementation

class function TModelEntidadeOrdemServico.New: iOrdemServico;
begin
  Result := Self.Create;
end;

function TModelEntidadeOrdemServico.ID: Integer;
begin
  Result := FID;
end;

function TModelEntidadeOrdemServico.ID(Value: Integer): iOrdemServico;
begin
  FID := Value;
  Result := Self;
end;

function TModelEntidadeOrdemServico.ClienteID: Integer;
begin
  Result := FClienteID;
end;

function TModelEntidadeOrdemServico.ClienteID(
  Value: Integer): iOrdemServico;
begin
  FClienteID := Value;
  Result := Self;
end;

function TModelEntidadeOrdemServico.DataAbertura: TDateTime;
begin
  Result := FDataAbertura;
end;

function TModelEntidadeOrdemServico.DataAbertura(
  Value: TDateTime): iOrdemServico;
begin
  FDataAbertura := Value;
  Result := Self;
end;

function TModelEntidadeOrdemServico.DataPrevista: TDateTime;
begin
  Result := FDataPrevista;
end;

function TModelEntidadeOrdemServico.DataPrevista(
  Value: TDateTime): iOrdemServico;
begin
  FDataPrevista := Value;
  Result := Self;
end;

function TModelEntidadeOrdemServico.DataFechamento: TDateTime;
begin
  Result := FDataFechamento;
end;

function TModelEntidadeOrdemServico.DataFechamento(
  Value: TDateTime): iOrdemServico;
begin
  FDataFechamento := Value;
  FTemDataFechamento := True;
  Result := Self;
end;

function TModelEntidadeOrdemServico.TemDataFechamento: Boolean;
begin
  Result := FTemDataFechamento;
end;

function TModelEntidadeOrdemServico.LimparDataFechamento: iOrdemServico;
begin
  FDataFechamento := 0;
  FTemDataFechamento := False;
  Result := Self;
end;

function TModelEntidadeOrdemServico.Problema: string;
begin
  Result := FProblema;
end;

function TModelEntidadeOrdemServico.Problema(
  Value: string): iOrdemServico;
begin
  FProblema := Value;
  Result := Self;
end;

function TModelEntidadeOrdemServico.ValorTotal: Currency;
begin
  Result := FValorTotal;
end;

function TModelEntidadeOrdemServico.ValorTotal(
  Value: Currency): iOrdemServico;
begin
  FValorTotal := Value;
  Result := Self;
end;

function TModelEntidadeOrdemServico.Status: string;
begin
  Result := FStatus;
end;

function TModelEntidadeOrdemServico.Status(
  Value: string): iOrdemServico;
begin
  FStatus := Value;
  Result := Self;
end;

function TModelEntidadeOrdemServico.Ativo: Boolean;
begin
  Result := FAtivo;
end;

function TModelEntidadeOrdemServico.Ativo(
  Value: Boolean): iOrdemServico;
begin
  FAtivo := Value;
  Result := Self;
end;

end.
