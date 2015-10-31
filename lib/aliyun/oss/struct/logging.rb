module Aliyun
  module Oss
    module Struct
      class Logging < Base
        # Container for logging information. This element and its children are present when logging is enabled; otherwise, this element and its children are absent.
        attr_accessor :logging_enabled

        # This element specifies the bucket where server access logs will be delivered.
        attr_accessor :target_bucket

        # Specifies the prefix for the keys that the log files are being stored for.
        attr_accessor :target_prefix

        def initialize(attributes = {})
          @logging_enabled = false
          super
        end

        def logging_enabled=(logging_enabled)
          return @logging_enabled = false unless logging_enabled.is_a?(Hash)

          if logging_enabled.key?('TargetBucket')
            @target_bucket = logging_enabled['TargetBucket']
          end
          if logging_enabled.key?('TargetPrefix')
            @target_prefix = logging_enabled['TargetPrefix']
          end
          @logging_enabled = true
        end
      end
    end
  end
end
