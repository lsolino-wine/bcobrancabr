# -*- encoding: utf-8 -*-
#

require 'spec_helper'

RSpec.describe 'Bbrcobranca' do
  describe 'gerador' do
    context 'rghost' do
      before { Bbrcobranca.configuration.gerador = :rghost }

      it { expect(Bbrcobranca.configuration.gerador).to be(:rghost) }
    end

    context 'prawn' do
      before { Bbrcobranca.configuration.gerador = :prawn }

      it { expect(Bbrcobranca.configuration.gerador).to be(:prawn) }
    end
  end

  describe 'formato' do
    context 'pdf' do
      before { Bbrcobranca.configuration.formato = :pdf }

      it { expect(Bbrcobranca.configuration.formato).to be(:pdf) }
    end

    context 'gif' do
      before { Bbrcobranca.configuration.formato = :gif }

      it { expect(Bbrcobranca.configuration.formato).to be(:gif) }
    end
  end
end
