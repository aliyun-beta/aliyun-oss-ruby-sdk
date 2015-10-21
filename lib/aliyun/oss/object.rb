module Aliyun
  module Oss
    class Object < OpenStruct

      def initialize(bucket)
        @bucket = bucket
      end

      def get
        @bucket.get_object(self)
      end

      def delete
        @bucket.delete_object(self)
      end

      def get_meta
        @bucket.get_meta_object(self)
      end
    end
  end
end
