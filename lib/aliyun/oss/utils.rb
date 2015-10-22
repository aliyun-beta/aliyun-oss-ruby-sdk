require 'base64'
require 'openssl'
require 'digest'

module Aliyun
  module Oss
    class Utils
      PROVIDER = 'OSS'

      def self.authorization(access_key, secret_key, options = {})
        content_string = concat_content_string(options[:verb], options[:headers], options[:date], options)
        p content_string
        signature_string = signature(secret_key, content_string)
        p signature_string
        "#{PROVIDER} #{access_key}:#{signature_string.strip}"
      end

      private

      def self.concat_content_string(verb, headers, date, options = {})
        oss_headers = headers.select {|key, _| key.to_s.downcase.start_with?("x-oss-") }
        cononicalized_oss_headers = nil
        unless oss_headers.empty?
          cononicalized_oss_headers = oss_headers.keys.sort.map { |key| "#{key.downcase}:#{oss_headers[key]}" }.join("\n")
        end
        cononicalized_resource = "/"
        cononicalized_resource += "#{options[:bucket_name]}/" if options[:bucket_name]
        cononicalized_resource += options[:object_name] if options[:object_name]
        if options[:sub_resources]
          sub_resources_string = options[:sub_resources].keys.sort.map {|key| "#{key}=#{options[:sub_resources][key]}" }.join("&")
          cononicalized_resource += "?"
          cononicalized_resource += sub_resources_string
        end
        if cononicalized_oss_headers
          [verb, headers['content_md5'], headers['content_type'], date, cononicalized_oss_headers, cononicalized_resource].join("\n")
        else
          [verb, headers['content_md5'], headers['content_type'], date, cononicalized_resource].join("\n")
        end
      end

      def self.signature(secret_key, content_string)
        Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, secret_key, content_string))
      end
    end
  end
end
