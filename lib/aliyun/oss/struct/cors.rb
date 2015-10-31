module Aliyun
  module Oss
    module Struct
      class Cors < Base
        ACCESSPTED_METHODS = %w(GET PUT DELETE POST HEAD)

        # Set allowed origins. [Array]
        attr_accessor :allowed_origin

        # Set allowed methods. [Array]
        attr_accessor :allowed_method

        # Set allowed headers used in preflight (see #bucket_preflight). [Array]
        attr_accessor :allowed_header

        # Set allowed used response headers for user. [Array]
        attr_accessor :expose_header

        # Specifies cache time the browser to pre-fetch a particular resource request in seconds. [Integer]
        attr_accessor :max_age_seconds

        def allowed_origin=(allowed_origin)
          @allowed_origin = Utils.wrap(allowed_origin)
        end

        def allowed_method=(allowed_method)
          @allowed_method = Utils.wrap(allowed_method)
            .map(&:upcase)
            .select { |method| ACCESSPTED_METHODS.include?(method.to_s) }
        end

        def allowed_header=(allowed_header)
          @allowed_header = Utils.wrap(allowed_header)
        end

        def expose_header=(expose_header)
          @expose_header = Utils.wrap(expose_header)
        end

        def to_hash
          if valid?
            attrs = {
              'AllowedOrigin' => allowed_origin,
              'AllowedMethod' => allowed_method
            }
            attrs.merge!('AllowedHeader' => allowed_header) if value_present?(allowed_header)
            attrs.merge!('EsposeHeader' => expose_header) if value_present?(expose_header)
            attrs.merge!('MaxAgeSeconds' => max_age_seconds) if max_age_seconds
            attrs
          else
            {}
          end
        end

        def valid?
          value_present?(allowed_origin) && value_present?(allowed_method)
        end

        private

        def value_present?(value)
          value && !value.empty?
        end
      end
    end
  end
end
