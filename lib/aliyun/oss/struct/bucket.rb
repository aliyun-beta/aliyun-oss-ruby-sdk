module Aliyun
  module Oss
    module Struct
      class Bucket < Base
        # Bucket Name
        attr_accessor :name

        # Bucket Location
        attr_accessor :location

        # Createion date of Bucket
        attr_accessor :creation_date

        # reference to client
        attr_accessor :client

        def host
          "#{location}.aliyuncs.com"
        end

        # Get the location
        #
        # @return [String]
        #
        # @see Api::BucketProperty#bucket_get_location
        def location!
          result = client.bucket_get_location.parsed_response
          Utils.dig_value(result, 'LocationConstraint', '__content__') ||
            Utils.dig_value(result, 'LocationConstraint')
        end

        # Get Logging configration for bucket
        #
        # return [true]
        #
        # @see Api::BucketProperty#bucket_get_logging
        def logging!
          result = client.bucket_get_logging.parsed_response
          Struct::Logging.new(Utils.dig_value(result, 'BucketLoggingStatus'))
        end

        # Used to enable access logging.
        #
        # @see Api::BucketProperty#bucket_enable_logging
        # @example (see Api::BucketProperty#bucket_enable_logging)
        # @param (see Api::BucketProperty#bucket_enable_logging)
        # @raise (see Api::BucketProperty#bucket_enable_logging)
        #
        # @return [true]
        def enable_logging(*args)
          !!client.bucket_enable_logging(*args)
        end

        # Used to disable access logging.
        #
        # @param (see #bucket_disable_logging)
        #
        # @return [true]
        #
        # @see Api::BucketProperty#bucket_disable_logging
        def disable_logging
          !!client.bucket_disable_logging
        end

        # Get the acl
        #
        # @return [String]
        #
        # @see Api::BucketProperty#bucket_get_acl
        def acl!
          result = client.bucket_get_acl.parsed_response
          acl_keys = %w(AccessControlPolicy AccessControlList Grant)
          Utils.dig_value(result, *acl_keys)
        end

        # Set ACL for bucket
        #
        # @see Api::BucketProperty#bucket_set_acl
        # @example (see Api::BucketProperty#bucket_set_acl)
        # @param (see Api::BucketProperty#bucket_set_acl)
        # @raise (see Api::BucketProperty#bucket_set_acl)
        #
        # @return [true]
        def set_acl(*args)
          !!client.bucket_set_acl(*args)
        end

        # Get the CORS
        #
        # @return [Array<Aliyun::Oss::Struct::Cors>]
        #
        # @see Api::BucketProperty#bucket_get_cors
        def cors!
          result = client.bucket_get_cors.parsed_response
          cors_keys = %w(CORSConfiguration CORSRule)
          Utils.wrap(Utils.dig_value(result, *cors_keys)).map do |cors|
            Struct::Cors.new(cors)
          end
        end

        # Set CORS for bucket
        #
        # @see Api::BucketProperty#bucket_enable_cors
        # @example (see Api::BucketProperty#bucket_enable_cors)
        # @param (see Api::BucketProperty#bucket_enable_cors)
        # @raise (see Api::BucketProperty#bucket_enable_cors)
        #
        # @return [true]
        def enable_cors(*args)
          !!client.bucket_enable_cors(*args)
        end

        # Disable CORS for bucket
        #
        # @return [true]
        #
        # @see Api::BucketProperty#bucket_disable_cors
        def disable_cors
          !!client.bucket_disable_cors
        end

        # Get the website configuration
        #
        # @return [Aliyun::Oss::Rule::Website]
        #
        # @see Api::BucketProperty#bucket_get_website
        def website!
          result = client.bucket_get_website.parsed_response
          suffix_keys = %w(WebsiteConfiguration IndexDocument Suffix)
          error_keys = %w(WebsiteConfiguration ErrorDocument Key)
          Aliyun::Oss::Struct::Website.new(
            suffix: Utils.dig_value(result, *suffix_keys),
            error_key: Utils.dig_value(result, *error_keys)
          )
        end

        # Used to enable static website hosted mode.
        #
        # @see Api::BucketProperty#bucket_enable_website
        # @example (see Api::BucketProperty#bucket_enable_website)
        # @param (see Api::BucketProperty#bucket_enable_website)
        # @raise (see Api::BucketProperty#bucket_enable_website)
        #
        # @return [true]
        def enable_website(*args)
          !!client.bucket_enable_website(*args)
        end

        # Used to disable website hostted mode.
        #
        # @return [true]
        #
        # @see Api::BucketProperty#bucket_disable_website
        def disable_website
          !!client.bucket_disable_website
        end

        # Get the referer configuration
        #
        # @return [Aliyun::Oss::Struct::Referer]
        #
        # @see Api::BucketProperty#bucket_get_referer
        def referer!
          result = client.bucket_get_referer.parsed_response
          allow_empty = %w(RefererConfiguration AllowEmptyReferer)
          referers = %w(RefererConfiguration RefererList Referer)
          Aliyun::Oss::Struct::Referer.new(
            allow_empty: Utils.dig_value(result, *allow_empty),
            referers: Utils.dig_value(result, *referers)
          )
        end

        # Used to set referer for bucket.
        #
        # @see Api::BucketProperty#bucket_set_referer
        # @example (see Api::BucketProperty#bucket_set_referer)
        # @param (see Api::BucketProperty#bucket_set_referer)
        # @raise (see Api::BucketProperty#bucket_set_referer)
        #
        # @return [true]
        def set_referer(*args)
          !!client.bucket_set_referer(*args)
        end

        # Get the lifecycle configuration
        #
        # @return [Array<Aliyun::Oss::Struct::Lifecycle?]
        #
        # @see Api::BucketProperty#bucket_get_lifecycle
        def lifecycle!
          result = client.bucket_get_lifecycle.parsed_response
          lifecycle_keys = %w(LifecycleConfiguration Rule)
          Utils.wrap(Utils.dig_value(result, *lifecycle_keys)).map do |lifecycle|
            Struct::LifeCycle.new(lifecycle)
          end
        end

        # Used to enable and set lifecycle for bucket
        #
        # @param (see #bucket_enable_lifecycle)
        #
        # @raise (see #bucket_enable_lifecycle)
        #
        # @return [true]
        #
        # @see Client#bucket_enable_lifecycle
        def enable_lifecycle(*args)
          !!client.bucket_enable_lifecycle(*args)
        end

        # Used to disable lifecycle for bucket
        #
        # @return [true]
        #
        # @see Api::BucketProperty#bucket_disable_lifecycle
        def disable_lifecycle
          !!client.bucket_disable_lifecycle
        end

        # OPTIONS Object
        #
        # @see Api::BucketProperty#bucket_preflight
        # @example (see Api::BucketProperty#bucket_preflight)
        # @param (see Api::BucketProperty#bucket_preflight)
        # @raise (see Api::BucketProperty#bucket_preflight)
        #
        # @return [true]
        def preflight(*args)
          !!client.bucket_preflight(*args)
        end
        alias_method :options, :preflight
      end
    end
  end
end
