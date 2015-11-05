module Aliyun
  module Oss
    module Api
      module BucketObjects
        # List objects in the bucket
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucket Get Bucket (List Object)
        #
        # @param options [Hash] options
        # @option options [String] :prefix Filter objects with prefix
        # @option options [String] :marker Result should after marker in alphabetical order
        # @option options [Integer] :max-keys (100) Limit number of objects, the maxinum should <= 1000
        # @option options [String] :delimiter Used to group objects with delimiter
        # @option options [String] :encoding-type Encoding type used for unsupported character
        #
        # @return [Response]
        def bucket_list_objects(options = {})
          Utils.stringify_keys!(options)
          accepted_keys = ['prefix', 'marker', 'max-keys', 'delimiter', 'encoding-type']
          query = Utils.hash_slice(options, *accepted_keys)
          http.get('/', query: query, bucket: bucket)
        end

        # Upload file to bucket
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/object&PutObject Put Object
        #
        # @param key [String] Specify object name
        # @param file [File, Bin data] Specify need upload resource
        # @param [Hash] headers Specify other options
        # @option headers [String] :Content-Type ('application/x-www-form-urlencoded') Specify Content-Type for the object
        # @option headers [String] :Cache-Control Specify the caching behavior when download from browser, ref {https://www.ietf.org/rfc/rfc2616.txt?spm=5176.730001.3.128.Y5W4bu&file=rfc2616.txt RFC2616}
        # @option headers [String] :Content-Disposition Specify the name when download, ref {https://www.ietf.org/rfc/rfc2616.txt?spm=5176.730001.3.128.Y5W4bu&file=rfc2616.txt RFC2616}
        # @option headers [String] :Content-Encoding Specify the content encoding when download, ref {https://www.ietf.org/rfc/rfc2616.txt?spm=5176.730001.3.128.Y5W4bu&file=rfc2616.txt RFC2616}
        # @option headers [String] :Content-MD5 RFC 1864 according to the agreement of the message Content (not including head) are calculated MD5 value 128 bits number, the number is base64 encoding for the Content of a message - MD5 value.The legality of the examination of the request headers can be used for information (a message content is consistent with send).Although the request header is optional, OSS recommend that users use the end-to-end check request header.
        # @option headers [Integer] :Expires Specify the expiration time (milliseconds)
        # @option headers [String] :x-oss-server-side-encryption Specify the oss server-side encryption algorithm when the object was created. supported value: 'AES256'
        # @option headers [String] :x-oss-object-acl Specify the oss access when the object was created. supported value: public-read-write | public-read | private
        # @option headers [Hash] other options will insert into headers when upload, such as user meta headers, eg: headers with prefix: x-oss-meta-
        #
        # @return [Response]
        def bucket_create_object(key, file, headers = {})
          Utils.stringify_keys!(headers)
          http.put("/#{key}", headers: headers, body: Utils.to_data(file), bucket: bucket, key: key)
        end

        # Copy an existing object in OSS into another object
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/object&CopyObject Copy Object
        #
        # @param key [String] the object name
        # @param source_bucket [String] the source bucket name
        # @param source_key [String] the source object name
        # @param [Hash] headers
        # @option headers [String] :x-oss-copy-source-if-match If the specified ETag match the source object ETag, normal transfer and return 200; Otherwise return 412(precondition)
        # @option headers [String] :x-oss-copy-source-if-none-match If the specified ETag not match the source object ETag, normal transfer and return 200; Otherwise return 304(Not Modified)
        # @option headers [String] :x-oss-copy-source-if-unmodified-since If the specified time is equal to or later than the source object last modification time, normal transfer ans return 200; Otherwise returns 412(precondition)
        # @option headers [String] :x-oss-copy-source-if-modified-since If the specified time is earlier than the source object last modification time, normal transfer ans return 200; Otherwise returns 304(not modified)
        # @option headers [String] :x-oss-metadata-directive ('COPY') supported value: COPY, REPLACE;
        # @option headers [String] :x-oss-server-side-encryption supported value: AES256
        # @option headers [String] :x-oss-object-acl supported value: public-read, private, public-read-write
        #
        # @raise [RequestError]
        #
        # @return [Response]
        def bucket_copy_object(key, source_bucket, source_key, headers = {})
          fail('source_bucket must be not empty!') if source_bucket.nil? || source_bucket.empty?
          fail('source_key must be not empty!') if source_key.nil? || source_key.empty?

          Utils.stringify_keys!(headers)
          headers.merge!('x-oss-copy-source' => "/#{source_bucket}/#{source_key}")

          http.put("/#{key}", headers: headers, bucket: bucket, key: key)
        end

        # Append data to a object, will create Appendable object
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/object&AppendObject Append Object
        #
        # @param key [String] object name
        # @param file [file, bin data] the data to append
        # @param position [Integer] append to position of object
        # @option headers (see #bucket_create_object)
        #
        # @raise [RequestError]
        #
        # @return [Response]
        def bucket_append_object(key, file, position = 0, headers = {})
          Utils.stringify_keys!(headers)

          query = { 'append' => true, 'position' => position }
          body = Utils.to_data(file)

          http.post("/#{key}", query: query, headers: headers, body: body, bucket: bucket, key: key)
        end

        # Get the object
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/object&GetObject Get Object
        #
        # @param key [String] the object name
        # @param query [Hash] query params
        # @option query [String] :response-content-type Specify the header Content-Type in response
        # @option query [String] :response-content-language Specify the header Content-Language in response
        # @option query [String] :response-expires Specify the header Expires in response
        # @option query [String] :response-cache-control Specify the header Cache-Control in response
        # @option query [String] :response-content-disposition Specify the header Content-Disposition in response
        # @option query [String] :response-content-encoding Specify the header Content-encoding in response
        # @param headers [Hash] headers
        # @option headers [String] :Range Specify the range of the file. Such as "bytes=0-9" means the 10 characters from 0 to 9.
        # @option headers [String] :If-Modified-Since If the specified time is earlier than the file last modification time, return 200 OK; Otherwise returns 304(not modified)
        # @option headers [String] :If-Unmodified-Since If the specified time is equal to or later than the file last modification time, normal transfer ans return 200; Otherwise returns 412(precondition)
        # @option headers [String] :If-Match If the specified ETag match the object ETag, normal transfer and return 200; Otherwise return 412(precondition)
        # @option headers [String] :If-None-Match If the specified ETag not match the object ETag, normal transfer and return 200; Otherwise return 304(Not Modified)
        #
        # @return [Response]
        def bucket_get_object(key, query = {}, headers = {})
          Utils.stringify_keys!(query)
          Utils.stringify_keys!(headers)

          http.get("/#{key}", query: query, headers: headers, bucket: bucket, key: key)
        end

        # Get object share link
        #
        # @param key [String] the Object name
        # @param expired_in_seconds [Integer] expire after specify seconds
        #
        # @return [String]
        def bucket_get_object_share_link(key, expired_in_seconds)
          expire_time = Time.now.to_i + expired_in_seconds

          signature = Authorization.get_temporary_signature(
            @secret_key,
            expire_time,
            verb: 'GET',
            bucket: bucket,
            key: key
          )

          Utils.get_endpoint(bucket, @options[:host]) + "#{key}?" \
            "OSSAccessKeyId=#{@access_key}&Expires=#{expire_time}&Signature=#{signature}"
        end

        # Delete object from bucket
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/object&DeleteObject Delete Object
        #
        # @param key [String] the object name
        #
        # @return [Response]
        def bucket_delete_object(key)
          http.delete("/#{key}", bucket: bucket, key: key)
        end

        # Delete multiple objects, at max 1000 at once
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/object&DeleteMultipleObjects Delete Multiple Objects
        #
        # @param keys [Array<String>] the object names
        # @param quiet [Boolean] Specify response mode: false(Quiet) return results for error objects, true(Verbose) return results of every objects
        #
        # @return [Response]
        def bucket_delete_objects(keys, quiet = false)
          query = { 'delete' => true }

          body = XmlGenerator.generate_delete_objects_xml(keys, quiet)

          http.post('/', query: query, body: body, bucket: bucket)
        end

        # Get meta information of object
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/object&HeadObject Head Object
        #
        # @param key [String] object name
        # @param headers [Hash] headers
        # @option headers [String] :If-Modified-Since If the specified time is earlier than the file last modification time, return 200 OK; Otherwise returns 304(not modified)
        # @option headers [String] :If-Unmodified-Since If the specified time is equal to or later than the file last modification time, normal transfer ans return 200; Otherwise returns 412(precondition)
        # @option headers [String] :If-Match If the specified ETag match the object ETag, normal transfer and return 200; Otherwise return 412(precondition)
        # @option headers [String] :If-None-Match If the specified ETag not match the object ETag, normal transfer and return 200; Otherwise return 304(Not Modified)
        #
        # @raise [RequestError]
        #
        # @return [Response]
        def bucket_get_meta_object(key, headers = {})
          Utils.stringify_keys!(headers)
          http.head("/#{key}", headers: headers, bucket: bucket, key: key)
        end

        # Get access of object
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/object&GetObjectACL Get Object ACL
        #
        # @param key [String] object name
        #
        # @raise [RequestError]
        #
        # @return [Response]
        def bucket_get_object_acl(key)
          query = { 'acl' => true }
          http.get("/#{key}", query: query, bucket: bucket, key: key)
        end

        # Set access of object
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/object&PutObjectACL Put Object ACL
        #
        # @param key [String] object name
        # @param acl [String] access value, supported value: private, public-read, public-read-write
        #
        # @raise [RequestError]
        #
        # @return [Response]
        def bucket_set_object_acl(key, acl)
          query = { 'acl' => true }
          headers = { 'x-oss-object-acl' => acl }
          http.put("/#{key}", query: query, headers: headers, bucket: bucket, key: key)
        end
      end
    end
  end
end
