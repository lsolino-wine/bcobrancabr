# -*_ encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Bbrcobranca::Retorno::Cnab240::Base do
  let(:arquivo) { File.join(File.dirname(__FILE__), '..', '..', '..', 'arquivos', nome_arquivo) }

  describe "#load_lines" do
    it "retorna nil se o arquivo é nil" do
      expect(Bbrcobranca::Retorno::Cnab240::Base.load_lines(nil)).to be_nil
    end

    context "Sicoob" do
      let(:nome_arquivo) { "CNAB240SICOOB.RET" }

      subject { Bbrcobranca::Retorno::Cnab240::Sicoob }

      it "lê o arquivo pela classe do Sicoob" do
        expect(subject).to receive(:load_lines).with(arquivo, {})
        Bbrcobranca::Retorno::Cnab240::Base.load_lines(arquivo)
      end
    end
  end
end
