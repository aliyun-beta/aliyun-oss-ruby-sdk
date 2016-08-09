require 'httparty'
require 'addressable/uri'
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

      def get(path, options = {})
        request('GET', path, options)
      end

      def put(path, options = {})
        headers = default_content_type.merge(options[:headers] || {})
        request('PUT', path, options.merge(headers: headers))
      end

      def post(path, options = {})
        headers = default_content_type.merge(options[:headers] || {})
        request('POST', path, options.merge(headers: headers))
      end

      def delete(path, options = {})
        headers = default_content_type.merge(options[:headers] || {})
        request('DELETE', path, options.merge(headers: headers))
      end

      def options(path, options = {})
        request('OPTIONS', path, options)
      end

      def head(path, options = {})
        request('HEAD', path, options)
      end

      private

      def request(verb, resource, options = {})
        query = options.fetch(:query, {})
        headers = options.fetch(:headers, {})
        body = options.delete(:body)

        append_headers!(headers, verb, body, options)

        path = get_path(headers['Host'], resource)
        options = { headers: headers, query: query, body: body, uri_adapter: Addressable::URI }

        wrap(HTTParty.__send__(verb.downcase, path, options))
      end

      def wrap(response)
        case response.code
        when 200..299
          response
        else
          fail RequestError, response
        end
      end

      def append_headers!(headers, verb, body, options)
        append_default_headers!(headers)
        append_body_headers!(headers, body)
        append_host_headers!(headers, options[:bucket], options[:location])
        append_authorization_headers!(headers, verb, options)
      end

      def append_default_headers!(headers)
        headers.merge!(default_headers)
      end

      def append_body_headers!(headers, body)
        return headers unless body

        unless headers.key?('Content-MD5')
          headers.merge!('Content-MD5' => Utils.md5_digest(body))
        end

        return if headers.key?('Content-Length')
        headers.merge!('Content-Length' => Utils.content_size(body).to_s)
      end

      def append_host_headers!(headers, bucket, location)
        headers.merge!('Host' => get_host(bucket, location))
      end

      def append_authorization_headers!(headers, verb, options)
        auth_key = get_auth_key(
          options.merge(verb: verb, headers: headers, date: headers['Date'])
        )
        headers.merge!('Authorization' => auth_key)
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

      def get_host(bucket, location)
        if location && bucket
          "#{bucket}.#{location}.aliyuncs.com"
        elsif bucket
          "#{bucket}.#{@host}"
        else
          @host
        end
      end

      def default_content_type
        {
          'Content-Type' => 'application/xml'
        }
      end

      def api_endpoint(host)
        "http://#{host}"
      end

      def get_path(host, resource)
        fixed = resource.split('/').map { |res| CGI.escape(res) }.join('/')
        api_endpoint(host) + fixed
      end

      def user_agent
        "aliyun-oss-sdk-ruby/#{Aliyun::Oss::VERSION} " \
        "(#{RbConfig::CONFIG['host_os']} ruby-#{RbConfig::CONFIG['ruby_version']})"
      end
    end
  end
end
