module Aliyun
  module Oss
    class Http

      def initialize(endpoint, access_key, secret_key, options = {})
        @endpoint = endpoint
        @access_key = access_key
        @secret_key = secret_key
        @options = options
        @host = URI(@endpoint).host
      end

      def get(resource, options = {})
        headers = options.fetch(:headers, {})

        endpoint = "http://#{headers['Host']}"
        date = Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")
        authorization_value = Utils.authorization(@access_key, @secret_key, options.merge(verb: 'GET', headers: headers, date: date))
        headers.merge!('Authorization' => authorization_value, 'Date' => date)

        response = HTTParty.get(endpoint, options.merge(headers: headers))
        if response.success?
          response.parsed_response
        else
          puts response
          response
        end
      end

      def post
        
      end

      def put(resource, options = {})
        headers = options.delete(:headers) ||n {}

        endpoint = "http://#{headers['Host']}"
        date = Time.now.utc.strftime("%a, %d %b %Y %H:%M:%S GMT")
        authorization_value = Utils.authorization(@access_key, @secret_key, options.merge(verb: 'PUT', headers: headers, date: date))
        headers.merge!('Authorization' => authorization_value, 'Date' => date)

        response = HTTParty.put(endpoint, options.merge(headers: headers))
        if response.success?
          response
        else
          puts response
          response
        end
       
      end

      def delete
        
      end

      private
      def request
        
      end
    end
  end
end
