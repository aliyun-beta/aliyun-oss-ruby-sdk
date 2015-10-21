module Aliyun
  module Oss
    class Multipart < OpenStruct
      def initialize(client)
        @client = client
      end

      def upload
        @client.multipart_upload_for(self)
      end

      def copy_upload
        @client.multipart_copy_upload_for(self)
      end

      def complete
        @client.multipart_complete_for(self)
      end

      def abort
        @client.multipart_abort_for(self)
      end

      def list
        @client.multipart_list_for(self)
      end
    end
  end
end
