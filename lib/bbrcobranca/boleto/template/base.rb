# -*- encoding: utf-8 -*-
#

module Bbrcobranca
  module Boleto
    module Template
      module Base
        extend self

        def define_template(template)
          case template
          when :rghost
            [Bbrcobranca::Boleto::Template::Rghost]
          when :rghost_carne
            [Bbrcobranca::Boleto::Template::RghostCarne]
          when :both
            [Bbrcobranca::Boleto::Template::Rghost, Bbrcobranca::Boleto::Template::RghostCarne]
          else
            [Bbrcobranca::Boleto::Template::Rghost]
          end
        end
      end
    end
  end
end
