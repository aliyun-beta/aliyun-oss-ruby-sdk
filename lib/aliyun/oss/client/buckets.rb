module Aliyun
  module Oss
    class Client
      module Buckets
        # List buckets
        #
        # @param (see #list_buckets)
        # @option (see #list_buckets)
        #
        # @return [Array<Aliyun::Oss::Struct::Bucket>]
        #
        # @see Client#list_buckets
        def list(options = {})
          result = client.list_buckets(options).parsed_response

          bucket_keys = %w(ListAllMyBucketsResult Buckets Bucket)
          Utils.wrap(Utils.dig_value(result, *bucket_keys)).map do |bucket_hash|
            build_bucket(bucket_hash, client)
          end
        end

        # Create bucket
        #
        # @param (see #bucket_create)
        #
        # @return [true]
        #
        # @see Client#bucket_create
        def create(*args)
          !!client.bucket_create(*args)
        end

        # Delete bucket
        #
        # @param (see #bucket_delete)
        #
        # @return [true]
        #
        # @see Client#bucket_delete
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
