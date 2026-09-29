unit Sky.Controller.Factory;

interface

uses
  System.SysUtils,
  Sky.Controller.Interfaces,
  Sky.Model.Connection.Interfaces;

type
  TTipoAcessoDados = (adFireDAC, adADO);

  TControllerFactory = class(TInterfacedObject, iControllerFactory)
  private
    FConexao: iConexao;
    FTipoAcesso: TTipoAcessoDados;
    constructor Create(const aArquivoINI: string;
      aTipoAcesso: TTipoAcessoDados);
    function CriarQuery: iQuery;
  public
    class function New(const aArquivoINI: String;
      aTipoAcesso: TTipoAcessoDados): iControllerFactory;
    function Cliente: iControllerCliente;
    function OrdemServico: iControllerOrdemServico;
  end;

implementation

uses
  Sky.Controller.Clientes,
  Sky.Controller.OrdemServico,
  Sky.Model.DAO.Interfaces,
  Sky.Model.DAO.Cliente,
  Sky.Model.DAO.OrdemServico,
  Sky.Model.DAO.ItemOrdem,
  Sky.Model.Connection.Configuracao,
  Sky.Model.Connection.FireDAC,
  Sky.Model.Connection.ADO,
  Sky.Model.Connection.Query.FireDAC,
  Sky.Model.Connection.Query.ADO;

{ TControllerFactory }

constructor TControllerFactory.Create(const aArquivoINI: string;
  aTipoAcesso: TTipoAcessoDados);
var
  Configuracao: iConfiguracao;
begin
  inherited Create;

  FTipoAcesso := ATipoAcesso;

  Configuracao := TModelConfiguracaoFiredac.New(AArquivoINI);

  case FTipoAcesso of
    adFireDAC:
      FConexao := TModelConexaoFireDAC.New(Configuracao);

    adADO:
      FConexao := TModelConexaoADO.New(Configuracao);
  else
    raise Exception.Create('Tipo de acesso a dados invalido.');
  end;

  FConexao.Conectar;
end;

class function TControllerFactory.New(const aArquivoINI: String;
  aTipoAcesso: TTipoAcessoDados): iControllerFactory;
begin
  Result := Self.Create(AArquivoINI, aTipoAcesso);
end;

function TControllerFactory.OrdemServico: iControllerOrdemServico;
var
  ConsultaListagem: iQuery;
  ComandoListagem: iQuery;
  ConsultaCadastro: iQuery;
  ComandoCadastro: iQuery;
  ConsultaItens: iQuery;
  ComandoItens: iQuery;
  ConsultaClientes: iQuery;
  ComandoClientes: iQuery;

  DAOListagem: iDAOOrdemServico;
  DAOCadastro: iDAOOrdemServico;
  DAOItens: iDAOItemOrdem;
  DAOClientes: iDAOCliente;
begin
  if not FConexao.Conectada then
    raise Exception.Create('Conexao fechada.');

  ConsultaListagem := CriarQuery;
  ComandoListagem := CriarQuery;

  ConsultaCadastro := CriarQuery;
  ComandoCadastro := CriarQuery;

  ConsultaItens := CriarQuery;
  ComandoItens := CriarQuery;

  ConsultaClientes := CriarQuery;
  ComandoClientes := CriarQuery;

  DAOListagem := TModelDAOOrdemServico.New(
    FConexao,
    ConsultaListagem,
    ComandoListagem);

  DAOCadastro := TModelDAOOrdemServico.New(
    FConexao,
    ConsultaCadastro,
    ComandoCadastro);

  DAOItens := TModelDAOItemOrdem.New(
    FConexao,
    ConsultaItens,
    ComandoItens);

  DAOClientes := TModelDAOCliente.New(
    FConexao,
    ConsultaClientes,
    ComandoClientes);

  Result := TControllerOrdemServico.New(
    FConexao,
    DAOListagem,
    DAOCadastro,
    DAOItens,
    DAOClientes);
end;

function TControllerFactory.Cliente: iControllerCliente;
var
  ConsultaListagem: iQuery;
  ComandoListagem: iQuery;
  ConsultaCadastro: iQuery;
  ComandoCadastro: iQuery;
  DAOListagem: iDAOCliente;
  DAOCadastro: iDAOCliente;
begin
  if not FConexao.Conectada then
    raise Exception.Create('Conexao fechada.');

  ConsultaListagem := CriarQuery;
  ComandoListagem := CriarQuery;

  ConsultaCadastro := CriarQuery;
  ComandoCadastro := CriarQuery;

  DAOListagem := TModelDAOCliente.New(
    FConexao,
    ConsultaListagem,
    ComandoListagem);

  DAOCadastro := TModelDAOCliente.New(
    FConexao,
    ConsultaCadastro,
    ComandoCadastro);

  Result := TControllerCliente.New(
    FConexao,
    DAOListagem,
    DAOCadastro);
end;

function TControllerFactory.CriarQuery: iQuery;
begin
  case FTipoAcesso of
    adFireDAC:
      Result := TModelQueryFireDAC.New(FConexao);

    adADO:
      Result := TModelQueryADO.New(FConexao);
  else
    raise Exception.Create('Tipo de acesso a dados invalido.');
  end;
end;

end.