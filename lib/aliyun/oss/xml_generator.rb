module Aliyun
  module Oss
    class XmlGenerator
      # Generate xml from rules
      #
      # @example
      #  <?xml version="1.0" encoding="UTF-8"?>
      #  <LifecycleConfiguration>
      #    <Rule>
      #      <ID>RuleID</ID>
      #      <Prefix>Prefix</Prefix>
      #      <Status>Status</Status>
      #      <Expiration>
      #        <Days>Days</Days>
      #      </Expiration>
      #    </Rule>
      #  </LifecycleConfiguration>
      def self.generate_lifecycle_rules(rules)
        Utils.to_xml(
          'LifecycleConfiguration' => {
            'Rule' => rules.map(&:to_hash)
          })
      end

      # Generate xml for cors from rules
      #
      # @example
      #  <?xml version="1.0" encoding="UTF-8"?>
      #  <CORSConfiguration>
      #      <CORSRule>
      #        <AllowedOrigin>the origin you want allow CORS request from</AllowedOrigin>
      #        <AllowedOrigin>…</AllowedOrigin>
      #        <AllowedMethod>HTTP method</AllowedMethod>
      #        <AllowedMethod>…</AllowedMethod>
      #          <AllowedHeader> headers that allowed browser to send</AllowedHeader>
      #            <AllowedHeader>…</AllowedHeader>
      #            <ExposeHeader> headers in response that can access from client app</ExposeHeader>
      #            <ExposeHeader>…</ExposeHeader>
      #            <MaxAgeSeconds>time to cache pre-fight response</MaxAgeSeconds>
      #      </CORSRule>
      #      <CORSRule>
      #        …
      #      </CORSRule>
      #  …
      #  </CORSConfiguration >
      #
      def self.generate_cors_rules(rules)
        Utils.to_xml(
          'CORSConfiguration' => {
            'CORSRule' => rules.map(&:to_hash)
          })
      end

      # Generate xml for delete objects
      #
      # @example
      #  <?xml version="1.0" encoding="UTF-8"?>
      #  <Delete>
      #    <Quiet>true</Quiet>
      #    <Object>
      #      <Key>key</Key>
      #    </Object>
      #  …
      #  </Delete>
      #
      def self.generate_delete_objects_xml(keys, quiet)
        key_objects = keys.map { |key| { 'Key' => key } }
        body = Utils.to_xml(
          'Delete' => {
            'Object' => key_objects,
            'Quiet' => quiet
          })
      end

      # Generate xml for complete multipart from parts
      #
      # @example
      #  <CompleteMultipartUpload>
      #   <Part>
      #     <PartNumber>PartNumber</PartNumber>
      #     <ETag>ETag</ETag>
      #   </Part>
      #   ...
      #  </CompleteMultipartUpload>
      #
      def self.generate_complete_multipart_xml(parts)
        Utils.to_xml(
          'CompleteMultipartUpload' => {
            'Part' => parts.map(&:to_hash)
          })
      end

      # Generate xml for #bucket_create with location
      #
      # @example
      #  <?xml version="1.0" encoding="UTF-8"?>
      #  <CreateBucketConfiguration>
      #   <LocationConstraint>BucketRegion</LocationConstraint>
      #  </CreateBucketConfiguration>
      #
      def self.generate_create_bucket_xml(location)
        configuration = {
          'CreateBucketConfiguration' => {
            'LocationConstraint' => location
          }
        }
        Utils.to_xml(configuration)
      end

      # Generate xml for enable logging
      #
      # @example
      #  <?xml version="1.0" encoding="UTF-8"?>
      #  <BucketLoggingStatus>
      #    <LoggingEnabled>
      #     <TargetBucket>TargetBucket</TargetBucket>
      #     <TargetPrefix>TargetPrefix</TargetPrefix>
      #    </LoggingEnabled>
      #  </BucketLoggingStatus>
      #
      def self.generate_enable_logging_xml(target_bucket, target_prefix)
        logging = { 'TargetBucket' => target_bucket }
        logging.merge!('TargetPrefix' => target_prefix) if target_prefix
        Utils.to_xml(
          'BucketLoggingStatus' => {
            'LoggingEnabled' => logging
          })
      end

      # Generate xml for enable website
      #
      # @example
      #  <?xml version="1.0" encoding="UTF-8"?>
      #  <WebsiteConfiguration>
      #    <IndexDocument>
      #     <Suffix>index.html</Suffix>
      #    </IndexDocument>
      #    <ErrorDocument>
      #     <Key>errorDocument.html</Key>
      #    </ErrorDocument>
      #  </WebsiteConfiguration>
      #
      def self.generate_enable_website_xml(suffix, key)
        website_configuration = { 'IndexDocument' => { 'Suffix' => suffix } }
        website_configuration.merge!('ErrorDocument' => { 'Key' => key }) if key
        Utils.to_xml('WebsiteConfiguration' => website_configuration)
      end

      # Generate xml for set referer
      #
      # @example
      #  <?xml version="1.0" encoding="UTF-8"?>
      #  <RefererConfiguration>
      #    <AllowEmptyReferer>true</AllowEmptyReferer >
      #    <RefererList>
      #     <Referer> http://www.aliyun.com</Referer>
      #     <Referer> https://www.aliyun.com</Referer>
      #     <Referer> http://www.*.com</Referer>
      #     <Referer> https://www.?.aliyuncs.com</Referer>
      #    </ RefererList>
      #  </RefererConfiguration>
      #
      def self.generate_set_referer_xml(referers, allowed_empty)
        Utils.to_xml(
          'RefererConfiguration' => {
            'AllowEmptyReferer' => allowed_empty,
            'RefererList' => {
              'Referer' => referers
            }
          })
      end
    end
  end
end
