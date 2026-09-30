unit Sky.Model.Connection.MemTable.FireDAC;

interface

uses
  System.SysUtils,
  System.Classes,
  Sky.Model.Connection.Interfaces,
  Data.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TModelMemTableFireDAC = class(TInterfacedObject, iMemTable)
  private
    FMemTable: TFDMemTable;
    constructor Create;
  public
    destructor Destroy; override;
    class function New: iMemTable;
    function DefinirCampo(const aNome: string; aTipo: TFieldType;
      const aTamanho: Integer = 0;
      const aObrigatorio: Boolean = False): iMemTable;
    procedure Criar;
    procedure Limpar;
    function DataSet: TDataSet;
  end;

implementation

{ TModelMemTableFireDAC }

constructor TModelMemTableFireDAC.Create;
begin
  inherited Create;
  FMemTable := TFDMemTable.Create(nil);
end;

destructor TModelMemTableFireDAC.Destroy;
begin
  FMemTable.Free;
  inherited;
end;

class function TModelMemTableFireDAC.New: iMemTable;
begin
  Result := Self.Create;
end;

procedure TModelMemTableFireDAC.Criar;
begin
  if FMemTable.Active then
    raise Exception.Create(
      'A tabela em memoria ja esta aberta.');

  if FMemTable.FieldDefs.Count = 0 then
    raise Exception.Create(
      'Defina os campos antes de criar a tabela em memoria.');

  FMemTable.CreateDataSet;
end;

function TModelMemTableFireDAC.DataSet: TDataSet;
begin
  Result := FMemTable;
end;

function TModelMemTableFireDAC.DefinirCampo(const aNome: string;
  aTipo: TFieldType; const aTamanho: Integer;
  const aObrigatorio: Boolean): iMemTable;
var
  Nome: string;
  I: Integer;
begin
  if FMemTable.Active then
    raise Exception.Create(
      'Os campos devem ser definidos antes de criar a tabela.');

  Nome := Trim(ANome);

  if Nome = '' then
    raise Exception.Create('Informe o nome do campo.');

  if not (ATipo in [ftInteger, ftString, ftFloat, ftCurrency]) then
    raise Exception.Create(
      'Tipo de campo nao suportado pela tabela em memoria.');

  if ATipo = ftString then
  begin
    if ATamanho <= 0 then
      raise Exception.Create(
        'Informe um tamanho maior que zero para o campo de texto.');
  end
  else if ATamanho <> 0 then
    raise Exception.Create(
      'O tamanho deve ser zero para campos numericos.');

  for I := 0 to FMemTable.FieldDefs.Count - 1 do
    if SameText(FMemTable.FieldDefs[I].Name, Nome) then
      raise Exception.CreateFmt(
        'O campo %s ja foi definido.', [Nome]);

  FMemTable.FieldDefs.Add(
    Nome, ATipo, ATamanho, AObrigatorio);

  Result := Self;
end;

procedure TModelMemTableFireDAC.Limpar;
begin
  if not FMemTable.Active then
    raise Exception.Create(
      'A tabela em memoria nao esta aberta.');

  FMemTable.DisableControls;
  try
    if FMemTable.State in [dsEdit, dsInsert] then
      FMemTable.Cancel;

    FMemTable.EmptyDataSet;
  finally
    FMemTable.EnableControls;
  end;
end;

end.
