unit Sky.Model.Connection.MemTable.ADO;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  Data.Win.ADODB,
  Sky.Model.Connection.Interfaces;

type
  TModelMemTableADO = class(TInterfacedObject, iMemTable)
  private
    FMemTable: TADODataSet;

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

{ TModelMemTableADO }

constructor TModelMemTableADO.Create;
begin
  inherited Create;

  FMemTable := TADODataSet.Create(nil);
  FMemTable.CursorLocation := clUseClient;
end;

destructor TModelMemTableADO.Destroy;
begin
  FMemTable.Free;
  inherited;
end;

class function TModelMemTableADO.New: iMemTable;
begin
  Result := Self.Create;
end;

procedure TModelMemTableADO.Criar;
begin
  if FMemTable.Active then
    raise Exception.Create(
      'A tabela em memoria ja esta aberta.');

  if FMemTable.FieldDefs.Count = 0 then
    raise Exception.Create(
      'Defina os campos antes de criar a tabela em memoria.');

  FMemTable.CreateDataSet;
end;

function TModelMemTableADO.DataSet: TDataSet;
begin
  Result := FMemTable;
end;

function TModelMemTableADO.DefinirCampo(const aNome: string; aTipo: TFieldType;
  const aTamanho: Integer; const aObrigatorio: Boolean): iMemTable;
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

procedure TModelMemTableADO.Limpar;
var
  Filtrado: Boolean;
  GrupoFiltro: TFilterGroup;
begin
  if not FMemTable.Active then
    raise Exception.Create(
      'A tabela em memoria nao esta aberta.');

  Filtrado := FMemTable.Filtered;
  GrupoFiltro := FMemTable.FilterGroup;

  FMemTable.DisableControls;
  try
    if FMemTable.State in [dsEdit, dsInsert] then
      FMemTable.Cancel;

    try
      FMemTable.Filtered := False;
      FMemTable.FilterGroup := fgNone;

      FMemTable.First;

      while not FMemTable.Eof do
        FMemTable.Delete;
    finally
      FMemTable.FilterGroup := GrupoFiltro;
      FMemTable.Filtered := Filtrado;
    end;
  finally
    FMemTable.EnableControls;
  end;
end;

end.
