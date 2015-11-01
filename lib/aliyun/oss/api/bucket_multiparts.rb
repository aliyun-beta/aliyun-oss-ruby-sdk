module Aliyun
  module Oss
    module Api
      module BucketMultiparts
        # Initialize a Multipart Upload event, before using Multipart Upload mode to transmit data, we has to call the interface to notify the OSS initialize a Multipart Upload events.
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/multipart-upload&InitiateMultipartUpload Initiate Multipart Upload
        #
        # @param key [String] object name
        # @param headers [Hash] headers
        # @option headers [String] :Content-Type ('application/x-www-form-urlencoded') Specify Content-Type for the object
        # @option headers [String] :Cache-Control Specify the caching behavior when download from browser, ref https://www.ietf.org/rfc/rfc2616.txt?spm=5176.730001.3.128.Y5W4bu&file=rfc2616.txt RFC2616}
        # @option headers [String] :Content-Disposition Specify the name when download, ref https://www.ietf.org/rfc/rfc2616.txt?spm=5176.730001.3.128.Y5W4bu&file=rfc2616.txt RFC2616}
        # @option headers [String] :Content-Encoding Specify the content encoding when download, ref https://www.ietf.org/rfc/rfc2616.txt?spm=5176.730001.3.128.Y5W4bu&file=rfc2616.txt RFC2616}
        # @option headers [Integer] :Expires Specify the expiration time (milliseconds)
        # @option headers [String] :x-oss-server-side-encryption Specify the oss server-side encryption algorithm when the object was created. supported value: 'AES256'#
        #
        # @return [Response]
        def bucket_init_multipart(key, headers = {})
          query = { 'uploads' => true }
          http.post("/#{key}", query: query, headers: headers, bucket: bucket, key: key)
        end

        # Upload object in part.
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/multipart-upload&UploadPart Upload Part
        #
        # @param key [String] object name
        # @param number [Integer] the part number, Range in 1~10000.
        # @param upload_id [String] the upload ID return by #bucket_init_multipart
        # @param file [File, bin data] the upload data
        #
        # @raise [RequestError]
        # @raise [MultipartPartNumberEmptyError]
        # @raise [MultipartUploadIdEmptyError]
        #
        # @return [Response]
        def bucket_multipart_upload(upload_id, key, number, file)
          fail MultipartPartNumberEmptyError if number.nil?
          fail MultipartUploadIdEmptyError if upload_id.nil? || upload_id.empty?

          query = { 'partNumber' => number.to_s, 'uploadId' => upload_id }

          http.put("/#{key}", query: query, body: Utils.to_data(file), bucket: bucket, key: key)
        end

        # Upload a Part from an existing Object Copy data.
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/multipart-upload&UploadPartCopy Upload Part Copy
        #
        # @param key [String] object name
        # @param number [Integer] the part number, Range in 1~10000.
        # @param upload_id [String] the upload ID return by #bucket_init_multipart
        # @param options [Hash] options
        # @option options [String] :source_bucket the source bucket name
        # @option options [String] :source_key the source object name
        # @option options [String] :range the Range bytes, not set means the whole object, eg: bytes=100-6291756
        # @option options [String] :x-oss-copy-source-if-match If the specified ETag match the source object ETag, normal transfer and return 200; Otherwise return 412(precondition)
        # @option options [String] :x-oss-copy-source-if-none-match If the specified ETag not match the source object ETag, normal transfer and return 200; Otherwise return 304(Not Modified)
        # @option options [String] :x-oss-copy-source-if-unmodified-since If the specified time is equal to or later than the source object last modification time, normal transfer ans return 200; Otherwise returns 412(precondition)
        # @option options [String] :x-oss-copy-source-if-modified-since If the specified time is earlier than the source object last modification time, normal transfer ans return 200; Otherwise returns 304(not modified)
        #
        # @raise [RequestError]
        # @raise [MultipartSourceBucketEmptyError]
        # @raise [MultipartSourceKeyEmptyError]
        #
        # @return [Response]
        def bucket_multipart_copy_upload(upload_id, key, number, options = {})
          source_bucket = options.delete(:source_bucket).to_s
          source_key = options.delete(:source_key).to_s
          range = options.delete(:range)

          fail MultipartSourceBucketEmptyError if source_bucket.empty?
          fail MultipartSourceKeyEmptyError if source_key.empty?

          query = { 'partNumber' => number, 'uploadId' => upload_id }
          headers = copy_upload_headers(source_bucket, source_key, range, options)

          http.put("/#{key}", query: query, headers: headers, bucket: bucket, key: key)
        end

        # Complete a Multipart Upload event.
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/multipart-upload&CompleteMultipartUpload Complete Multipart Upload
        #
        # @param key [String] object name
        # @param upload_id [String] the upload ID return by #bucket_init_multipart
        # @param parts [Array<Aliyun::Oss::Multipart:Part>] parts
        #
        # @raise [RequestError]
        # @raise [MultipartPartsEmptyError]
        # @raise [MultipartUploadIdEmptyError]
        #
        # @return [Response]
        def bucket_complete_multipart(upload_id, key, parts = [])
          fail MultipartPartsEmptyError if parts.nil? || parts.empty?
          fail MultipartUploadIdEmptyError if upload_id.nil?

          query = { 'uploadId' => upload_id }

          body = XmlGenerator.generate_complete_multipart_xml(parts)

          http.post("/#{key}", query: query, body: body, bucket: bucket, key: key)
        end

        # Abort a Multipart Upload event
        #
        # @note After abort the Multipart Upload, the Uploaded data will be deleted
        # @note When abort a Multipart Upload event, if there are still part upload belonging to this event, then theree parts will not be removed. So if there is a concurrent access, in order to release the space on the OSS completely, you need to call #bucket_abort_multipart a few times.
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/multipart-upload&AbortMultipartUpload Abort Multipart Upload
        #
        # @param key [String] the object name
        # @param upload_id [String] the upload ID return by #bucket_init_multipart
        #
        # @raise [RequestError]
        #
        # @return [Response]
        def bucket_abort_multipart(upload_id, key)
          query = { 'uploadId' => upload_id }
          http.delete("/#{key}", query: query, bucket: bucket, key: key)
        end

        # List existing opened Multipart Upload event.
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/multipart-upload&ListMultipartUploads List Multipart Uploads
        #
        # @param options [Hash] options
        # @option options [String] :prefix Filter objects with prefix
        # @option options [String] :delimiter Used to group objects with delimiter
        # @option options [Integer] :max-uploads (1000) Limit number of Multipart Upload events, the maxinum should <= 1000
        # @option options [String] :encoding-type Encoding type used for unsupported character
        # @option options [String] :key-marker with upload-id-marker used to specify the result range.
        # @option options [String] :upload-id-marker with key-marker used to specify the result range.
        #
        # @return [Response]
        def bucket_list_multiparts(options = {})
          accepted_keys = ['prefix', 'key-marker', 'upload-id-marker', 'max-uploads', 'delimiter', 'encoding-type']

          query = Utils.hash_slice(options, *accepted_keys)
                  .merge('uploads' => true)

          http.get('/', query: query, bucket: bucket)
        end

        # List uploaded parts for Multipart Upload event
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/multipart-upload&ListParts List Parts
        #
        # @param key [String] the object name
        # @param upload_id [Integer] the upload ID return by #bucket_init_multipart
        # @param options [Hash] options
        # @option options [Integer] :max-parts (1000) Limit number of parts, the maxinum should <= 1000
        # @option options [Integer] :part-number-marker Specify the start part, return parts which number large than the specified value
        # @option options [String] :encoding-type Encoding type used for unsupported character in xml 1.0
        #
        # @return [Response]
        def bucket_list_parts(upload_id, key, options = {})
          accepted_keys = ['max-parts', 'part-number-marker', 'encoding-type']

          query = Utils.hash_slice(options, *accepted_keys).merge('uploadId' => upload_id)

          http.get("/#{key}", query: query, bucket: bucket, key: key)
        end

        private

        def copy_upload_headers(source_bucket, source_key, range, options)
          copy_source = "/#{source_bucket}/#{source_key}"

          headers = {}
          headers.merge!('x-oss-copy-source' => copy_source)
          headers.merge!('x-oss-copy-source-range' => range) if range
          headers.merge!(options)
          headers
        end
      end
    end
  end
end
