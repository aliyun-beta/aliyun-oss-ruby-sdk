module Aliyun
  module Oss
    class Http # nodoc
      attr_reader :access_key, :secret_key, :host

      def initialize(access_key, secret_key, options = {})
        @access_key = access_key
        @secret_key = secret_key
        @options = options
        @host = options[:host]
      end

      def get(uri, options = {})
        response = request('GET', uri, options)
        response.success? ? response.parsed_response : response
      end

      def put(uri, options = {})
        headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }.merge(options[:headers]||{})
        request('PUT', uri, options.merge(headers: headers))
      end

      def post(uri, options = {})
        headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }.merge(options[:headers]||{})
        request('POST', uri, options.merge(headers: headers))
      end

      def delete(uri, options = {})
        headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }.merge(options[:headers]||{})
        request('DELETE', uri, options.merge(headers: headers))
      end

      def options(uri, options = {})
        request('OPTIONS', uri, options)
      end

      def head(uri, options = {})
        request('HEAD', uri, options)
      end

      private

      def request(verb, uri, options = {})
        headers = options.delete(:headers) || {}
        headers = default_headers.merge!(headers)

        if options[:body]
          headers.merge!( 'Content-MD5' => Utils.md5_digest(options[:body]) ) if !headers.key?('Content-MD5')
          headers.merge!( 'Content-Length' => Utils.content_size(options[:body]).to_s ) if !headers.key?('Content-Length')
        end

        if options[:bucket]
          new_host = headers['Host'].split(".").tap {|a| a[0] = options[:bucket] }.join(".")
          headers.merge!( 'Host' => new_host )
        end
        p headers

        uri = "http://#{headers['Host']}#{uri}"

        auth_key = get_auth_key(options.merge(verb: verb, headers: headers, date: headers['Date']))
        headers.merge!('Authorization' => auth_key)

        response = HTTParty.__send__(verb.downcase, uri, options.merge(headers: headers))
      end

      def get_auth_key(options)
        Authorization.get_authorization(access_key, secret_key, options)
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
