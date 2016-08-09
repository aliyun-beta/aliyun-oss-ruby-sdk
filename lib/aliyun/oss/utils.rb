require 'base64'
require 'openssl'
require 'digest'
require 'gyoku'

module Aliyun
  module Oss
    class Utils

      # Get endpoint
      #
      # @example
      #
      #   get_endpoint('bucket-name', 'oss-cn-hangzhou.aliyuncs.com')
      #   # => 'http://bucket-name.oss-cn-hangzhou.aliyuncs.com'
      #
      # @param bucket [String] the Bucket name
      # @param host [String] the host of Bucket
      #
      # @return [String]
      def self.get_endpoint(bucket, host)
        "http://#{bucket}.#{host}/"
      end

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

      # Dig values in deep hash
      #
      # @example
      #   dig_value({ 'a' => { 'b' => { 'c' => 3 } } }, 'a', 'b', 'c')  # => 3
      #
      def self.dig_value(hash, *keys)
        new_hash = hash.dup

        keys.each do |key|
          if new_hash.is_a?(Hash) && new_hash.key?(key)
            new_hash = new_hash[key]
          else
            return nil
          end
        end
        new_hash
      end

      # @see {http://apidock.com/rails/String/underscore String#underscore}
      def self.underscore(str)
        word = str.to_s.dup
        word.gsub!(/::/, '/')
        word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
        word.tr!('-', '_')
        word.downcase!
        word
      end

      # Copy from {https://github.com/rails/rails/blob/14254d82a90b8aa4bd81f7eeebe33885bf83c378/activesupport/lib/active_support/core_ext/array/wrap.rb#L36 ActiveSupport::Array#wrap}
      def self.wrap(object)
        if object.nil?
          []
        elsif object.respond_to?(:to_ary)
          object.to_ary || [object]
        else
          [object]
        end
      end

      def self.stringify_keys!(hash)
        hash.keys.each do |key|
          hash[key.to_s] = hash.delete(key)
        end
      end
    end
  end
end
