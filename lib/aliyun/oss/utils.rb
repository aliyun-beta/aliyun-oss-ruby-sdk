require 'base64'
require 'openssl'
require 'digest'

module Aliyun
  module Oss
    class Utils # nodoc

      PROVIDER = 'OSS'

      def self.authorization(access_key, secret_key, options = {})
        p options
        content_string = concat_content_string(options[:verb], options[:headers], options[:date], options)
        p content_string
        signature_string = signature(secret_key, content_string)
        p signature_string
        "#{PROVIDER} #{access_key}:#{signature_string.strip}"
      end

      def self.md5_digest(body)
        Base64.encode64(Digest::MD5.digest(body)).strip
      end

      private

      def self.concat_content_string(verb, headers, date, options = {})
        headers = headers || {}

        cononicalized_oss_headers = get_cononicalized_oss_headers(headers)
        cononicalized_resource = get_cononicalized_resource(*options.values_at(:bucket, :key, :sub))

        if cononicalized_oss_headers
          [
            verb.upcase,
            headers['Content-MD5'],
            headers['Content-Type'],
            date,
            cononicalized_oss_headers,
            cononicalized_resource
          ].join("\n")
        else
          [
            verb.upcase,
            headers['Content-MD5'],
            headers['Content-Type'],
            date,
            cononicalized_resource
          ].join("\n")
        end
      end

      def self.signature(secret_key, content_string)
        Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, secret_key, content_string))
      end

      def self.get_cononicalized_oss_headers(headers)
        oss_headers = (headers||{}).select {|key, _| key.to_s.downcase.start_with?("x-oss-") }
        return if oss_headers.empty?

        oss_headers.keys.sort.map { |key| "#{key.downcase}:#{oss_headers[key]}" }.join("\n")
      end

      def self.get_cononicalized_resource(bucket, key, subs)
        cononicalized_resource = "/"
        cononicalized_resource += "#{bucket}/" if bucket
        cononicalized_resource += key if key
        return cononicalized_resource if subs.nil? || subs.empty?

        cononicalized_resource + "?" + subs.keys.sort.map {|key| "#{key}=#{subs[key]}" }.join("&")
      end
    end
  end
end
