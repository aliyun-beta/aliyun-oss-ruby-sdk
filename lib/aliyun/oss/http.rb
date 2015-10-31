require 'httparty'
require 'aliyun/oss/error'

module Aliyun
  module Oss
    class Http # nodoc
      attr_reader :access_key, :secret_key

      def initialize(access_key, secret_key, host)
        @access_key = access_key
        @secret_key = secret_key
        @host = host
      end

      def get(uri, options = {})
        request('GET', uri, options)
      end

      def put(uri, options = {})
        headers = default_content_type.merge(options[:headers] || {})
        request('PUT', uri, options.merge(headers: headers))
      end

      def post(uri, options = {})
        headers = default_content_type.merge(options[:headers] || {})
        request('POST', uri, options.merge(headers: headers))
      end

      def delete(uri, options = {})
        headers = default_content_type.merge(options[:headers] || {})
        request('DELETE', uri, options.merge(headers: headers))
      end

      def options(uri, options = {})
        request('OPTIONS', uri, options)
      end

      def head(uri, options = {})
        request('HEAD', uri, options)
      end

      private

      def request(verb, resource, options = {})
        headers = options.delete(:headers) || {}
        headers = default_headers.merge!(headers)

        if options[:body]
          unless headers.key?('Content-MD5')
            headers.merge!('Content-MD5' => Utils.md5_digest(options[:body]))
          end

          unless headers.key?('Content-Length')
            headers.merge!('Content-Length' => Utils.content_size(options[:body]).to_s)
          end
        end

        headers.merge!('Host' => get_host(options))

        auth_key = get_auth_key(options
          .merge(verb: verb, headers: headers, date: headers['Date']))
        headers.merge!('Authorization' => auth_key)

        path = api_endpoint(headers['Host']) + resource

        options = Utils
        .hash_slice(options.merge(headers: headers), :query, :headers, :body)

        response = HTTParty.__send__(verb.downcase, path, options)
        case response.code
        when 200..299
          response
        else
          raise RequestError.new(response)
        end
      end

      def get_auth_key(options)
        Authorization.get_authorization(access_key, secret_key, options)
      end

      def default_headers
        {
          'User-Agent' => user_agent,
          'Date' => Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S GMT')
        }
      end

      def get_host(options)
        if options[:location] && options[:bucket]
          "#{options[:bucket]}.#{options[:location]}.aliyuncs.com"
        elsif options[:bucket]
          "#{options[:bucket]}.#{@host}"
        else
          @host
        end
      end

      def default_content_type
        {
          'Content-Type' => 'application/x-www-form-urlencoded'
        }
      end

      def api_endpoint(host)
        "http://#{host}"
      end

      def user_agent
        "aliyun-oss-sdk-ruby/#{Aliyun::Oss::VERSION} " \
        "(#{RbConfig::CONFIG['host_os']} ruby-#{RbConfig::CONFIG['ruby_version']})"
      end
    end
  end
end
