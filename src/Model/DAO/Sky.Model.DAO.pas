unit Sky.Model.DAO;

interface

uses
  System.SysUtils,
  System.Variants,
  Data.DB,
  Sky.Model.DAO.Interfaces,
  Sky.Model.Connection.Interfaces;

type
  TModelDAO = class(TInterfacedObject, iDAO)
  private
    FConexao: iConexao;
    FConsulta: iQuery;

    function PrepararValor(
      const AFiltro: TFiltro): Variant;
  protected
    FComando: iQuery;

    function SQLConsulta: string; virtual; abstract;

    function ColunaFiltro(
      const ACampo: string;
      out ATexto: Boolean): string; virtual; abstract;

    function MapearCampo(
      const ACampo: string;
      const ANomes: array of string;
      const AColunas: array of string): string;

    procedure ExigirTransacao;
    procedure VerificarRegistro(const ATabela: string; const AID: Integer);
    function GerarID(const AGenerator: string): Integer;

    procedure ExecutarComando;
    procedure ValidarID(const AID: Integer);

    procedure ValidarTexto(
      const AValor: string;
      const ACampo: string;
      const ATamanho: Integer;
      const AObrigatorio: Boolean);
  public
    constructor Create(
      const AConexao: iConexao;
      const AConsulta: iQuery;
      const AComando: iQuery);

    function Listar: iDAO;
    function BuscarPorId(const AID: Integer): iDAO;
    function BuscarPor(const AFiltros: array of TFiltro): iDAO;
    function DataSet: TDataSet;
  end;

implementation

uses
  Sky.Service.Log;

constructor TModelDAO.Create(
  const AConexao: iConexao;
  const AConsulta: iQuery;
  const AComando: iQuery);
begin
  inherited Create;

  if AConexao = nil then
    raise Exception.Create('Conexao nao informada.');

  if AConsulta = nil then
    raise Exception.Create('Query de consulta nao informada.');

  if AComando = nil then
    raise Exception.Create('Query de comando nao informada.');

  if AConsulta = AComando then
    raise Exception.Create(
      'Consulta e comando devem utilizar queries distintas.');

  FConexao := AConexao;
  FConsulta := AConsulta;
  FComando := AComando;
end;

procedure TModelDAO.ValidarID(const AID: Integer);
begin
  if AID <= 0 then
    raise Exception.Create('Identificador invalido.');
end;

procedure TModelDAO.ValidarTexto(
  const AValor: string;
  const ACampo: string;
  const ATamanho: Integer;
  const AObrigatorio: Boolean);
begin
  if AObrigatorio and (Trim(AValor) = '') then
    raise EOperacaoRecusada.CreateFmt(
      'Informe %s.', [ACampo]);

  if Length(AValor) > ATamanho then
    raise EOperacaoRecusada.CreateFmt(
      '%s permite ate %d caracteres.',
      [ACampo, ATamanho]);
end;

procedure TModelDAO.ExigirTransacao;
begin
  if not FConexao.Conectada then
    raise Exception.Create('Conexao fechada.');

  if not FConexao.EmTransacao then
    raise Exception.Create(
      'Inicie a transacao antes de gravar.');
end;

procedure TModelDAO.VerificarRegistro(
  const ATabela: string;
  const AID: Integer);
begin
  ValidarID(AID);
  ExigirTransacao;

  { ATabela recebe apenas constantes das classes DAO. }
  FComando.SQL(
    'SELECT ID FROM ' + ATabela +
    ' WHERE ID = :ID WITH LOCK');

  FComando.Parametro('ID', AID);

  try
    FComando.Abrir;

    if FComando.DataSet.IsEmpty then
      raise Exception.CreateFmt(
        'Registro %d nao encontrado em %s.',
        [AID, ATabela]);
  finally
    FComando.Fechar;
  end;
end;

function TModelDAO.GerarID(
  const AGenerator: string): Integer;
begin
  ExigirTransacao;

  { AGenerator recebe apenas constantes das classes DAO. }
  FComando.SQL(
    'SELECT GEN_ID(' + AGenerator +
    ', 1) AS ID FROM RDB$DATABASE');

  try
    FComando.Abrir;

    Result := StrToInt(
      FComando.DataSet.FieldByName('ID').AsString);

    ValidarID(Result);
  finally
    FComando.Fechar;
  end;
end;

procedure TModelDAO.ExecutarComando;
begin
  ExigirTransacao;

  try
    FComando.Executar;
  finally
    FComando.Fechar;
  end;
end;

function TModelDAO.MapearCampo(
  const ACampo: string;
  const ANomes: array of string;
  const AColunas: array of string): string;
var
  I: Integer;
begin
  Result := '';

  if Length(ANomes) <> Length(AColunas) then
    raise Exception.Create(
      'Mapeamento de filtros inconsistente.');

  for I := 0 to High(ANomes) do
    if SameText(Trim(ACampo), ANomes[I]) then
    begin
      Result := AColunas[I];
      Exit;
    end;
end;

function TModelDAO.PrepararValor(
  const AFiltro: TFiltro): Variant;
var
  Texto: string;
begin
  if VarIsNull(AFiltro.Valor) or
     VarIsEmpty(AFiltro.Valor) or
     VarIsArray(AFiltro.Valor) then
    raise Exception.CreateFmt(
      'Valor invalido para o filtro %s.',
      [AFiltro.Campo]);

  if AFiltro.Operador = ofContem then
  begin
    Texto := VarToStr(AFiltro.Valor);

    Texto := StringReplace(
      Texto, '!', '!!', [rfReplaceAll]);

    Texto := StringReplace(
      Texto, '%', '!%', [rfReplaceAll]);

    Texto := StringReplace(
      Texto, '_', '!_', [rfReplaceAll]);

    Result := '%' + Texto + '%';
  end
  else
    Result := AFiltro.Valor;
end;

function TModelDAO.Listar: iDAO;
var
  Filtros: array[0..0] of TFiltro;
begin
  Filtros[0].Campo := 'Ativo';
  Filtros[0].Operador := ofIgual;
  Filtros[0].Valor := 1;

  Result := BuscarPor(Filtros);
end;

function TModelDAO.BuscarPorId(
  const AID: Integer): iDAO;
var
  Filtros: array[0..0] of TFiltro;
begin
  ValidarID(AID);

  Filtros[0].Campo := 'ID';
  Filtros[0].Operador := ofIgual;
  Filtros[0].Valor := AID;

  Result := BuscarPor(Filtros);
end;

function TModelDAO.BuscarPor(
  const AFiltros: array of TFiltro): iDAO;
var
  I: Integer;
  TextoSQL: string;
  Coluna: string;
  Operador: string;
  CampoTexto: Boolean;
  Valores: array of Variant;
begin
  TextoSQL := SQLConsulta + ' WHERE 1 = 1';

  SetLength(Valores, Length(AFiltros));

  for I := 0 to High(AFiltros) do
  begin
    Coluna := ColunaFiltro(
      AFiltros[I].Campo, CampoTexto);

    if Coluna = '' then
      raise Exception.CreateFmt(
        'Campo de filtro nao permitido: %s.',
        [AFiltros[I].Campo]);

    case AFiltros[I].Operador of
      ofIgual:
        Operador := ' = ';

      ofMaiorOuIgual:
        Operador := ' >= ';

      ofMenorOuIgual:
        Operador := ' <= ';

      ofContem:
        begin
          if not CampoTexto then
            raise Exception.CreateFmt(
              'O campo %s nao permite o operador contem.',
              [AFiltros[I].Campo]);

          Operador := ' LIKE ';
        end;
    else
      raise Exception.Create('Operador de filtro invalido.');
    end;

    Valores[I] := PrepararValor(AFiltros[I]);

    TextoSQL := TextoSQL +
      ' AND ' + Coluna + Operador +
      ':FILTRO_' + IntToStr(I);

    if AFiltros[I].Operador = ofContem then
      TextoSQL := TextoSQL + ' ESCAPE ''!''';
  end;

  TextoSQL := TextoSQL + ' ORDER BY 1';

  FConsulta.SQL(TextoSQL);

  for I := 0 to High(AFiltros) do
    FConsulta.Parametro(
      'FILTRO_' + IntToStr(I), Valores[I]);

  FConsulta.Abrir;

  Result := Self;
end;

function TModelDAO.DataSet: TDataSet;
begin
  Result := FConsulta.DataSet;
end;

end.
