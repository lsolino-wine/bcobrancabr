module Bbrcobranca
  module Boleto
    class SantanderAdimplere < Base
      attr_writer :codigo_barras, :nosso_numero_dv

      def codigo_barras
        instance_variable_get("@codigo_barras").remove(/\D/) rescue nil
      end

      def nosso_numero_dv
        instance_variable_get("@nosso_numero_dv").remove(/\D/) rescue nil
      end

      def logotipo
        if Bbrcobranca.configuration.gerador == :rghost_carne
          File.join(
            brcobranca_path, "lib", "bbrcobranca", "arquivos", "logos", "santander_carne.eps"
          )
        else
          File.join(brcobranca_path, "lib", "bbrcobranca", "arquivos", "logos", "santander.eps")
        end
      end

      validates_presence_of :convenio, message: 'não pode estar em branco.'
      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :convenio, maximum: 7, message: 'deve ser menor ou igual a 7 dígitos.'
      validates_length_of :nosso_numero, maximum: 8, message: 'deve ser menor ou igual a 8 dígitos.'

      def initialize(campos = {})
        campos = { carteira: '102' }.merge!(campos)
        super(campos)
      end

      def banco
        '033'
      end

      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(9, '0') if valor
      end

      def convenio=(valor)
        @convenio = valor.to_s.rjust(7, '0') if valor
      end

      def nosso_numero=(valor)
        @nosso_numero = valor.to_s.rjust(8, '0') if valor
      end

      def nosso_numero_boleto
        if nosso_numero_dv
          "#{nosso_numero}-#{nosso_numero_dv}"
        else
          nosso_numero
        end
      end

      def agencia_conta_boleto
        "#{agencia}/#{convenio}"
      end

      def codigo_barras_segunda_parte
        "9#{convenio}00000#{nosso_numero}#{nosso_numero_dv}0#{carteira}"
      end

      private

      def brcobranca_path
        @brcobranca_path ||= Gem::Specification.find_by_name("bbrcobranca").gem_dir
      end
    end
  end
end
