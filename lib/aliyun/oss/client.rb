require 'aliyun/oss/api/buckets'
require 'aliyun/oss/api/bucket_property'
require 'aliyun/oss/api/bucket_objects'
require 'aliyun/oss/api/bucket_multiparts'
require 'aliyun/oss/client/clients'

module Aliyun
  module Oss
    class Client
      include Aliyun::Oss::Api::Buckets
      include Aliyun::Oss::Api::BucketProperty
      include Aliyun::Oss::Api::BucketObjects
      include Aliyun::Oss::Api::BucketMultiparts

      attr_reader :access_key, :secret_key, :bucket

      # Initialize a object
      #
      # @example
      #   Aliyun::Oss::Client.new("ACCESS_KEY", "SECRET_KEY", host: "oss-cn-beijing.aliyuncs.com", bucket: 'oss-sdk-beijing')
      #
      # @param access_key [String] access_key obtained from aliyun
      # @param secret_key [String] secret_key obtained from aliyun
      # @option options [String] :host host for bucket's data center
      # @option options [String] :bucket Bucket name
      #
      # @return [Response]
      def initialize(access_key, secret_key, options = {})
        @access_key = access_key
        @secret_key = secret_key
        @options = options
        @bucket = options[:bucket]

        @services = {}
      end

      private

      def http
        @http ||= Http.new(access_key, secret_key, @options[:host])
      end
    end
  end
end
