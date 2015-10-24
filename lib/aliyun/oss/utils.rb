require 'base64'
require 'openssl'
require 'digest'

module Aliyun
  module Oss
    class Utils

      # Calculate content length
      #
      # @return [Integer]
      def self.content_size(content)
        if content.respond_to?(:size)
          content.size
        elsif content.is_a?(IO)
          content.stat.size
        end
      end

      # Digest body with MD5 and then encoding with Base64
      #
      # @return [String]
      def self.md5_digest(body)
        Base64.encode64(Digest::MD5.digest(body)).strip
      end

    end
  end
end
