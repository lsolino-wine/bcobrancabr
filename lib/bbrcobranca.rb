# -*- encoding: utf-8 -*-
#
require 'bbrcobranca/calculo'
require 'bbrcobranca/limpeza'
require 'bbrcobranca/formatacao'
require 'bbrcobranca/formatacao_string'
require 'bbrcobranca/calculo_data'
require 'bbrcobranca/currency'
require 'bbrcobranca/validations'
require 'bbrcobranca/util/date'

module Bbrcobranca
  # Exception lançada quando algum tipo de boleto soicitado ainda não tiver sido implementado.
  class NaoImplementado < RuntimeError
  end

  class ValorInvalido < StandardError
  end

  # Exception lançada quando os dados informados para o boleto estão inválidos.
  #
  # Você pode usar assim na sua aplicação:
  #   rescue Bbrcobranca::BoletoInvalido => invalido
  #   puts invalido.errors
  class BoletoInvalido < StandardError
    # Atribui o objeto boleto e pega seus erros de validação
    def initialize(boleto)
      errors = boleto.errors.full_messages.join(', ')
      super(errors)
    end
  end

  # Exception lançada quando os dados informados para o arquivo remessa estão inválidos.
  #
  # Você pode usar assim na sua aplicação:
  #   rescue Bbrcobranca::RemessaInvalida => invalido
  #   puts invalido.errors
  class RemessaInvalida < StandardError
    # Atribui o objeto boleto e pega seus erros de validação
    def initialize(remessa)
      errors = remessa.errors.full_messages.join(', ')
      super(errors)
    end
  end

  # Configurações do Bbrcobranca.
  #
  # Para mudar as configurações padrão, você pode fazer assim:
  # config/environments/test.rb:
  #
  #     Bbrcobranca.setup do |config|
  #       config.formato = :gif
  #     end
  #
  # Ou colocar em um arquivo na pasta initializer do rails.
  class Configuration
    # Gerador de arquivo de boleto.
    # @return [Symbol]
    # @param  [Symbol] (Padrão: :rghost)
    attr_accessor :gerador
    # Formato do arquivo de boleto a ser gerado.
    # @return [Symbol]
    # @param  [Symbol] (Padrão: :pdf)
    # @see http://wiki.github.com/shairontoledo/rghost/supported-devices-drivers-and-formats Veja mais formatos na documentação do rghost.
    attr_accessor :formato

    # Resolução em pixels do arquivo gerado.
    # @return [Integer]
    # @param  [Integer] (Padrão: 150)
    attr_accessor :resolucao

    # Ajusta o encoding do texto do boleto enviado para o GhostScript
    # O valor 'ascii-8bit' evita problemas com acentos e cedilha
    # @return [String]
    # @param  [String] (Padrão: nil)
    attr_accessor :external_encoding

    # Atribui valores padrões de configuração
    def initialize
      self.gerador = :rghost
      self.formato = :pdf
      self.resolucao = 150
      self.external_encoding = 'ascii-8bit'
    end
  end

  # Atribui os valores customizados para as configurações.
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Bloco para realizar configurações customizadas.
  def self.setup
    yield(configuration)
  end

  # Módulo para classes de boletos
  module Boleto
    autoload :Base,               'bbrcobranca/boleto/base'
    autoload :BancoNordeste,      'bbrcobranca/boleto/banco_nordeste'
    autoload :BancoBrasil,        'bbrcobranca/boleto/banco_brasil'
    autoload :BancoBrasilia,      'bbrcobranca/boleto/banco_brasilia'
    autoload :Itau,               'bbrcobranca/boleto/itau'
    autoload :Hsbc,               'bbrcobranca/boleto/hsbc'
    autoload :Bradesco,           'bbrcobranca/boleto/bradesco'
    autoload :Caixa,              'bbrcobranca/boleto/caixa'
    autoload :Sicoob,             'bbrcobranca/boleto/sicoob'
    autoload :Sicredi,            'bbrcobranca/boleto/sicredi'
    autoload :Unicred,            'bbrcobranca/boleto/unicred'
    autoload :Santander,          'bbrcobranca/boleto/santander'
    autoload :Banestes,           'bbrcobranca/boleto/banestes'
    autoload :Banrisul,           'bbrcobranca/boleto/banrisul'
    autoload :Credisis,           'bbrcobranca/boleto/credisis'
    autoload :Cecred,             'bbrcobranca/boleto/cecred'
    autoload :BradescoGRB,        'bbrcobranca/boleto/bradesco_grb'

    # Módulos para classes de template
    module Template
      autoload :Base,        'bbrcobranca/boleto/template/base'
      autoload :Rghost,      'bbrcobranca/boleto/template/rghost'
      autoload :RghostCarne, 'bbrcobranca/boleto/template/rghost_carne'
    end
  end

  # Módulos para classes de retorno bancário
  module Retorno
    autoload :Base,            'bbrcobranca/retorno/base'
    autoload :RetornoCbr643,   'bbrcobranca/retorno/retorno_cbr643'
    autoload :RetornoCnab240,  'bbrcobranca/retorno/retorno_cnab240'
    autoload :RetornoCnab400,  'bbrcobranca/retorno/retorno_cnab400' # DEPRECATED

    module Cnab400
      autoload :Base,          'bbrcobranca/retorno/cnab400/base'
      autoload :Bradesco,      'bbrcobranca/retorno/cnab400/bradesco'
      autoload :Banrisul,      'bbrcobranca/retorno/cnab400/banrisul'
      autoload :Itau,          'bbrcobranca/retorno/cnab400/itau'
      autoload :BancoNordeste, 'bbrcobranca/retorno/cnab400/banco_nordeste'
      autoload :BancoBrasilia, 'bbrcobranca/retorno/cnab400/banco_brasilia'
      autoload :Unicred,       'bbrcobranca/retorno/cnab400/unicred'
      autoload :Credisis,      'bbrcobranca/retorno/cnab400/credisis'
      autoload :Santander,     'bbrcobranca/retorno/cnab400/santander'
      autoload :BancoBrasil,   'bbrcobranca/retorno/cnab400/banco_brasil'
    end

    module Cnab240
      autoload :Base,          'bbrcobranca/retorno/cnab240/base'
      autoload :Santander,     'bbrcobranca/retorno/cnab240/santander'
      autoload :Cecred,        'bbrcobranca/retorno/cnab240/cecred'
      autoload :Sicredi,       'bbrcobranca/retorno/cnab240/sicredi'
      autoload :Sicoob,        'bbrcobranca/retorno/cnab240/sicoob'
      autoload :Caixa,         'bbrcobranca/retorno/cnab240/caixa'
    end
  end

  # Módulos para as classes que geram os arquivos remessa
  module Remessa
    autoload :Base,            'bbrcobranca/remessa/base'
    autoload :Pagamento,       'bbrcobranca/remessa/pagamento'

    module Cnab400
      autoload :Base,          'bbrcobranca/remessa/cnab400/base'
      autoload :BancoBrasil,   'bbrcobranca/remessa/cnab400/banco_brasil'
      autoload :Banrisul,      'bbrcobranca/remessa/cnab400/banrisul'
      autoload :Bradesco,      'bbrcobranca/remessa/cnab400/bradesco'
      autoload :Itau,          'bbrcobranca/remessa/cnab400/itau'
      autoload :Citibank,      'bbrcobranca/remessa/cnab400/citibank'
      autoload :Santander,     'bbrcobranca/remessa/cnab400/santander'
      autoload :Sicoob,        'bbrcobranca/remessa/cnab400/sicoob'
      autoload :BancoNordeste, 'bbrcobranca/remessa/cnab400/banco_nordeste'
      autoload :BancoBrasilia, 'bbrcobranca/remessa/cnab400/banco_brasilia'
      autoload :Unicred,       'bbrcobranca/remessa/cnab400/unicred'
      autoload :Credisis,      'bbrcobranca/remessa/cnab400/credisis'
    end

    module Cnab240
      autoload :Base,               'bbrcobranca/remessa/cnab240/base'
      autoload :BaseCorrespondente, 'bbrcobranca/remessa/cnab240/base_correspondente'
      autoload :Caixa,              'bbrcobranca/remessa/cnab240/caixa'
      autoload :Cecred,             'bbrcobranca/remessa/cnab240/cecred'
      autoload :BancoBrasil,        'bbrcobranca/remessa/cnab240/banco_brasil'
      autoload :Sicoob,             'bbrcobranca/remessa/cnab240/sicoob'
      autoload :SicoobBancoBrasil,  'bbrcobranca/remessa/cnab240/sicoob_banco_brasil'
      autoload :Sicredi,            'bbrcobranca/remessa/cnab240/sicredi'
      autoload :Unicred,            'bbrcobranca/remessa/cnab240/unicred'
    end
  end

  # Módulos para classes de utilidades
  module Util
    autoload :Empresa, 'bbrcobranca/util/empresa'
    autoload :Errors, 'bbrcobranca/util/errors'
  end
end
