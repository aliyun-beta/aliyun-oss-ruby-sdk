module Aliyun
  module Oss
    class Error < StandardError; end

    # [Aliyun::Oss::RequestError] when OSS give a Non 2xx response
    class RequestError < Error

      # Error Code defined by OSS
      attr_reader :code

      # Error Message defined by OSS
      attr_reader :message

      # It's the UUID to uniquely identifies this request;
      # When you can't solve the problem, you can request help from the OSS development engineer with the RequestId.
      attr_reader :request_id

      # The Origin Httparty Response
      attr_reader :origin_response

      def initialize(response)
        if (error_values = response.parsed_response['Error']).empty?
          @code = response.code
          @message = response.message
        else
          @code = error_values['Code']
          @message = error_values['Message']
        end
        @request_id = response.headers['x-oss-request-id']
        @origin_response = response
        super("#{@request_id} - #{@code}: #{@message}")
      end
    end

    class MultipartPartNumberEmpty < Error; end
    class MultipartUploadIdEmpty < Error; end
    class MultipartSourceBucketEmptyError < Error; end
    class MultipartSourceKeyEmptyError < Error; end
    class MultipartPartsEmptyError < Error; end

    class InvalidCorsRuleError < Error; end
    class InvalidLifeCycleRuleError < Error; end
  end
end
