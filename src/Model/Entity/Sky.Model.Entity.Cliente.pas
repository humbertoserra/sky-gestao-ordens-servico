unit Sky.Model.Entity.Cliente;

interface

uses
  Sky.Model.Entity.Interfaces;

type
  TModelEntidadeCliente = class(TInterfacedObject, iCliente)
  private
    FID: Integer;
    FNome: String;
    FDocumento: String;
    FEmail: String;
    FTelefone: String;
    FDataCadastro: TDateTime;
    FAtivo: Boolean;
  public
    class function New: iCliente;
    function ID: integer; overload;
    function ID(Value: integer): iCliente; overload;
    function Nome: string; overload;
    function Nome(Value: string): iCliente; overload;
    function Documento: string; overload;
    function Documento(Value: string): iCliente; overload;
    function Email: string; overload;
    function Email(Value: string): iCliente; overload;
    function Telefone: string; overload;
    function Telefone(Value: string): iCliente; overload;
    function DataCadastro: TDateTime; overload;
    function DataCadastro(Value: TDateTime): iCliente; overload;
    function Ativo: Boolean; overload;
    function Ativo(Value: Boolean): iCliente; overload;
  end;


implementation

{ TModelEntidadeCliente }

function TModelEntidadeCliente.Ativo: Boolean;
begin
  Result := FAtivo;
end;

function TModelEntidadeCliente.Ativo(Value: Boolean): iCliente;
begin
  Result := Self;
  FAtivo := Value;
end;

function TModelEntidadeCliente.DataCadastro(Value: TDateTime): iCliente;
begin
  Result := Self;
  FDataCadastro := Value;
end;

function TModelEntidadeCliente.DataCadastro: TDateTime;
begin
  Result := FDataCadastro;
end;

function TModelEntidadeCliente.Documento: string;
begin
  Result := FDocumento;
end;

function TModelEntidadeCliente.Documento(Value: string): iCliente;
begin
  Result := Self;
  FDocumento := Value;
end;

function TModelEntidadeCliente.Email(Value: string): iCliente;
begin
  Result := Self;
  FEmail := Value;
end;

function TModelEntidadeCliente.Email: string;
begin
  Result := FEmail;
end;

function TModelEntidadeCliente.ID: integer;
begin
  Result := FID;
end;

function TModelEntidadeCliente.ID(Value: integer): iCliente;
begin
  Result := Self;
  FID := Value;
end;

class function TModelEntidadeCliente.New: iCliente;
begin
  Result := Self.Create;
end;

function TModelEntidadeCliente.Nome: string;
begin
  Result := FNome;
end;

function TModelEntidadeCliente.Nome(Value: string): iCliente;
begin
  Result := Self;
  FNome := Value;
end;

function TModelEntidadeCliente.Telefone: string;
begin
  Result := FTelefone;
end;

function TModelEntidadeCliente.Telefone(Value: string): iCliente;
begin
  Result := Self;
  FTelefone := Value;
end;

end.
