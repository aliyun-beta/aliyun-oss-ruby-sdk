module Aliyun
  module Oss
    class Http # nodoc
      attr_reader :access_key, :secret_key, :endpoint, :host, :options

      def initialize(access_key, secret_key, options = {})
        @access_key = access_key
        @secret_key = secret_key
        @options = options
        @endpoint = options[:endpoint]
        @host = options[:host] || URI(@endpoint).host
      end

      def get(uri, options = {})
        response = request('GET', uri, options)
        response.success? ? response.parsed_response : response
      end

      def put(uri, options = {})
        headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
        request('PUT', uri, options.merge(headers: headers))
      end

      def delete(uri, options = {})
        headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }
        request('DELETE', uri, options.merge(headers: headers))
      end

      def options(uri, options = {})
        request('OPTIONS', uri, options)
      end

      private

      def request(verb, uri, options = {})
        uri = "#{endpoint}#{uri}"

        headers = options.delete(:headers) || {}
        headers = default_headers.merge!(headers)
        headers.merge!( 'Content-MD5' => Utils.md5_digest(options[:body]) ) if options[:body]

        auth_key = get_auth_key(options.merge(verb: verb, headers: headers, date: headers['Date']))
        headers.merge!('Authorization' => auth_key)

        response = HTTParty.__send__(verb.downcase, uri, options.merge(headers: headers))
      end

      def get_auth_key(options)
        Utils.authorization(access_key, secret_key, options)
      end

      def default_headers
        {
          'Host' => host,
          'Date' => Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")
        }
      end
    end
  end
end
