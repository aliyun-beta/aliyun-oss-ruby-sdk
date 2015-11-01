module Aliyun
  module Oss
    module Struct
      class Referer < Base
        # specify allow empty referer access
        attr_accessor :allow_empty

        # specify white list for allows referers
        attr_accessor :referers

        def allow_empty=(allow_empty)
          @allow_empty = allow_empty == 'true'
        end

        def referers=(referers)
          @referers = Utils.wrap(referers).map(&:strip)
        end
      end
    end
  end
end
