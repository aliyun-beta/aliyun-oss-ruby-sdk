require 'base64'
require 'openssl'
require 'digest'
require 'json'

module Aliyun
  module Oss
    class Authorization
      PROVIDER = 'OSS'

      # Get temporary Signature
      #
      # @see {https://docs.aliyun.com/#/pub/oss/api-reference/access-control&signature-url Tempoorary Signature}
      #
      # @param secret_key [String] Secret Key
      # @param expire_time [Integer] the number of seconds since January 1, 1970 UTC. used to specified expired time
      # @param [Hash] options other options
      # @option options [String] :key the object name
      # @option options [String] :bucket bucket name
      # @option options [String] :verb, Request Method
      # @option options [Hash] :query Query Params
      # @option options [Hash] :headers Headers Params
      #
      # @return [String]
      def self.get_temporary_signature(secret_key, expire_time, options = {})
        content_string = concat_content_string(options[:verb], expire_time, options)
        URI.escape(signature(secret_key, content_string).strip)
      end

      # Get base64 encoded string, used to fill policy field
      #
      # @see {https://docs.aliyun.com/#/pub/oss/api-reference/object&PostObject Post Object}
      #
      # @param policy [Hash] Policy {https://docs.aliyun.com/#/pub/oss/api-reference/object&PostObject#menu7 Detail}
      #
      # @return [String]
      def self.get_base64_policy(policy)
        Base64.encode64(JSON.generate(policy).force_encoding('utf-8')).delete("\n")
      end

      # Get Signature for policy
      #
      # @see {https://docs.aliyun.com/#/pub/oss/api-reference/object&PostObject}
      #
      # @param secret_key [String] Secret Key
      # @param policy [Hash] Policy {https://docs.aliyun.com/#/pub/oss/api-reference/object&PostObject#menu7 Detail}
      #
      # @return [String]
      def self.get_policy_signature(secret_key, policy)
        signature(secret_key, get_base64_policy(policy)).strip
      end

      # @private
      #
      # Get authorization key
      #
      # @see {https://docs.aliyun.com/#/pub/oss/api-reference/access-control&signature-header Authorization}
      #
      # @param access_key [String] Access Key
      # @param secret_key [String] Secret Key
      # @param options [Hash] Options
      # @option options [String] :verb VERB, request method
      # @option options [String] :date Request Time in formate: '%a, %d %b %Y %H:%M:%S GMT'
      # @option options [String] :bucket Bucket Name
      # @option options [String] :key Object Name
      # @option options [Hash] :query Query key-value pair
      # @option options [Hash] :headers Headers
      #
      # @return [String] the authorization string
      def self.get_authorization(access_key, secret_key, options = {})
        content_string = concat_content_string(options[:verb], options[:date], options)
        signature_string = signature(secret_key, content_string)
        "#{PROVIDER} #{access_key}:#{signature_string.strip}"
      end

      def self.concat_content_string(verb, time, options = {})
        headers = options.fetch(:headers, {})

        conon_headers = get_cononicalized_oss_headers(headers)
        conon_resource = get_cononicalized_resource(
          *options.values_at(:bucket, :key, :query)
        )

        join_values(verb.upcase, time, headers, conon_headers, conon_resource)
      end

      def self.join_values(verb, time, headers, conon_headers, resource)
        if conon_headers
          join_with_conon_headers(verb, time, headers, conon_headers, resource)
        else
          join_without_conon_headers(verb, time, headers, resource)
        end
      end

      def self.join_with_conon_headers(verb, time, headers, c_headers, resource)
        [
          verb,
          headers['Content-MD5'],
          headers['Content-Type'],
          time,
          c_headers,
          resource
        ].join("\n")
      end

      def self.join_without_conon_headers(verb, time, headers, resource)
        [
          verb,
          headers['Content-MD5'],
          headers['Content-Type'],
          time,
          resource
        ].join("\n")
      end

      def self.signature(secret_key, content_string)
        utf8_string = content_string.force_encoding('utf-8')
        Base64.encode64(
          OpenSSL::HMAC.digest(
            OpenSSL::Digest::SHA1.new,
            secret_key,
            utf8_string
          )
        )
      end

      def self.get_cononicalized_oss_headers(headers)
        oss_headers = (headers || {}).select do |key, _|
          key.to_s.downcase.start_with?('x-oss-')
        end
        return if oss_headers.empty?

        oss_headers.keys.sort.map do |key|
          "#{key.downcase}:#{oss_headers[key]}"
        end.join("\n")
      end

      def self.get_cononicalized_resource(bucket, key, query)
        cononicalized_resource = '/'
        cononicalized_resource += "#{bucket}/" if bucket
        cononicalized_resource += key if key
        return cononicalized_resource if query.nil? || query.empty?

        query_str = query.keys.sort.map { |k| "#{k}=#{query[k]}" }.join('&')
        cononicalized_resource + '?' + query_str
      end
    end
  end
end
