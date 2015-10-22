module Aliyun
  module Oss
    class Bucket
      attr_reader :name, :location, :creation_date

      def initialize(client, name, location, creation_date)
        @client = client
        @name = name
        @location = location
        @creation_date = creation_date
      end

      def list_objects
        @client.bucket_list_objects_for(self)
      end

      def set_acl
        @client.bucket_set_acl_for(self)
      end

      def enable_logging
        @client.bucket_enable_logging_for(self)
      end

      def disable_logging
        @client.bucket_disable_logging_for(self)
      end

      def enable_website
        @client.bucket_enable_website_for(self)
      end

      def disable_website
        @client.bucket_disable_website_for(self)
      end

      def set_referer
        @client.bucket_set_referer_for(self)
      end

      def set_lifecycle
        @client.bucket_set_lifecycle_for(self)
      end

      def remove_lifecycle
        @client.bucket_remove_lifecycle_for(self)
      end

      def set_cors
        @client.bucket_set_cors_for(self)
      end

      def remove_cors
        @client.bucket_remove_cors_for(self)
      end

      def preflight
        @client.bucket_preflight_for(self)
      end

      def get_acl
        @client.bucket_get_acl_for(self)
      end

      def get_location
        @client.bucket_get_location_for(self)
      end

      def get_logging
        @client.bucket_get_logging_for(self)
      end

      def get_website
        @client.bucket_get_website_for(self)
      end

      def get_referer
        @client.bucket_get_referer_for(self)
      end

      def get_lifecycle
        @client.bucket_get_lifecycle_for(self)
      end

      def create_object
        @client.bucket_create_object_for(self)
      end

      def copy_object
        @client.bucket_copy_object_for(self)
      end

      def get_object
        @client.bucket_get_object_for(self)
      end

      def delete_object
        @client.bucket_delete_object_for(self)
      end

      def delete_objects
        @client.bucket_delete_objects_for(self)
      end

      def get_meta_object
        @client.bucket_get_meta_object_for(self)
      end

      def get_cors
        @client.bucket_get_cors_for(self)
      end

      def init_multipart
        @client.bucket_init_multipart_for(self)
      end

      def list_multiparts
        @client.bucket_list_multiparts_for(self)
      end
    end
  end
end
