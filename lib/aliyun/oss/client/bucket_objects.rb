module Aliyun
  module Oss
    class Client
      module BucketObjects
        # List objects of bucket
        #
        # @see Api::BucketObjects#bucket_list_objects
        # @example (see Api::BucketObjects#bucket_list_objects)
        # @param (see Api::BucketObjects#bucket_list_objects)
        # @raise (see Api::BucketObjects#bucket_list_objects)
        #
        # @return [Array<Aliyun::Oss::Struct::Object>]
        def list(*args)
          result = client.bucket_list_objects(*args).parsed_response

          object_keys = %w(ListBucketResult Contents)
          directory_keys = %w(ListBucketResult CommonPrefixes)
          Struct::Object.init_from_response(result, object_keys, client) + \
            Struct::Object.init_from_response(result, directory_keys, client)
        end

        # create object of bucket
        #
        # @see Api::BucketObjects#bucket_create_object
        # @example (see Api::BucketObjects#bucket_create_object)
        # @param (see Api::BucketObjects#bucket_create_object)
        # @raise (see Api::BucketObjects#bucket_create_object)
        #
        # @return [true]
        def create(*args)
          !!client.bucket_create_object(*args)
        end

        # Delete object for bucket
        #
        # @see Api::BucketObjects#bucket_delete_object
        # @example (see Api::BucketObjects#bucket_delete_object)
        # @param (see Api::BucketObjects#bucket_delete_object)
        # @raise (see Api::BucketObjects#bucket_delete_object)
        #
        # @return [true]
        def delete(*args)
          !!client.bucket_delete_object(*args)
        end

        # Delete objects for bucket
        #
        # @see Api::BucketObjects#bucket_delete_objects
        # @example (see Api::BucketObjects#bucket_delete_objects)
        # @param (see Api::BucketObjects#bucket_delete_objects)
        # @raise (see Api::BucketObjects#bucket_delete_objects)
        #
        # @return [true]
        def delete_multiple(*args)
          !!client.bucket_delete_objects(*args)
        end

        # Copy from existing object
        #
        # @see Api::BucketObjects#bucket_copy_object
        # @example (see Api::BucketObjects#bucket_copy_object)
        # @param (see Api::BucketObjects#bucket_copy_object)
        # @raise (see Api::BucketObjects#bucket_copy_object)
        #
        # @return [true]
        def copy(*args)
          !!client.bucket_copy_object(*args)
        end

        # Get Object
        #
        # @see Api::BucketObjects#bucket_get_object
        # @example (see Api::BucketObjects#bucket_get_object)
        # @param (see Api::BucketObjects#bucket_get_object)
        # @raise (see Api::BucketObjects#bucket_get_object)
        #
        # @return [BodyString]
        def get(*args)
          client.bucket_get_object(*args).body
        end

        # Append data to a object, will create Appendable object
        #
        # @see Api::BucketObjects#bucket_append_object
        # @example (see Api::BucketObjects#bucket_append_object)
        # @param (see Api::BucketObjects#bucket_append_object)
        # @raise (see Api::BucketObjects#bucket_append_object)
        #
        # @return [HTTParty::Response::Headers]
        def append(*args)
          client.bucket_append_object(*args).headers
        end
      end
    end
  end
end
