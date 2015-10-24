require 'base64'
require 'openssl'
require 'digest'
require 'pry'
require 'httparty'

module Aliyun
  module Oss
    class Client
      attr_reader :access_key, :secret_key, :bucket

      # Initialize a object
      #
      # @example
      #   Aliyun::Oss::Client.new("ACCESS_KEY", "SECRET_KEY", host: "#bucket_name#.oss-cn-beijing.aliyuncs.com", bucket: '#bucket_name#')
      #
      # @param access_key [String] access_key obtained from aliyun
      # @param secret_key [String] secret_key obtained from aliyun
      # @option options [String] :host host for bucket's data center
      # @option options [String] :bucket Bucket name
      #
      # @return [Client] the object
      def initialize(access_key, secret_key, options = {})
        @access_key = access_key
        @secret_key = secret_key
        @options = options
        @bucket = options[:bucket]
      end

      # List buckets
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/service&GetService GetService (ListBucket
      #
      # @param options [Hash] options
      # @option options [String] :prefix Filter buckets with prefix
      # @option options [String] :marker Bucket name should after marker in alphabetical order
      # @option options [Integer] :max-keys (100) Limit number of buckets, the maxinum should <= 1000
      #
      # @return [Object{buckets}]
      def list_buckets(options = {})
        query = options.select {|k, _| ['prefix', 'marker', 'max-keys'].include?(k.to_s) }
        http.get('/', query: query)
      end

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
      # @return [Object{objects}]
      def bucket_list_objects(options = {})
        query = options.select do |k, _|
          ['prefix', 'marker', 'max-keys', 'delimiter', 'encoding-type'].include?(k.to_s)
        end
        http.get('/', query: query, bucket: bucket)
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
      # @return [Response]
      def bucket_create(name, location = 'oss-cn-hangzhou', acl = 'private')
        host = "#{name}.#{location}.aliyuncs.com"
        query = { 'acl' => true }
        headers = { 'x-oss-acl' => acl, 'Host' => host }

        configuration = { "CreateBucketConfiguration" => { "LocationConstraint" => location }}
        body = XmlBuilder.to_xml(configuration)

        http.put("/", query: query, headers: headers, body: body, bucket: name)
      end

      # Delete bucket
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&DeleteBucket Delete Bucket
      #
      # @param name [String] bucket name want to delete
      #
      # @return [Response]
      def bucket_delete(name)
        http.delete("/", bucket: name)
      end

      # Used to modify the bucket access.
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketACL Put Bucket Acl
      #
      # @param acl [String] supported value: public-read-write | public-read | private
      def bucket_set_acl(acl)
        query = { 'acl' => true }
        headers = { 'x-oss-acl' => acl }
        http.put('/', query: query, headers: headers, bucket: bucket)
      end

      # Used to enable access logging.
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketLogging Put Bucket Logging
      #
      # @param target_bucket [String] specifies the bucket where you want Aliyun OSS to store server access logs.
      # @param target_prefix [String] this element lets you specify a prefix for the objects that the log files will be stored.
      def bucket_enable_logging(target_bucket, target_prefix = nil)
        logging = { "TargetBucket" => target_bucket }
        logging.merge!("TargetPrefix" => target_prefix) if target_prefix
        body = XmlBuilder.to_xml({ "BucketLoggingStatus" => { "LoggingEnabled" => logging }})
        query = { 'logging' => true }
        http.put('/', query: query, body: body, bucket: bucket)
      end

      # Used to disable access logging.
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&DeleteBucketLogging Delete Bucket Logging
      def bucket_disable_logging
        query = { 'logging' => false }
        http.delete('/', query: query, bucket: bucket)
      end

      # Used to enable static website hosted mode.
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketWebsite Put Bucket Website
      #
      # @param suffix [String] A suffix that is appended to a request that is for a directory on the website endpoint (e.g. if the suffix is index.html and you make a request to samplebucket/images/ the data that is returned will be for the object with the key name images/index.html) The suffix must not be empty and must not include a slash character.
      # @param key [String] The object key name to use when a 4XX class error occurs
      def bucket_enable_website(suffix, key = nil)
        query = { 'website' => true }
        website_configuration = { "IndexDocument" => { "Suffix" => suffix } }
        website_configuration.merge!("ErrorDocument" => { "Key" => key }) if key
        body = XmlBuilder.to_xml({ "WebsiteConfiguration" => website_configuration })
        headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
        http.put('/', query: query, headers: headers, body: body, bucket: bucket)
      end

      # Used to disable website hostted mode.
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&DeleteBucketWebsite Delete Bucket Website
      def bucket_disable_website
        query = { 'website' => true }
        http.delete('/', query: query, bucket: bucket)
      end

      # Used to set referer for bucket.
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketReferer Put Bucket Referer
      #
      # @param referers [Array<String>] white list for allowed referer.
      # @param allowed_empty [Boolean] whether allow empty refer.
      def bucket_set_referer(referers = [], allowed_empty = false)
        query = { 'referer' => true }
        referer_configuration = { "RefererConfiguration" => { "AllowEmptyReferer" => allowed_empty, "RefererList" => { "Referer" => referers }}}
        body = XmlBuilder.to_xml(referer_configuration)
        query = { 'referer' => true }
        http.put('/', query: query, body: body, bucket: bucket)
      end

      # Used to enable and set lifecycle for bucket
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketLifecycle Put Bucket Lifecycle
      #
      # @param rules [Array<Hash>] rules for lifecycle
      # @option rule [Integer] :id optional, Rule ID, auto set when not set
      # @option rule [String] :prefix, Used for filter objects
      # @option rule [Boolean] :enable, Used for set rule status
      # @option rule [Integer] :days Set auto delete objects after days since last modified, at least exist one with date
      # @option rule [Time] :date, Set auto auto delete object at given time, at least exist one with days
      def bucket_enable_lifecycle(rules = [])
        rules_configuration = []
        rules.each do |rule|
          id = rule.fetch("id", "")
          prefix = rule["prefix"]
          fail "Missing prefix for rule" unless prefix
          status = rule.fetch("enable", false) ? 'Enabled' : 'Disabled'
          expiration =
            if rule.key?("date") && rule['date'].is_a?(Time)
              { "Date" => rule['date'].utc.strftime("%Y-%m-%dT00:00:00.000Z") }
            elsif rule.key?("days") && rule['days'].is_a?(Integer)
              { "Days" => rule['days'].to_i }
            else
              fail "Must contains days or date for rule: days must be integer and date must be a Time Object"
            end
          rules_configuration << { "ID" => id, "Prefix" => prefix, "Status" => status, "Expiration" => expiration }
        end
        lifecycle_configuration = { "LifecycleConfiguration" => { "Rule" => rules_configuration } }
        body = XmlBuilder.to_xml(lifecycle_configuration)
        query = { 'lifecycle' => true }
        http.put('/', query: query, body: body, bucket: bucket)
      end

      # Used to disable lifecycle for bucket.
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&DeleteBucketLifecycle Delete Bucket Lifecycle
      def bucket_disable_lifecycle
        query = { 'lifecycle' => false }
        http.delete('/', query: query, bucket: bucket)
      end

      # Used to enable CORS and set rules for bucket
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/cors&PutBucketcors Put Bucket cors
      #
      # @param rules [Array<Hash>] array of rule
      # each rule contains:
      # @option rule [Array] :allowed_origins Set allowed origins
      # @option rule [Array] :allowed_methods Set allowed methods
      # @option rule [Array] :allowed_headers Set allowed headers used in preflight (see #bucket_preflight)
      # @option rule [Array] :expose_headers  Set allowed used response headers for user
      # @option rule [Integer] :max_age_seconds Specifies cache time the browser to pre-fetch a particular resource request in seconds
      def bucket_enable_cors(rules = [])
        rules_configuration = []
        rules.each do |rule|
          allowed_origins = rule['allowed_origins']
          fail "Missing allowed_origins for rule" if allowed_origins.nil? || allowed_origins.empty?
          allowed_methods = rule['allowed_methods']
          allowed_methods.map!(&:upcase).select! {|method| %w{GET PUT DELETE POST HEAD}.include?(method) }
          fail "Missing allowed_methods for rule OR allow_methods not in {GET PUT DELETE POST HEAD}" if allowed_methods.nil? || allowed_methods.empty?
          configuration = { "AllowedOrigin" => allowed_origins, "AllowedMethod" => allowed_methods }
          configuration.merge!("AllowedHeader" => rule['allowed_headers']) if rule['allowed_headers'] && !rule['allowed_headers'].empty?
          configuration.merge!("EsposeHeader" => rule['espose_headers']) if rule['espose_headers'] && !rule['espose_headers'].empty?
          configuration.merge!("MaxAgeSeconds" => rule['max_age_seconds']) if rule['max_age_seconds'] && !rule['max_age_seconds'].empty?
          rules_configuration << configuration
        end
        cors_configuration = { "CORSConfiguration" => { "CORSRule" => rules_configuration } }
        body = XmlBuilder.to_xml(cors_configuration)
        query = { 'cors' => true }
        http.put('/', query: query, body: body, bucket: bucket)
      end

      # Used to disable cors and clear rules for bucket
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/cors&DeleteBucketcors Delete Bucket cors
      def bucket_disable_cors
        query = { 'cors' => false }
        http.delete('/', query: query, bucket: bucket)
      end

      # OPTIONS Object
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/cors&OptionObject OPTIONS Object
      #
      # @param origin [String] the requested source domain, denoting cross-domain request.
      # @param request_method [String] the actual request method will be used.
      # @param request_headers [Array<String>] the actual used headers except simple headers will be used.
      # @param object_name [String] the object name will be visit.
      #
      # @return [Response]
      def bucket_preflight(origin, request_method, request_headers = [], object_name = nil)
        uri = object_name ? "/#{object_name}" : "/"

        headers = { 'Origin' => origin, 'Access-Control-Request-Method' => request_method }
        unless request_headers.empty?
          headers.merge!('Access-Control-Request-Headers' => request_headers.join(','))
        end

        http.options(uri, headers: headers, bucket: bucket, key: object_name)
      end

      # Get ACL for bucket
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketAcl Get Bucket ACL
      #
      # @return [String] public-read-write | public-read | private
      def bucket_get_acl
        query = { 'acl' => true }
        http.get('/', query: query, bucket: bucket)
      end

      # Get the location information of the Bucket's data center
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketLocation Get Bucket Location
      #
      # @return [String] one of [oss-cn-hangzhou，oss-cn-qingdao，oss-cn-beijing，oss-cn-hongkong，
      #   oss-cn-shenzhen，oss-cn-shanghai，oss-us-west-1，oss-ap-southeast-1]
      def bucket_get_location
        query = { 'location' => true }
        http.get('/', query: query, bucket: bucket)
      end

      # Get the log configuration of Bucket
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketLogging Get Bucket Logging
      #
      # @return [loggingConfiguration]
      def bucket_get_logging
        query = { 'logging' => true }
        http.get('/', query: query, bucket: bucket)
      end

      # Get the bucket state of static website hosting.
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketWebsite Get Bucket Website
      #
      # @return [websiteConfiguration]
      def bucket_get_website
        query = { 'website' => true }
        http.get('/', query: query, bucket: bucket)
      end

      # Get the referer configuration of bucket
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketReferer Get Bucket Referer
      #
      # @return [refererConfiguration]
      def bucket_get_referer
        query = { 'referer' => true }
        http.get('/', query: query, bucket: bucket)
      end

      # Get the lifecycle configuration of bucket
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketLifecycle Get Bucket Lifecycle
      #
      # @return [LifeCycleConfiguration]
      def bucket_get_lifecycle
        query = { 'lifecycle' => true }
        http.get('/', query: query, bucket: bucket)
      end

      # Get the CORS rules of bucket
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/cors&GetBucketcors Get Bucket cors
      #
      # @return [CorsConfiguration]
      def bucket_get_cors
        query = { 'cors' => true }
        http.get('/', query: query, bucket: bucket)
      end

      # Upload file to bucket
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/object&PutObject Put Object
      #
      # @param key [String] Specify object name
      # @param file [File, bin data] Specify need upload resource
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
        body = file.respond_to?(:read) ? IO.binread(file) : file
        http.put("/#{key}", headers: headers, body: body, bucket: bucket, key: key)
      end

      # Create object via post
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/object&PostObject Post Object
      def bucket_post_object(key)
        
      end

      # Copy an existing object in OSS into another object
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/object&CopyObject Copy Object
      #
      # @param key [String] the object name
      # @param source_bucket [String] the source bucket name
      # @param source_key [String] the source object name
      # @option headers (see #bucket_create_object)
      #
      # @return [Response]
      def bucket_copy_object(key, source_bucket, source_key, headers = {})
        fail("source_bucket must be not empty!") if source_bucket.nil? || source_bucket.empty?
        fail("source_key must be not empty!") if source_key.nil? || source_key.empty?

        headers.merge!( "x-oss-copy-source" => "/#{source_bucket}/#{source_key}" )

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
      def bucket_append_object(key, file, position = 0, headers = {})
        query = { "append" => true, "position" => position }

        body = file.respond_to?(:read) ? IO.binread(file) : file

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
      def bucket_get_object(key, query = {}, headers = {})
        http.get("/#{key}", query: query, headers: headers, bucket: bucket, key: key)
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
        query = { "delete" => true }

        key_objects = keys.map {|key| { "Key" => key } }
        body = XmlBuilder.to_xml({ "Delete" => { "Object" => key_objects, "Quiet" => quiet }})

        http.post("/", query: query, body: body, bucket: bucket)
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
      # @return [Response]
      def bucket_get_meta_object(key, headers = {})
        http.head("/#{key}", headers: headers, bucket: bucket, key: key)
      end

      # Get access of object
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/object&GetObjectACL Get Object ACL
      #
      # @param key [String] object name
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
      # @return [Response]
      def bucket_set_object_acl(key, acl)
        query = { 'acl' => true }
        headers = { 'x-oss-object-acl' => acl }
        http.put("/#{key}", query: query, headers: headers, bucket: bucket, key: key)
      end

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
        query = { "uploads" => true }
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
      # @return [Response]
      def bucket_multipart_upload(key, number, upload_id, file)
        fail("number must not empty!") if number.nil?
        fail("upload_id must not empty!") if upload_id.nil? || upload_id.empty?

        query = { "partNumber" => number.to_s, "uploadId" => upload_id }

        body = file.respond_to?(:read) ? IO.binread(file) : file

        http.put("/#{key}", query: query, body: body, bucket: bucket, key: key)
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
      # @option options [String] :range the Range bytes, not set means the whole object
      # @option options [String] :x-oss-copy-source-if-match If the specified ETag match the source object ETag, normal transfer and return 200; Otherwise return 412(precondition)
      # @option options [String] :x-oss-copy-source-if-none-match If the specified ETag not match the source object ETag, normal transfer and return 200; Otherwise return 304(Not Modified)
      # @option options [String] :x-oss-copy-source-if-unmodified-since If the specified time is equal to or later than the source object last modification time, normal transfer ans return 200; Otherwise returns 412(precondition)
      # @option options [String] :x-oss-copy-source-if-modified-since If the specified time is earlier than the source object last modification time, normal transfer ans return 200; Otherwise returns 304(not modified)
      #
      # @return [Response]
      def bucket_multipart_copy_upload(key, number, upload_id, options = {})
        fail("source_bucket must not empty!") if options[:source_bucket].to_s.empty?
        fail("source_key must not empty!") if options[:source_key].to_s.empty?

        query = { "partNumber" => number, "uploadId" => upload_id }

        headers = {}

        source_bucket = options.delete(:source_bucket)
        source_key = options.delete(:source_key)
        headers.merge!( "x-oss-copy-source" => "/#{source_bucket}/#{source_key}" )
        headers.merge!( "x-oss-copy-source-range" => options.delete(:range)) if options.key?(:range)

        headers.merge!(options)

        http.put("/#{key}", query: query, headers: headers, bucket: bucket, key: key)
      end

      # Complete a Multipart Upload event.
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/multipart-upload&CompleteMultipartUpload Complete Multipart Upload
      #
      # @param key [String] object name
      # @param upload_id [String] the upload ID return by #bucket_init_multipart
      # @param parts [Array<Hash>] parts
      # @option part [Integer] :number the part number
      # @option part [String] :etag the etag for the part
      #
      # @return [Response]
      def bucket_complete_multipart(key, upload_id, parts = [])
        fail("upload_id must not empty!") if upload_id.nil? || upload_id.empty?
        fail("parts must not empty!") if parts.nil? || parts.empty?

        query = { "uploadId" => upload_id }

        part_objects = parts.map {|part| { "PartNumber" => part[:number], "ETag" => part[:etag] } }
        body = XmlBuilder.to_xml({ "CompleteMultipartUpload" => { "Part" => part_objects } })

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
      # @return [Response]
      def bucket_abort_multipart(key, upload_id)
        query = { "uploadId" => upload_id }
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
      def bucket_list_multiparts(options = {})
        query = { "uploads" => true }

        query.merge!(options.select do |k, _|
          ['prefix', 'key-marker', 'upload-id-marker', 'max-uploads', 'delimiter', 'encoding-type'].include?(k.to_s)
        end)

        http.get("/", query: query, bucket: bucket)
      end

      # List uploaded parts for Multipart Upload event
      #
      # @see https://docs.aliyun.com/#/pub/oss/api-reference/multipart-upload&ListParts List Parts
      #
      # @param key [String] the object name
      # @param upload_id [String] the upload ID return by #bucket_init_multipart
      # @param options [Hash] options
      # @option options [Integer] :max-parts (1000) Limit number of parts, the maxinum should <= 1000
      # @option options [Integer] :part-number-marker Specify the start part, return parts which number large than the specified value
      # @option options [String] :encoding-type Encoding type used for unsupported character in xml 1.0
      #
      # @return [Response]
      def bucket_list_parts(key, upload_id, options = {})
        query = { "uploadId" => upload_id }

        query.merge(options.select do |k, _|
          ['max-parts', 'part-number-marker'].include?(k.to_s)
        end)

        http.get("/#{key}", query: query, bucket: bucket, key: key)
      end

      private

      def http
        @http = Http.new(access_key, secret_key, @options)
      end

    end
  end
end
