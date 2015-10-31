module Aliyun
  module Oss
    module Struct
      class Part < Base
        # [Integer] :number the part number
        attr_accessor :number

        # [String] :etag the etag for the part
        attr_accessor :etag

        # Last Modified time
        attr_accessor :last_modified

        # Part size
        attr_accessor :size

        def last_modified=(last_modified)
          @last_modified = Time.parse(last_modified)
        end

        def part_number=(part_number)
          @number = part_number
        end

        def e_tag=(e_tag)
          @etag = e_tag
        end

        def to_hash
          if valid?
            {
              'PartNumber' => number,
              'ETag' => etag
            }
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
