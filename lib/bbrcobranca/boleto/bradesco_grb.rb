module Bbrcobranca
  module Boleto
    class BradescoGRB < Base
      attr_writer :codigo_barras, :nosso_numero_dv

      def codigo_barras
        instance_variable_get("@codigo_barras").remove(/\D/) rescue nil
      end

      def nosso_numero_dv
        instance_variable_get("@nosso_numero_dv").remove(/\D/)
      end

      def logotipo
        if Bbrcobranca.configuration.gerador == :rghost_carne
          File.join(brcobranca_path, "lib", "bbrcobranca", "arquivos", "logos", "bradesco_carne.eps")
        else
          File.join(brcobranca_path, "lib", "bbrcobranca", "arquivos", "logos", "bradesco.eps")
        end
      end

      validates_length_of :agencia, maximum: 5, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :nosso_numero, maximum: 11,
                                         message: 'deve ser menor ou igual a 11 dígitos.'
      validates_length_of :conta_corrente, maximum: 7,
                                           message: 'deve ser menor ou igual a 7 dígitos.'
      validates_length_of :carteira, maximum: 2,
                                     message: 'deve ser menor ou igual a 2 dígitos.'

      def initialize(campos = {})
        campos = { carteira: '06' }.merge!(campos)

        campos[:local_pagamento] = 'Pagável preferencialmente na Rede Bradesco ou Bradesco Expresso'

        super(campos)
      end

      def banco
        '237'
      end

      def carteira; end

      def carteira=(valor)
        @carteira = valor.to_s.rjust(2, '0') if valor
      end

      def nosso_numero=(valor)
        @nosso_numero = valor.to_s.rjust(11, '0') if valor
      end

      def nosso_numero_boleto
        "#{nosso_numero}-#{nosso_numero_dv}"
      end

      def agencia_dv
        agencia.modulo11(
          multiplicador: [2, 3, 4, 5],
          mapeamento: { 10 => 'P', 11 => 0 }
        ) { |total| 11 - (total % 11) }
      end

      def conta_corrente_dv
        conta_corrente.modulo11(
          multiplicador: [2, 3, 4, 5, 6, 7],
          mapeamento: { 10 => 'P', 11 => 0 }
        ) { |total| 11 - (total % 11) }
      end

      def agencia_conta_boleto
        "#{agencia} / #{conta_corrente.rjust(9, '0')}"
      end

      def codigo_barras_segunda_parte
        "#{agencia}#{carteira}#{nosso_numero}#{conta_corrente}0"
      end

      private

      def brcobranca_path
        @brcobranca_path ||= Gem::Specification.find_by_name("bbrcobranca").gem_dir
      end
    end
  end
end
