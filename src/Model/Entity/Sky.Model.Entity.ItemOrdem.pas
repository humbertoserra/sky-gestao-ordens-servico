unit Sky.Model.Entity.ItemOrdem;

interface

uses
  Sky.Model.Entity.Interfaces;

type
  TModelEntidadeItemOrdem = class(TInterfacedObject, iItemOrdem)
  private
    FID: Integer;
    FOrdemID: Integer;
    FDescricao: string;
    FQuantidade: Double;
    FValorUnitario: currency;
    FAtivo: Boolean;
  public
    class function New: iItemOrdem;
    function ID: integer; overload;
    function ID(Value: integer): iItemOrdem; overload;
    function OrdemID: integer; overload;
    function OrdemID(Value: integer): iItemOrdem; overload;
    function Descricao: string; overload;
    function Descricao(Value: string): iItemOrdem; overload;
    function Quantidade: Double; overload;
    function Quantidade(Value: Double): iItemOrdem; overload;
    function ValorUnitario: currency; overload;
    function ValorUnitario(Value: currency): iItemOrdem; overload;
    function Ativo: Boolean; overload;
    function Ativo(Value: Boolean): iItemOrdem; overload;
  end;

implementation

{ TModelEntidadeItemOrdem }

function TModelEntidadeItemOrdem.ID: integer;
begin
  Result := FID;
end;

function TModelEntidadeItemOrdem.Ativo: Boolean;
begin
  Result := FAtivo;
end;

function TModelEntidadeItemOrdem.Ativo(Value: Boolean): iItemOrdem;
begin
  Result := Self;
  FAtivo := Value;
end;

function TModelEntidadeItemOrdem.Descricao: string;
begin
  Result := FDescricao;
end;

function TModelEntidadeItemOrdem.Descricao(Value: string): iItemOrdem;
begin
  Result := Self;
  FDescricao := Value;
end;

function TModelEntidadeItemOrdem.ID(Value: integer): iItemOrdem;
begin
  Result := Self;
  FID := Value;
end;

class function TModelEntidadeItemOrdem.New: iItemOrdem;
begin
  Result := Self.Create;
end;

function TModelEntidadeItemOrdem.OrdemID: integer;
begin
  Result := FOrdemID;
end;

function TModelEntidadeItemOrdem.OrdemID(Value: integer): iItemOrdem;
begin
  Result := Self;
  FOrdemID := Value;
end;

function TModelEntidadeItemOrdem.Quantidade(Value: Double): iItemOrdem;
begin
  Result := Self;
  FQuantidade := Value;
end;

function TModelEntidadeItemOrdem.Quantidade: Double;
begin
  Result := FQuantidade;
end;

function TModelEntidadeItemOrdem.ValorUnitario: currency;
begin
  Result := FValorUnitario;
end;

function TModelEntidadeItemOrdem.ValorUnitario(Value: currency): iItemOrdem;
begin
  Result := Self;
  FValorUnitario := Value;
end;

end.
