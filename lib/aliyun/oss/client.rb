require 'base64'
require 'openssl'
require 'digest'
require 'pry'
require 'httparty'

module Aliyun
  module Oss
    class Client
      # example:
      # endpoint: eg: http://oss.aliyuncs.com
      # secret_key: get on aliyun console
      # secret_key: get from aliyun console
      def initialize(endpoint, access_key, secret_key, options = {})
        @endpoint = endpoint
        @access_key = access_key
        @secret_key = secret_key
        @options = options
        @host = URI(@endpoint).host
      end

      # prefix: filter buckets by prefix, default no filter
      # marker: get buckets after marker
      # max-keys: limit maxinum of return buckets, default is 100, the maxinum should large than 1000
      def list_buckets(options = {})
        query = options.select {|k, _| ['prefix', 'marker', 'max-keys'].include?(k.to_s) }
        headers = { 'Host' => @host }
        http.get('/', query: query, headers: headers)
      end

      # prefix: filter buckets by prefix, default no filter
      # marker: get buckets after marker
      # max-keys: limit maxinum of return buckets, default is 100, the maxinum should large than 1000
      # delimiter: group object with delimiter as prefix
      def bucket_list_objects_for(bucket, options = {})
        query = options.select {|k, _| ['prefix', 'marker', 'max-keys', 'delimiter', 'encoding-type'].include?(k.to_s) }
        host = "#{bucket.name}.#{bucket.location}.aliyuncs.com"
        headers = { 'Host' => host }
        http.get('/', query: query, headers: headers, bucket_name: bucket.name)
      end

      # acl: public-read-write | public-read | private
      def bucket_set_acl_for(bucket, acl)
        host = "#{bucket.name}.#{bucket.location}.aliyuncs.com"
        query = { 'acl' => true }
        headers = { 'x-oss-acl' => acl, 'Host' => host, 'content_type' => 'application/x-www-form-urlencoded' }
        http.put('/', query: query, headers: headers, sub_resources: query, bucket_name: bucket.name)
      end

      # target_bucket: Specifies the bucket where you want Aliyun OSS to store server access logs.
      # target_prefix: This element lets you specify a prefix for the objects that the log files will be stored.
      def bucket_enable_logging_for(bucket, target_bucket, target_prefix = nil)
        host = "#{bucket.name}.#{bucket.location}.aliyuncs.com"
        query = { 'logging' => true }
        logging = { "TargetBucket" => target_bucket }
        logging.merge!("TargetPrefix" => target_prefix)
        body = XmlBuilder.to_xml({ "BucketLoggingStatus" => { "LoggingEnabled" => logging }})
        p body
        headers = { 'Host' => host, 'content_type' => 'application/x-www-form-urlencoded' }
        http.put('/', query: query, headers: headers, body: body, sub_resources: query, bucket_name: bucket.name)
      end

      def bucket_disable_logging_for(bucket)
        
      end

      def bucket_enable_website_for(bucket)
        
      end

      def bucket_disable_website_for(bucket)
        
      end

      def bucket_set_referer_for(bucket)
        
      end

      def bucket_set_lifecycle_for(bucket)
        
      end

      def bucket_remove_lifecycle_for(bucket)
        
      end

      def bucket_set_cors_for(bucket)
        
      end

      def bucket_remove_cors_for(bucket)
        
      end

      def bucket_preflight_for(bucket)
        
      end

      def bucket_get_acl_for(bucket)
        
      end

      def bucket_get_location_for(bucket)
        
      end

      def bucket_get_logging_for(bucket)
        
      end

      def bucket_get_website_for(bucket)
        
      end

      def bucket_get_referer_for(bucket)
        
      end

      def bucket_get_lifecycle_for(bucket)
        
      end

      def bucket_get_cors_for(bucket)
        
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
        @http = Http.new(@endpoint, @access_key, @secret_key)
      end
    end
  end
end
