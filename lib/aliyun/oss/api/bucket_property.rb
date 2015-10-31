module Aliyun
  module Oss
    module Api
      module BucketProperty
        # Used to modify the bucket access.
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketACL Put Bucket Acl
        #
        # @param acl [String] supported value: public-read-write | public-read | private
        # @raise [RequestError]
        #
        # @return [Response]
        def bucket_set_acl(acl)
          query = { 'acl' => true }
          headers = { 'x-oss-acl' => acl }
          http.put('/', query: query, headers: headers, bucket: bucket)
        end

        # Used to enable access logging.
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketLogging Put Bucket Logging
        #
        # @param target_bucket [String] specifies the bucket where you want Aliyun OSS to store server access logs.
        # @param target_prefix [String] this element lets you specify a prefix for the objects that the log files will be stored.
        #
        # @raise [RequestError]
        #
        # @return [Response]
        def bucket_enable_logging(target_bucket, target_prefix = nil)
          query = { 'logging' => true }

          body = XmlGenerator.generate_enable_logging_xml(target_bucket,
                                                          target_prefix)

          http.put('/', query: query, body: body, bucket: bucket)
        end

        # Used to disable access logging.
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&DeleteBucketLogging Delete Bucket Logging
        #
        # @raise [RequestError]
        #
        # @return [Response]
        def bucket_disable_logging
          query = { 'logging' => false }
          http.delete('/', query: query, bucket: bucket)
        end

        # Used to enable static website hosted mode.
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketWebsite Put Bucket Website
        #
        # @param suffix [String] A suffix that is appended to a request that is for a directory on the website endpoint (e.g. if the suffix is index.html and you make a request to samplebucket/images/ the data that is returned will be for the object with the key name images/index.html) The suffix must not be empty and must not include a slash character.
        # @param key [String] The object key name to use when a 4XX class error occurs
        #
        # @raise [RequestError]
        #
        # @return [Response]
        def bucket_enable_website(suffix, key = nil)
          query = { 'website' => true }

          body = XmlGenerator.generate_enable_website_xml(suffix, key)

          http.put('/', query: query, body: body, bucket: bucket)
        end

        # Used to disable website hostted mode.
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&DeleteBucketWebsite Delete Bucket Website
        #
        # @raise [RequestError]
        #
        # @return [Response]
        def bucket_disable_website
          query = { 'website' => false }
          http.delete('/', query: query, bucket: bucket)
        end

        # Used to set referer for bucket.
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketReferer Put Bucket Referer
        #
        # @param referers [Array<String>] white list for allowed referer.
        # @param allowed_empty [Boolean] whether allow empty refer.
        #
        # @raise [RequestError]
        #
        # @return [Response]
        def bucket_set_referer(referers = [], allowed_empty = false)
          query = { 'referer' => true }

          body = XmlGenerator.generate_set_referer_xml(referers, allowed_empty)

          http.put('/', query: query, body: body, bucket: bucket)
        end

        # Used to enable and set lifecycle for bucket
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketLifecycle Put Bucket Lifecycle
        #
        # @param rules [Array<Aliyun::Oss::Struct::LifeCycle>] rules for lifecycle
        #
        # @raise [RequestError]
        # @raise [Aliyun::Oss::InvalidLifeCycleRuleError]
        #   if rule invalid
        #
        # @return [Response]
        def bucket_enable_lifecycle(rules = [])
          query = { 'lifecycle' => true }

          rules = Utils.wrap(rules)

          rules.each do |rule|
            unless rule.valid?
              fail Aliyun::Oss::InvalidLifeCycleRuleError, rule.inspect
            end
          end

          body = XmlGenerator.generate_lifecycle_rules(rules)

          http.put('/', query: query, body: body, bucket: bucket)
        end

        # Used to disable lifecycle for bucket.
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&DeleteBucketLifecycle Delete Bucket Lifecycle
        def bucket_disable_lifecycle
          query = { 'lifecycle' => false }
          http.delete('/', query: query, bucket: bucket)
        end

        # Used to enable CORS and set rules for bucket
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/cors&PutBucketcors Put Bucket cors
        #
        # @param rules [Array<Aliyun::Oss::Struct::Cors>] array of rule
        #
        # @raise [RequestError]
        # @raise [InvalidCorsRule]
        #   if rule invalid
        #
        # @return [Response]
        def bucket_enable_cors(rules = [])
          query = { 'cors' => true }

          rules = Utils.wrap(rules)

          rules.each do |rule|
            unless rule.valid?
              fail Aliyun::Oss::InvalidCorsRuleError, rule.inspect
            end
          end

          body = XmlGenerator.generate_cors_rules(rules)

          http.put('/', query: query, body: body, bucket: bucket)
        end

        # Used to disable cors and clear rules for bucket
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/cors&DeleteBucketcors Delete Bucket cors
        #
        # @raise [RequestError]
        #
        # @return [Response]
        def bucket_disable_cors
          query = { 'cors' => false }
          http.delete('/', query: query, bucket: bucket)
        end

        # Get ACL for bucket
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketAcl Get Bucket ACL
        #
        # @return [Response]
        def bucket_get_acl
          query = { 'acl' => true }
          http.get('/', query: query, bucket: bucket)
        end

        # Get the location information of the Bucket's data center
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketLocation Get Bucket Location
        #
        # @return [Response]
        def bucket_get_location
          query = { 'location' => true }
          http.get('/', query: query, bucket: bucket)
        end

        # Get the log configuration of Bucket
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketLogging Get Bucket Logging
        #
        # @raise [RequestError]
        #
        # @return [Response]
        def bucket_get_logging
          query = { 'logging' => true }
          http.get('/', query: query, bucket: bucket)
        end

        # Get the bucket state of static website hosting.
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketWebsite Get Bucket Website
        #
        # @return [Response]
        def bucket_get_website
          query = { 'website' => true }
          http.get('/', query: query, bucket: bucket)
        end

        # Get the referer configuration of bucket
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketReferer Get Bucket Referer
        #
        # @return [Response]
        def bucket_get_referer
          query = { 'referer' => true }
          http.get('/', query: query, bucket: bucket)
        end

        # Get the lifecycle configuration of bucket
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketLifecycle Get Bucket Lifecycle
        #
        # @return [Response]
        def bucket_get_lifecycle
          query = { 'lifecycle' => true }
          http.get('/', query: query, bucket: bucket)
        end

        # Get the CORS rules of bucket
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/cors&GetBucketcors Get Bucket cors
        #
        # @return [Response]
        def bucket_get_cors
          query = { 'cors' => true }
          http.get('/', query: query, bucket: bucket)
        end
      end
    end
  end
end
