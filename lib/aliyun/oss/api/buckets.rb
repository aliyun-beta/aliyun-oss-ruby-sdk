module Aliyun
  module Oss
    module Api
      module Buckets
        # List buckets
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/service&GetService GetService (ListBucket
        #
        # @param options [Hash] options
        # @option options [String] :prefix Filter buckets with prefix
        # @option options [String] :marker Bucket name should after marker in alphabetical order
        # @option options [Integer] :max-keys (100) Limit number of buckets, the maxinum should <= 1000
        #
        # @return [Response]
        def list_buckets(options = {})
          Utils.stringify_keys!(options)
          query = Utils.hash_slice(options, 'prefix', 'marker', 'max-keys')
          http.get('/', query: query)
        end

        # Create bucket
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucket Put Bucket
        #
        # @example
        #  oss.client.bucket_create('oss-sdk-dev-hangzhou-xxx')
        #
        # @param name [String] Specify bucket name
        # @param location [String] Specify the bucket's data center location, can be one of below:
        #   oss-cn-hangzhou,oss-cn-qingdao,oss-cn-beijing,oss-cn-hongkong,
        #   oss-cn-shenzhen,oss-cn-shanghai,oss-us-west-1 ,oss-ap-southeast-1
        # @param acl [String] Specify the bucket's access. (see #bucket_set_acl)
        #
        # @raise [RequestError]
        #
        # @return [Response]
        def bucket_create(name, location = 'oss-cn-hangzhou', acl = 'private')
          query = { 'acl' => true }
          headers = { 'x-oss-acl' => acl }

          body = XmlGenerator.generate_create_bucket_xml(location)

          http.put('/', query: query, headers: headers, body: body, bucket: name, location: location)
        end

        # Delete bucket
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&DeleteBucket Delete Bucket
        #
        # @param name [String] bucket name want to delete
        #
        # @raise [RequestError]
        #
        # @return [Response]
        def bucket_delete(name)
          http.delete('/', bucket: name)
        end

        # OPTIONS Object
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/cors&OptionObject OPTIONS Object
        #
        # @param object_key [String] the object name want to visit.
        # @param origin [String] the requested source domain, denoting cross-domain request.
        # @param request_method [String] the actual request method will be used.
        # @param request_headers [Array<String>] the actual used headers except simple headers will be used.
        #
        # @raise [RequestError]
        #
        # @return [Response]
        def bucket_preflight(object_key, origin, request_method, request_headers = [])
          path = object_key ? "/#{object_key}" : '/'

          headers = {
            'Origin' => origin,
            'Access-Control-Request-Method' => request_method
          }

          unless request_headers.empty?
            value = request_headers.join(',')
            headers.merge!('Access-Control-Request-Headers' => value)
          end

          http.options(path, headers: headers, bucket: bucket, key: object_key)
        end
      end
    end
  end
end
