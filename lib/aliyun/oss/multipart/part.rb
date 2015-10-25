module Aliyun
  module Oss
    module Multipart
      class Part
        # [Integer] :number the part number
        attr_accessor :number

        # [String] :etag the etag for the part
        attr_accessor :etag

        def initialize(options = {})
          @number = options[:number]
          @etag = options[:etag]
        end

        def to_hash
          if valid?
            { "PartNumber" => number, "ETag" => etag }
          else
            {}
          end
        end

        private

        def valid?
          number && etag
        end
      end
    end
  end
end
