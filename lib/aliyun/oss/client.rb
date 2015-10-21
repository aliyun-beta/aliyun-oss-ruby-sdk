module Aliyun
  module Oss
    class Client
      def initialize
        
      end

      def list_buckets
        
      end

      def bucket_list_objects_for(bucket)
        
      end

      def bucket_set_acl_for(bucket)
        
      end

      def bucket_enable_logging_for(bucket)
        
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
        @http = Http.new
      end
    end
  end
end
