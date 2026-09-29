unit Sky.Model.Entity;

interface

uses
  Sky.Model.Entity.Interfaces;

type
  TEntidade = class(TInterfacedObject, iEntidade)
  private
  public
    class function New: iEntidade;
    function Cliente: iCliente;
    function OrdemServico: iOrdemServico;
    function ItemOrdem: iItemOrdem;
  end;

implementation

{ TEntidade }

uses
  Sky.Model.Entity.Cliente,
  Sky.Model.Entity.ItemOrdem,
  Sky.Model.Entity.OrdemServico;

function TEntidade.Cliente: iCliente;
begin
  Result := TModelEntidadeCliente.New;
end;

function TEntidade.ItemOrdem: iItemOrdem;
begin
  Result := TModelEntidadeItemOrdem.New;
end;

class function TEntidade.New: iEntidade;
begin
  Result := Self.Create;
end;

function TEntidade.OrdemServico: iOrdemServico;
begin
  Result := TModelEntidadeOrdemServico.New;
end;

end.
