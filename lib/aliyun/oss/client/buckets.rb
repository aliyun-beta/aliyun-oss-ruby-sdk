module Aliyun
  module Oss
    class Client
      module Buckets
        # List buckets
        #
        # @see Api::Buckets#list_buckets
        # @example (see Api::Buckets#list_buckets)
        # @param (see Api::Buckets#list_buckets)
        # @raise (see Api::Buckets#list_buckets)
        #
        # @return [Array<Aliyun::Oss::Struct::Bucket>]
        def list(options = {})
          result = client.list_buckets(options).parsed_response

          bucket_keys = %w(ListAllMyBucketsResult Buckets Bucket)
          Utils.wrap(Utils.dig_value(result, *bucket_keys)).map do |bucket_hash|
            build_bucket(bucket_hash, client)
          end
        end

        # Create bucket
        #
        # @see Api::Buckets#bucket_create
        # @example (see Api::Buckets#bucket_create)
        # @param (see Api::Buckets#bucket_create)
        # @raise (see Api::Buckets#bucket_create)
        #
        # @return [true]
        def create(*args)
          !!client.bucket_create(*args)
        end

        # Delete bucket
        #
        # @see Api::Buckets#bucket_delete
        # @example (see Api::Buckets#bucket_delete)
        # @param (see Api::Buckets#bucket_delete)
        # @raise (see Api::Buckets#bucket_delete)
        #
        # @return [true]
        def delete(*args)
          !!client.bucket_delete(*args)
        end

        private

        def build_bucket(bucket_hash, client)
          Struct::Bucket.new(bucket_hash).tap do |bucket|
            bucket.client = Client.new(
              client.access_key, client.secret_key, host: bucket.host, bucket: bucket.name
            )
          end
        end
      end
    end
  end
end
