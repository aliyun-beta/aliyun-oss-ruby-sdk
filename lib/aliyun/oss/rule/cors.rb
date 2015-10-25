module Aliyun
  module Oss
    module Rule
      class Cors

        ACCESSPTED_METHODS = %w{GET PUT DELETE POST HEAD}

        # [Array] :allowed_origins Set allowed origins
        attr_accessor :allowed_origins

        # [Array] :allowed_methods Set allowed methods
        attr_accessor :allowed_methods

        # [Array] :allowed_headers Set allowed headers used in preflight (see #bucket_preflight)
        attr_accessor :allowed_headers

        # [Array] :expose_headers  Set allowed used response headers for user
        attr_accessor  :expose_headers

        # [Integer] :max_age_seconds Specifies cache time the browser to pre-fetch a particular resource request in seconds
        attr_accessor :max_age_seconds

        def initialize(options = {})
          @allowed_origins = options[:allowed_origins]
          @allowed_methods = options[:allowed_methods]
          @allowed_headers = options[:allowed_headers]
          @expose_headers  = options[:expose_headers]
          @max_age_seconds = options[:max_age_seconds]
        end

        def to_hash
          if valid?
            hash = {
              "AllowedOrigin" => allowed_origins,
              "AllowedMethod" => allowed_methods
            }
            hash.merge!("AllowedHeader" => allowed_headers) if value_present?(allowed_headers)
            hash.merge!("EsposeHeader" => expose_headers) if value_present?(expose_headers)
            hash.merge!("MaxAgeSeconds" => max_age_seconds) if max_age_seconds
            hash
          else
            {}
          end
        end

        private

        def valid?
          value_present?(allowed_origins) && value_present?(allowed_methods)
        end

        def allowed_methods
          @allowed_methods.map(&:upcase).select {|method| ACCESSPTED_METHODS.include?(method.to_s) }
        end

        def value_present?(value)
          value && !value.empty?
        end

      end
    end
  end
end
