unit Sky.Controller.OrdemServico;

interface

uses
  System.SysUtils,
  System.Variants,
  Data.DB,
  Sky.Controller.Interfaces,
  Sky.Model.Entity.Interfaces,
  Sky.Model.DAO.Interfaces,
  Sky.Model.Connection.Interfaces;

type
  TListaItensOS = array of iItemOrdem;

  TControllerOrdemServico = class(
    TInterfacedObject, iControllerOrdemServico)
  private
    FConexao: iConexao;

    FDAOListagem: iDAOOrdemServico;
    FDAOCadastro: iDAOOrdemServico;
    FDAOItens: iDAOItemOrdem;
    FDAOClientes: iDAOCliente;

    FOrdem: iOrdemServico;
    FItens: TListaItensOS;
    FItensOriginais: TListaItensOS;

    FTotal: Currency;
    FIndicadores: TIndicadoresOrdemServico;

    procedure VerificarConexao;
    procedure ExigirManutencao;
    procedure ValidarIndice(const AIndice: Integer);

    function ConsultaDAO(const ADAO: iDAO): TDataSet;

    function StatusTexto(
      AStatus: TStatusOrdemServico): string;

    function StatusTipo(
      const AStatus: string): TStatusOrdemServico;

    procedure AdicionarFiltro(
      var AFiltros: TFiltros;
      const ACampo: string;
      AOperador: TOperadorFiltro;
      const AValor: Variant);

    function LerOrdem(
      AConsulta: TDataSet): iOrdemServico;

    function LerItens(
      const AOrdemID: Integer): TListaItensOS;

    function CopiarItem(
      const AItem: iItemOrdem): iItemOrdem;

    function CopiarItens(
      const AItens: TListaItensOS): TListaItensOS;

    function ArredondarValor(
      const AValor: Currency): Currency;

    function CalcularSubtotal(
      const AQuantidade: Double;
      const AValorUnitario: Currency): Currency;

    function CalcularTotal(
      const AItens: TListaItensOS): Currency;

    procedure ValidarItem(const AItem: iItemOrdem);

    function IndiceItem(
      const AItens: TListaItensOS;
      const AID: Integer): Integer;

    function ItensIguais(
      const APrimeiro: iItemOrdem;
      const ASegundo: iItemOrdem): Boolean;

    function OrdensIguais(
      const APrimeira: iOrdemServico;
      const ASegunda: iOrdemServico): Boolean;

    procedure ConferirEstadoPersistido;

    function PrepararOrdem(
      const ADados: TDadosOrdemServico): iOrdemServico;
  public
    constructor Create(
      const AConexao: iConexao;
      const ADAOListagem: iDAOOrdemServico;
      const ADAOCadastro: iDAOOrdemServico;
      const ADAOItens: iDAOItemOrdem;
      const ADAOClientes: iDAOCliente);

    destructor Destroy; override;

    class function New(
      const AConexao: iConexao;
      const ADAOListagem: iDAOOrdemServico;
      const ADAOCadastro: iDAOOrdemServico;
      const ADAOItens: iDAOItemOrdem;
      const ADAOClientes: iDAOCliente): iControllerOrdemServico;

    procedure Pesquisar(
      const AFiltro: TFiltroOrdemServico);

    procedure Novo;
    procedure Carregar(const AID: Integer);

    function Dados: TDadosOrdemServico;
    function PodeEditar: Boolean;

    function PodeAlterarStatus(
      ANovoStatus: TStatusOrdemServico): Boolean;

    procedure NovoItem;

    function DadosItem(
      const AIndice: Integer): TDadosItemOrdem;

    procedure AtualizarItem(
      const AIndice: Integer;
      const ADados: TDadosItemOrdem);

    procedure ExcluirItem(const AIndice: Integer);
    function QuantidadeItens: Integer;
    procedure RecalcularTotal;

    procedure Salvar(
      const ADados: TDadosOrdemServico);

    procedure Descartar;
    procedure AtualizarClientes;
    procedure AtualizarIndicadores;

    function Indicadores: TIndicadoresOrdemServico;

    function DataSetListagem: TDataSet;
    function DataSetClientes: TDataSet;
    function DataSetItens: TDataSet;
  end;

implementation

uses
  Sky.Model.Entity;

const
  MAX_QUANTIDADE: Currency = 9999999999.99;
  MAX_VALOR: Currency = 9999999999999.99;

constructor TControllerOrdemServico.Create(
  const AConexao: iConexao;
  const ADAOListagem: iDAOOrdemServico;
  const ADAOCadastro: iDAOOrdemServico;
  const ADAOItens: iDAOItemOrdem;
  const ADAOClientes: iDAOCliente);
begin
  inherited Create;

  if AConexao = nil then
    raise Exception.Create('Conexao nao informada.');

  if ADAOListagem = nil then
    raise Exception.Create('DAO de listagem nao informado.');

  if ADAOCadastro = nil then
    raise Exception.Create('DAO de cadastro nao informado.');

  if ADAOItens = nil then
    raise Exception.Create('DAO de itens nao informado.');

  if ADAOClientes = nil then
    raise Exception.Create('DAO de clientes nao informado.');

  if ADAOListagem = ADAOCadastro then
    raise Exception.Create(
      'Listagem e cadastro devem utilizar DAOs distintos.');

  FConexao := AConexao;
  FDAOListagem := ADAOListagem;
  FDAOCadastro := ADAOCadastro;
  FDAOItens := ADAOItens;
  FDAOClientes := ADAOClientes;
end;

destructor TControllerOrdemServico.Destroy;
begin
  inherited Destroy;
end;

class function TControllerOrdemServico.New(
  const AConexao: iConexao;
  const ADAOListagem: iDAOOrdemServico;
  const ADAOCadastro: iDAOOrdemServico;
  const ADAOItens: iDAOItemOrdem;
  const ADAOClientes: iDAOCliente): iControllerOrdemServico;
begin
  Result := Self.Create(
    AConexao,
    ADAOListagem,
    ADAOCadastro,
    ADAOItens,
    ADAOClientes);
end;

procedure TControllerOrdemServico.VerificarConexao;
begin
  if not FConexao.Conectada then
    raise Exception.Create('Conexao fechada.');
end;

procedure TControllerOrdemServico.ExigirManutencao;
begin
  if FOrdem = nil then
    raise Exception.Create(
      'Selecione uma OS ou inicie um novo cadastro.');
end;

procedure TControllerOrdemServico.ValidarIndice(
  const AIndice: Integer);
begin
  ExigirManutencao;

  if (AIndice < 0) or (AIndice >= Length(FItens)) then
    raise Exception.Create('Indice de item invalido.');
end;

function TControllerOrdemServico.ConsultaDAO(
  const ADAO: iDAO): TDataSet;
begin
  Result := ADAO.DataSet;

  if Result = nil then
    raise Exception.Create('Consulta indisponivel.');

  if not Result.Active then
    raise Exception.Create('Consulta fechada.');
end;

function TControllerOrdemServico.StatusTexto(
  AStatus: TStatusOrdemServico): string;
begin
  case AStatus of
    soAberta:
      Result := 'Aberta';

    soEmAndamento:
      Result := 'Em Andamento';

    soConcluida:
      Result := 'Concluida';

    soCancelada:
      Result := 'Cancelada';
  else
    raise Exception.Create('Status de OS invalido.');
  end;
end;

function TControllerOrdemServico.StatusTipo(
  const AStatus: string): TStatusOrdemServico;
begin
  if AStatus = 'Aberta' then
    Result := soAberta
  else if AStatus = 'Em Andamento' then
    Result := soEmAndamento
  else if AStatus = 'Concluida' then
    Result := soConcluida
  else if AStatus = 'Cancelada' then
    Result := soCancelada
  else
    raise Exception.CreateFmt(
      'Status de OS desconhecido: %s.', [AStatus]);
end;

procedure TControllerOrdemServico.AdicionarFiltro(
  var AFiltros: TFiltros;
  const ACampo: string;
  AOperador: TOperadorFiltro;
  const AValor: Variant);
var
  Indice: Integer;
begin
  Indice := Length(AFiltros);
  SetLength(AFiltros, Indice + 1);

  AFiltros[Indice].Campo := ACampo;
  AFiltros[Indice].Operador := AOperador;
  AFiltros[Indice].Valor := AValor;
end;

procedure TControllerOrdemServico.Pesquisar(
  const AFiltro: TFiltroOrdemServico);
var
  Filtros: TFiltros;
  Nome: string;
begin
  VerificarConexao;

  SetLength(Filtros, 0);
  Nome := UpperCase(Trim(AFiltro.NomeCliente));

  if Nome <> '' then
    AdicionarFiltro(
      Filtros, 'NomeCliente', ofContem, Nome);

  if AFiltro.FiltrarPeriodo then
  begin
    if Trunc(AFiltro.DataInicial) >
       Trunc(AFiltro.DataFinal) then
      raise Exception.Create(
        'A data inicial deve ser anterior ou igual a final.');

    AdicionarFiltro(
      Filtros,
      'DataAbertura',
      ofMaiorOuIgual,
      VarFromDateTime(Trunc(AFiltro.DataInicial)));

    AdicionarFiltro(
      Filtros,
      'DataAbertura',
      ofMenorOuIgual,
      VarFromDateTime(Trunc(AFiltro.DataFinal)));
  end;

  if AFiltro.FiltrarStatus then
    AdicionarFiltro(
      Filtros,
      'Status',
      ofIgual,
      StatusTexto(AFiltro.Status));

  FDAOListagem.BuscarPor(Filtros);
end;

function TControllerOrdemServico.LerOrdem(
  AConsulta: TDataSet): iOrdemServico;
begin
  if AConsulta.IsEmpty then
    raise Exception.Create('Ordem de Servico nao encontrada.');

  Result := TEntidade.New.OrdemServico;

  Result.ID(AConsulta.FieldByName('ID').AsInteger);

  Result.ClienteID(
    AConsulta.FieldByName('CLIENTE_ID').AsInteger);

  Result.DataAbertura(
    AConsulta.FieldByName('DATA_ABERTURA').AsDateTime);

  Result.DataPrevista(
    AConsulta.FieldByName('DATA_PREVISTA').AsDateTime);

  Result.Status(
    AConsulta.FieldByName('STATUS').AsString);

  Result.Problema(
    AConsulta.FieldByName('DESCRICAO_PROBLEMA').AsString);

  Result.ValorTotal(
    AConsulta.FieldByName('VALOR_TOTAL').AsCurrency);

  Result.Ativo(
    AConsulta.FieldByName('ATIVO').AsInteger = 1);

  if AConsulta.FieldByName('DATA_FECHAMENTO').IsNull then
    Result.LimparDataFechamento
  else
    Result.DataFechamento(
      AConsulta.FieldByName('DATA_FECHAMENTO').AsDateTime);
end;

function TControllerOrdemServico.LerItens(
  const AOrdemID: Integer): TListaItensOS;
var
  Filtros: TFiltros;
  Consulta: TDataSet;
  Item: iItemOrdem;
  Indice: Integer;
begin
  SetLength(Result, 0);
  SetLength(Filtros, 0);

  AdicionarFiltro(
    Filtros, 'OrdemID', ofIgual, AOrdemID);

  FDAOItens.BuscarPor(Filtros);
  Consulta := ConsultaDAO(FDAOItens);

  Consulta.DisableControls;
  try
    Consulta.First;

    while not Consulta.Eof do
    begin
      Item := TEntidade.New.ItemOrdem;

      Item.ID(Consulta.FieldByName('ID').AsInteger);

      Item.OrdemID(
        Consulta.FieldByName('ORDEM_ID').AsInteger);

      Item.Descricao(
        Consulta.FieldByName('DESCRICAO').AsString);

      Item.Quantidade(
        Consulta.FieldByName('QUANTIDADE').AsFloat);

      Item.ValorUnitario(
        Consulta.FieldByName('VALOR_UNITARIO').AsCurrency);

      Item.Ativo(
        Consulta.FieldByName('ATIVO').AsInteger = 1);

      Indice := Length(Result);
      SetLength(Result, Indice + 1);
      Result[Indice] := Item;

      Consulta.Next;
    end;
  finally
    try
      Consulta.First;
    finally
      Consulta.EnableControls;
    end;
  end;
end;

function TControllerOrdemServico.CopiarItem(
  const AItem: iItemOrdem): iItemOrdem;
begin
  Result := TEntidade.New.ItemOrdem;

  Result.ID(AItem.ID);
  Result.OrdemID(AItem.OrdemID);
  Result.Descricao(AItem.Descricao);
  Result.Quantidade(AItem.Quantidade);
  Result.ValorUnitario(AItem.ValorUnitario);
  Result.Ativo(AItem.Ativo);
end;

function TControllerOrdemServico.CopiarItens(
  const AItens: TListaItensOS): TListaItensOS;
var
  I: Integer;
begin
  SetLength(Result, Length(AItens));

  for I := 0 to High(AItens) do
    Result[I] := CopiarItem(AItens[I]);
end;

procedure TControllerOrdemServico.Novo;
var
  Ordem: iOrdemServico;
begin
  Ordem := TEntidade.New.OrdemServico;

  Ordem.ID(0);
  Ordem.ClienteID(0);
  Ordem.DataAbertura(Date);
  Ordem.DataPrevista(Date);
  Ordem.Problema('');
  Ordem.Status('Aberta');
  Ordem.ValorTotal(0);
  Ordem.Ativo(True);
  Ordem.LimparDataFechamento;

  Descartar;
  FOrdem := Ordem;
end;

procedure TControllerOrdemServico.Carregar(
  const AID: Integer);
var
  Consulta: TDataSet;
  Ordem: iOrdemServico;
  Itens: TListaItensOS;
  Originais: TListaItensOS;
  Total: Currency;
begin
  VerificarConexao;

  if AID <= 0 then
    raise Exception.Create('Identificador de OS invalido.');

  FDAOCadastro.BuscarPorId(AID);
  Consulta := ConsultaDAO(FDAOCadastro);

  try
    Ordem := LerOrdem(Consulta);
  finally
    Consulta.Close;
  end;

  StatusTipo(Ordem.Status);

  Itens := LerItens(AID);
  Originais := CopiarItens(Itens);
  Total := CalcularTotal(Itens);

  FOrdem := Ordem;
  FItens := Itens;
  FItensOriginais := Originais;
  FTotal := Total;
end;

function TControllerOrdemServico.Dados: TDadosOrdemServico;
begin
  Result.ID := 0;
  Result.ClienteID := 0;
  Result.DataAbertura := 0;
  Result.DataPrevista := 0;
  Result.Problema := '';
  Result.Status := soAberta;
  Result.TemDataFechamento := False;
  Result.DataFechamento := 0;
  Result.ValorTotal := 0;

  if FOrdem = nil then
    Exit;

  Result.ID := FOrdem.ID;
  Result.ClienteID := FOrdem.ClienteID;
  Result.DataAbertura := FOrdem.DataAbertura;
  Result.DataPrevista := FOrdem.DataPrevista;
  Result.Problema := FOrdem.Problema;
  Result.Status := StatusTipo(FOrdem.Status);
  Result.TemDataFechamento := FOrdem.TemDataFechamento;

  if Result.TemDataFechamento then
    Result.DataFechamento := FOrdem.DataFechamento;

  Result.ValorTotal := FTotal;
end;

function TControllerOrdemServico.PodeEditar: Boolean;
begin
  Result := FOrdem <> nil;
end;

function TControllerOrdemServico.PodeAlterarStatus(
  ANovoStatus: TStatusOrdemServico): Boolean;
var
  Atual: TStatusOrdemServico;
begin
  Result := False;

  if FOrdem = nil then
    Exit;

  if FOrdem.ID = 0 then
  begin
    Result := ANovoStatus = soAberta;
    Exit;
  end;

  Atual := StatusTipo(FOrdem.Status);

  if Atual = ANovoStatus then
  begin
    Result := True;
    Exit;
  end;

  case Atual of
    soAberta:
      Result := ANovoStatus in [
        soEmAndamento, soCancelada];

    soEmAndamento:
      Result := ANovoStatus in [
        soConcluida, soCancelada];

    soConcluida, soCancelada:
      Result := False;
  end;
end;

function TControllerOrdemServico.ArredondarValor(
  const AValor: Currency): Currency;
var
  ParteInteira: Int64;
  Fracao: Currency;
  Centavos: Integer;
begin
  if AValor < 0 then
    raise Exception.Create('Valor negativo nao permitido.');

  ParteInteira := Trunc(AValor);
  Fracao := AValor - ParteInteira;
  Centavos := Trunc(Fracao * 100 + 0.5);

  Result := ParteInteira;
  Result := Result + Centavos / 100;
end;

function TControllerOrdemServico.CalcularSubtotal(
  const AQuantidade: Double;
  const AValorUnitario: Currency): Currency;
var
  Quantidade: Currency;
begin
  if not (AQuantidade > 0) then
    raise Exception.Create(
      'A quantidade deve ser maior que zero.');

  if not (AQuantidade <= MAX_QUANTIDADE) then
    raise Exception.Create(
      'A quantidade excede o limite permitido.');

  Quantidade := AQuantidade;

  if (Abs(AQuantidade - Quantidade) > 0.000001) or
     (ArredondarValor(Quantidade) <> Quantidade) then
    raise Exception.Create(
      'A quantidade permite ate duas casas decimais.');

  if AValorUnitario < 0 then
    raise Exception.Create(
      'O valor unitario nao pode ser negativo.');

  if AValorUnitario > MAX_VALOR then
    raise Exception.Create(
      'O valor unitario excede o limite permitido.');

  if ArredondarValor(AValorUnitario) <> AValorUnitario then
    raise Exception.Create(
      'O valor unitario permite ate duas casas decimais.');

  if AValorUnitario = 0 then
  begin
    Result := 0;
    Exit;
  end;

  if Quantidade > Extended(MAX_VALOR) / AValorUnitario then
    raise Exception.Create(
      'O subtotal do item excede o limite permitido.');

  Result := ArredondarValor(
    Quantidade * AValorUnitario);

  if Result > MAX_VALOR then
    raise Exception.Create(
      'O subtotal do item excede o limite permitido.');
end;

function TControllerOrdemServico.CalcularTotal(
  const AItens: TListaItensOS): Currency;
var
  I: Integer;
  Subtotal: Currency;
begin
  Result := 0;

  for I := 0 to High(AItens) do
  begin
    Subtotal := CalcularSubtotal(
      AItens[I].Quantidade,
      AItens[I].ValorUnitario);

    if Result > MAX_VALOR - Subtotal then
      raise Exception.Create(
        'O total da OS excede o limite permitido.');

    Result := Result + Subtotal;
  end;
end;

procedure TControllerOrdemServico.ValidarItem(
  const AItem: iItemOrdem);
begin
  if Trim(AItem.Descricao) = '' then
    raise Exception.Create('Informe a descricao do item.');

  if Length(AItem.Descricao) > 200 then
    raise Exception.Create(
      'A descricao do item permite ate 200 caracteres.');

  CalcularSubtotal(
    AItem.Quantidade, AItem.ValorUnitario);
end;

procedure TControllerOrdemServico.NovoItem;
var
  Item: iItemOrdem;
  Indice: Integer;
begin
  ExigirManutencao;

  Item := TEntidade.New.ItemOrdem;

  Item.ID(0);
  Item.OrdemID(FOrdem.ID);
  Item.Descricao('');
  Item.Quantidade(1);
  Item.ValorUnitario(0);
  Item.Ativo(True);

  Indice := Length(FItens);
  SetLength(FItens, Indice + 1);
  FItens[Indice] := Item;
end;

function TControllerOrdemServico.DadosItem(
  const AIndice: Integer): TDadosItemOrdem;
begin
  ValidarIndice(AIndice);

  Result.ID := FItens[AIndice].ID;
  Result.Descricao := FItens[AIndice].Descricao;
  Result.Quantidade := FItens[AIndice].Quantidade;
  Result.ValorUnitario := FItens[AIndice].ValorUnitario;
end;

procedure TControllerOrdemServico.AtualizarItem(
  const AIndice: Integer;
  const ADados: TDadosItemOrdem);
var
  Item: iItemOrdem;
  Anterior: iItemOrdem;
  Total: Currency;
begin
  ValidarIndice(AIndice);

  if ADados.ID <> FItens[AIndice].ID then
    raise Exception.Create(
      'Os dados nao correspondem ao item selecionado.');

  Item := CopiarItem(FItens[AIndice]);

  Item.Descricao(Trim(ADados.Descricao));
  Item.Quantidade(ADados.Quantidade);
  Item.ValorUnitario(ADados.ValorUnitario);

  ValidarItem(Item);

  Anterior := FItens[AIndice];
  FItens[AIndice] := Item;

  try
    Total := CalcularTotal(FItens);
  except
    FItens[AIndice] := Anterior;
    raise;
  end;

  FTotal := Total;
end;

procedure TControllerOrdemServico.ExcluirItem(
  const AIndice: Integer);
var
  I: Integer;
begin
  ValidarIndice(AIndice);

  for I := AIndice to High(FItens) - 1 do
    FItens[I] := FItens[I + 1];

  SetLength(FItens, Length(FItens) - 1);

  RecalcularTotal;
end;

function TControllerOrdemServico.QuantidadeItens: Integer;
begin
  Result := Length(FItens);
end;

procedure TControllerOrdemServico.RecalcularTotal;
begin
  FTotal := CalcularTotal(FItens);
end;

function TControllerOrdemServico.IndiceItem(
  const AItens: TListaItensOS;
  const AID: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;

  for I := 0 to High(AItens) do
    if AItens[I].ID = AID then
    begin
      Result := I;
      Exit;
    end;
end;

function TControllerOrdemServico.ItensIguais(
  const APrimeiro: iItemOrdem;
  const ASegundo: iItemOrdem): Boolean;
begin
  Result :=
    (APrimeiro.ID = ASegundo.ID) and
    (APrimeiro.OrdemID = ASegundo.OrdemID) and
    (APrimeiro.Descricao = ASegundo.Descricao) and
    (APrimeiro.Quantidade = ASegundo.Quantidade) and
    (APrimeiro.ValorUnitario = ASegundo.ValorUnitario) and
    (APrimeiro.Ativo = ASegundo.Ativo);
end;

function TControllerOrdemServico.OrdensIguais(
  const APrimeira: iOrdemServico;
  const ASegunda: iOrdemServico): Boolean;
begin
  Result :=
    (APrimeira.ID = ASegunda.ID) and
    (APrimeira.ClienteID = ASegunda.ClienteID) and
    (APrimeira.DataAbertura = ASegunda.DataAbertura) and
    (APrimeira.DataPrevista = ASegunda.DataPrevista) and
    (APrimeira.Status = ASegunda.Status) and
    (APrimeira.Problema = ASegunda.Problema) and
    (APrimeira.ValorTotal = ASegunda.ValorTotal) and
    (APrimeira.Ativo = ASegunda.Ativo) and
    (APrimeira.TemDataFechamento = ASegunda.TemDataFechamento);

  if Result and APrimeira.TemDataFechamento then
    Result :=
      APrimeira.DataFechamento = ASegunda.DataFechamento;
end;

procedure TControllerOrdemServico.ConferirEstadoPersistido;
var
  Consulta: TDataSet;
  OrdemAtual: iOrdemServico;
  ItensAtuais: TListaItensOS;
  I: Integer;
  Indice: Integer;
begin
  if FOrdem.ID = 0 then
    Exit;

  FDAOCadastro.Bloquear(FOrdem.ID);
  FDAOCadastro.BuscarPorId(FOrdem.ID);

  Consulta := ConsultaDAO(FDAOCadastro);
  try
    OrdemAtual := LerOrdem(Consulta);
  finally
    Consulta.Close;
  end;

  if not OrdensIguais(FOrdem, OrdemAtual) then
    raise Exception.Create(
      'A OS foi alterada apos o carregamento. ' +
      'Recarregue os dados antes de salvar.');

  ItensAtuais := LerItens(FOrdem.ID);

  if Length(ItensAtuais) <> Length(FItensOriginais) then
    raise Exception.Create(
      'Os itens foram alterados apos o carregamento. ' +
      'Recarregue a OS antes de salvar.');

  for I := 0 to High(ItensAtuais) do
  begin
    Indice := IndiceItem(
      FItensOriginais, ItensAtuais[I].ID);

    if Indice < 0 then
      raise Exception.Create(
        'Os itens foram alterados. Recarregue a OS.');

    if not ItensIguais(
      FItensOriginais[Indice], ItensAtuais[I]) then
      raise Exception.Create(
        'Os itens foram alterados. Recarregue a OS.');
  end;
end;

function TControllerOrdemServico.PrepararOrdem(
  const ADados: TDadosOrdemServico): iOrdemServico;
var
  Status: string;
begin
  if ADados.ID <> FOrdem.ID then
    raise Exception.Create(
      'Os dados nao correspondem a OS em manutencao.');

  Status := StatusTexto(ADados.Status);

  if not PodeAlterarStatus(ADados.Status) then
    raise Exception.Create(
      'A transicao de status informada nao e permitida.');

  Result := TEntidade.New.OrdemServico;

  Result.ID(FOrdem.ID);
  Result.ClienteID(ADados.ClienteID);
  Result.DataAbertura(Trunc(ADados.DataAbertura));
  Result.DataPrevista(Trunc(ADados.DataPrevista));
  Result.Problema(ADados.Problema);
  Result.Status(Status);
  Result.ValorTotal(FTotal);
  Result.Ativo(FOrdem.Ativo);

  if ADados.Status in [soConcluida, soCancelada] then
  begin
    if Status <> FOrdem.Status then
      Result.DataFechamento(Date)
    else if FOrdem.TemDataFechamento then
      Result.DataFechamento(FOrdem.DataFechamento)
    else
      Result.LimparDataFechamento;
  end
  else
    Result.LimparDataFechamento;
end;

procedure TControllerOrdemServico.Salvar(
  const ADados: TDadosOrdemServico);
var
  OrdemGravacao: iOrdemServico;
  ItensGravacao: TListaItensOS;
  I: Integer;
  Indice: Integer;
begin
  ExigirManutencao;
  VerificarConexao;

  if FConexao.EmTransacao then
    raise Exception.Create(
      'Existe uma transacao em andamento.');

  for I := 0 to High(FItens) do
    ValidarItem(FItens[I]);

  RecalcularTotal;

  OrdemGravacao := PrepararOrdem(ADados);
  ItensGravacao := CopiarItens(FItens);

  FConexao.IniciarTransacao;
  try
    ConferirEstadoPersistido;

    if OrdemGravacao.ID = 0 then
      FDAOCadastro.Inserir(OrdemGravacao)
    else
      FDAOCadastro.Atualizar(OrdemGravacao);

    for I := 0 to High(FItensOriginais) do
      if IndiceItem(
        ItensGravacao, FItensOriginais[I].ID) < 0 then
        FDAOItens.Excluir(FItensOriginais[I].ID);

    for I := 0 to High(ItensGravacao) do
    begin
      ItensGravacao[I].OrdemID(OrdemGravacao.ID);

      if ItensGravacao[I].ID = 0 then
        FDAOItens.Inserir(ItensGravacao[I])
      else
      begin
        Indice := IndiceItem(
          FItensOriginais, ItensGravacao[I].ID);

        if Indice < 0 then
          raise Exception.Create(
            'O item nao pertence a OS carregada.');

        if not ItensIguais(
          FItensOriginais[Indice], ItensGravacao[I]) then
          FDAOItens.Atualizar(ItensGravacao[I]);
      end;
    end;

    FConexao.ConfirmarTransacao;
  except
    on E: Exception do
    begin
      try
        if FConexao.EmTransacao then
          FConexao.DesfazerTransacao;
      except
        on ERollback: Exception do
          raise Exception.CreateFmt(
            'Falha ao salvar: %s. Falha ao desfazer: %s.',
            [E.Message, ERollback.Message]);
      end;

      raise;
    end;
  end;

  { A manutencao em memoria e encerrada somente apos o commit. }
  FOrdem := nil;
  SetLength(FItens, 0);
  SetLength(FItensOriginais, 0);
  FTotal := 0;
end;

procedure TControllerOrdemServico.Descartar;
begin
  FOrdem := nil;
  SetLength(FItens, 0);
  SetLength(FItensOriginais, 0);
  FTotal := 0;
end;

procedure TControllerOrdemServico.AtualizarClientes;
begin
  VerificarConexao;
  FDAOClientes.BuscarPor([]);
end;

procedure TControllerOrdemServico.AtualizarIndicadores;
var
  Consulta: TDataSet;
  Novos: TIndicadoresOrdemServico;
  Status: TStatusOrdemServico;
  Hoje: TDateTime;
begin
  VerificarConexao;

  Novos.Abertas := 0;
  Novos.EmAndamento := 0;
  Novos.Concluidas := 0;
  Novos.Atrasadas := 0;

  Hoje := Date;

  FDAOCadastro.BuscarPor([]);
  Consulta := ConsultaDAO(FDAOCadastro);

  try
    Consulta.First;

    while not Consulta.Eof do
    begin
      Status := StatusTipo(
        Consulta.FieldByName('STATUS').AsString);

      case Status of
        soAberta:
          Inc(Novos.Abertas);

        soEmAndamento:
          Inc(Novos.EmAndamento);

        soConcluida:
          Inc(Novos.Concluidas);
      end;

      if not (Status in [soConcluida, soCancelada]) then
        if Trunc(Hoje) >
           Trunc(Consulta.FieldByName(
             'DATA_PREVISTA').AsDateTime) then
          Inc(Novos.Atrasadas);

      Consulta.Next;
    end;

    FIndicadores := Novos;
  finally
    Consulta.Close;
  end;
end;

function TControllerOrdemServico.Indicadores:
  TIndicadoresOrdemServico;
begin
  Result := FIndicadores;
end;

function TControllerOrdemServico.DataSetListagem: TDataSet;
begin
  Result := FDAOListagem.DataSet;
end;

function TControllerOrdemServico.DataSetClientes: TDataSet;
begin
  Result := FDAOClientes.DataSet;
end;

function TControllerOrdemServico.DataSetItens: TDataSet;
begin
  Result := FDAOItens.DataSet;
end;

end.
