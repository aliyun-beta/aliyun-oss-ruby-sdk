require 'base64'
require 'openssl'
require 'digest'
require 'gyoku'

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

      # @example
      #   # { 'a' => 1, 'c' => 3 }
      #   Utils.hash_slice({ 'a' => 1, 'b' => 2, 'c' => 3 }, 'a', 'c')
      #
      # @return [Hash]
      def self.hash_slice(hash, *selected_keys)
        new_hash = {}
        selected_keys.each { |k| new_hash[k] = hash[k] if hash.key?(k) }
        new_hash
      end

      # Convert File or Bin data to bin data
      #
      # @return [Bin data]
      def self.to_data(file_or_bin)
        file_or_bin.respond_to?(:read) ? IO.binread(file_or_bin) : file_or_bin
      end

      def self.to_xml(hash) # nodoc
        %(<?xml version="1.0" encoding="UTF-8"?>#{Gyoku.xml(hash)})
      end
    end
  end
end
