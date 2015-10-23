require 'base64'
require 'openssl'
require 'digest'
require 'pry'
require 'httparty'

module Aliyun
  module Oss
    class Client
      attr_accessor :access_key, :secret_key, :bucket

      # Initialize a object
      #
      # @example
      #   Aliyun::Oss::Client.new("http://oss.aliyuncs.com", "ACCESS_KEY", "SECRET_KEY")
      #
      # @param access_key [String] access_key obtained from aliyun
      # @param secret_key [String] secret_key obtained from aliyun
      # @option options [String] :endpoint Endpoint for bucket's data center
      # @option options [String] :host (URI(endpoint).host) Host name for request
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
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/service&GetService GetService (ListBucket)}
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
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucket Get Bucket (List Object)}
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

      # Used to modify the bucket access.
      #
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketACL Put Bucket Acl}
      #
      # @param acl [String] supported value: public-read-write | public-read | private
      def bucket_set_acl(acl)
        query = { 'acl' => true }
        headers = { 'x-oss-acl' => acl }
        http.put('/', query: query, headers: headers, sub: query, bucket: bucket)
      end

      # Used to enable access logging.
      #
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketLogging Put Bucket Logging}
      #
      # @param target_bucket [String] specifies the bucket where you want Aliyun OSS to store server access logs.
      # @param target_prefix [String] this element lets you specify a prefix for the objects that the log files will be stored.
      def bucket_enable_logging(target_bucket, target_prefix = nil)
        logging = { "TargetBucket" => target_bucket }
        logging.merge!("TargetPrefix" => target_prefix) if target_prefix
        body = XmlBuilder.to_xml({ "BucketLoggingStatus" => { "LoggingEnabled" => logging }})
        query = { 'logging' => true }
        http.put('/', query: query, body: body, sub: query, bucket: bucket)
      end

      # Used to disable access logging.
      #
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/bucket&DeleteBucketLogging Delete Bucket Logging}
      def bucket_disable_logging
        query = { 'logging' => false }
        http.delete('/', query: query, sub: query, bucket: bucket)
      end

      # Used to enable static website hosted mode.
      #
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketWebsite Put Bucket Website}
      #
      # @param suffix [String] A suffix that is appended to a request that is for a directory on the website endpoint (e.g. if the suffix is index.html and you make a request to samplebucket/images/ the data that is returned will be for the object with the key name images/index.html) The suffix must not be empty and must not include a slash character.
      # @param key [String] The object key name to use when a 4XX class error occurs
      def bucket_enable_website(suffix, key = nil)
        query = { 'website' => true }
        website_configuration = { "IndexDocument" => { "Suffix" => suffix } }
        website_configuration.merge!("ErrorDocument" => { "Key" => key }) if key
        body = XmlBuilder.to_xml({ "WebsiteConfiguration" => website_configuration })
        headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
        http.put('/', query: query, headers: headers, body: body, sub: query, bucket: bucket)
      end

      # Used to disable website hostted mode.
      #
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/bucket&DeleteBucketWebsite Delete Bucket Website}
      def bucket_disable_website
        query = { 'website' => true }
        http.delete('/', query: query, sub: query, bucket: bucket)
      end

      # Used to set referer for bucket.
      #
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketReferer Put Bucket Referer}
      #
      # @param referers [Array<String>] white list for allowed referer.
      # @param allowed_empty [Boolean] whether allow empty refer.
      def bucket_set_referer(referers = [], allowed_empty = false)
        query = { 'referer' => true }
        referer_configuration = { "RefererConfiguration" => { "AllowEmptyReferer" => allowed_empty, "RefererList" => { "Referer" => referers }}}
        body = XmlBuilder.to_xml(referer_configuration)
        query = { 'referer' => true }
        http.put('/', query: query, body: body, sub: query, bucket: bucket)
      end

      # Used to enable and set lifecycle for bucket
      #
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketLifecycle Put Bucket Lifecycle}
      #
      # @param rules [Array<Hash>] rules for lifecycle
      # each rule contains:
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
        http.put('/', query: query, body: body, sub: query, bucket: bucket)
      end

      # Used to disable lifecycle for bucket.
      # 
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/bucket&DeleteBucketLifecycle Delete Bucket Lifecycle}
      def bucket_disable_lifecycle
        query = { 'lifecycle' => false }
        http.delete('/', query: query, sub: query, bucket: bucket)
      end

      # Used to enable CORS and set rules for bucket
      #
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/cors&PutBucketcors Put Bucket cors}
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
        http.put('/', query: query, body: body, sub: query, bucket: bucket)
      end

      # Used to disable cors and clear rules for bucket
      #
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/cors&DeleteBucketcors Delete Bucket cors}
      def bucket_disable_cors
        query = { 'cors' => false }
        http.delete('/', query: query, sub: query, bucket: bucket)
      end

      # OPTIONS Object
      # 
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/cors&OptionObject OPTIONS Object}
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
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketAcl Get Bucket ACL}
      #
      # @return [String] public-read-write | public-read | private
      def bucket_get_acl
        query = { 'acl' => true }
        http.get('/', query: query, sub: query, bucket: bucket)
      end

      # Get the location information of the Bucket's data center
      #
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketLocation Get Bucket Location}
      #
      # @return [String] one of [oss-cn-hangzhou，oss-cn-qingdao，oss-cn-beijing，oss-cn-hongkong，
      #   oss-cn-shenzhen，oss-cn-shanghai，oss-us-west-1，oss-ap-southeast-1]
      def bucket_get_location
        query = { 'location' => true }
        http.get('/', query: query, sub: query, bucket: bucket)
      end

      # Get the log configuration of Bucket
      #
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketLogging Get Bucket Logging}
      #
      # @return [loggingConfiguration] 
      def bucket_get_logging
        query = { 'logging' => true }
        http.get('/', query: query, sub: query, bucket: bucket)
      end

      # Get the bucket state of static website hosting.
      #
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketWebsite Get Bucket Website}
      #
      # @return [websiteConfiguration]
      def bucket_get_website
        query = { 'website' => true }
        http.get('/', query: query, sub: query, bucket: bucket)
      end

      # Get the referer configuration of bucket
      #
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketReferer Get Bucket Referer}
      #
      # @return [refererConfiguration]
      def bucket_get_referer
        query = { 'referer' => true }
        http.get('/', query: query, sub: query, bucket: bucket)
      end

      # Get the lifecycle configuration of bucket
      #
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketLifecycle Get Bucket Lifecycle}
      #
      # @return [LifeCycleConfiguration]
      def bucket_get_lifecycle
        query = { 'lifecycle' => true }
        http.get('/', query: query, sub: query, bucket: bucket)
      end

      # Get the CORS rules of bucket
      #
      # API Doc: {https://docs.aliyun.com/#/pub/oss/api-reference/cors&GetBucketcors Get Bucket cors}
      #
      # @return [CorsConfiguration]
      def bucket_get_cors
        query = { 'cors' => true }
        http.get('/', query: query, sub: query, bucket: bucket)
      end

      def bucket_create_object_for(bucket, type = :put) # post | put
        
      end

      def bucket_copy_object_for(bucket)
        
      end

      def bucket_get_object_for(bucket)
        
      end

      def bucket_delete_object_for(bucket)
        
      end

      def bucket_delete_objects_for(bucket)
        
      end

      def bucket_get_meta_object_for(bucket)
        
      end

      def bucket_init_multipart_for(bucket)
        
      end

      def multipart_upload_for(multipart)
        
      end

      def multipart_copy_upload_for(multipart)
        
      end

      def multipart_complete_for(multipart)
        
      end

      def multipart_abort_for(multipart)
        
      end

      def multipart_list_for(multipart)
        
      end

      def bucket_list_multiparts_for(bucket)
        
      end

      private

      def http
        @http = Http.new(access_key, secret_key, @options)
      end

    end
  end
end
