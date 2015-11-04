module Aliyun
  module Oss
    #
    # Here is some services used to make object based API possible, they are all contains a reference to instance of client, which used to do the real job.
    #
    # buckets: used to do many buckets operations eg: #list, #create, #delete
    #
    #   client.buckets
    #
    # bucket_objects: used to do some operation on objects eg: #list, #create, :delete, #copy
    #
    #   client.bucket_objects
    #
    # bucket_multiparts: used to do some operation for multiparts eg: #init, #list
    #
    #   client.bucket_multiparts
    #
    #
    class Client
      def buckets
        @services[:buckets] ||= Client::BucketsService.new(self)
      end

      def bucket_objects
        @services[:bucket_objects] ||= Client::BucketObjectsService.new(self)
      end

      def bucket_multiparts
        @services[:bucket_multiparts] ||= \
          Client::BucketMultipartsService.new(self)
      end

      def current_bucket
        @services[:current_bucket] ||= \
          Aliyun::Oss::Struct::Bucket.new(name: self.bucket, client: self)
      end

      ClientService = ::Struct.new(:client)

      require 'aliyun/oss/client/buckets'

      class BucketsService < ClientService
        include Client::Buckets
      end

      require 'aliyun/oss/client/bucket_objects'

      class BucketObjectsService < ClientService
        include Client::BucketObjects
      end

      require 'aliyun/oss/client/bucket_multiparts'

      class BucketMultipartsService < ClientService
        include Client::BucketMultiparts
      end
    end
  end
end
