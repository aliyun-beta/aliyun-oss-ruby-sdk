## CORS

CORS allow web application visit resources not belongs it's domain. OSS provide interface to help developer control the premissions.


### Set CORS


With Bucket#enable_cors, you can set cors easily:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    begin
      bucket = Aliyun::Oss::Struct::Bucket.new(client: client)
      rule = Aliyun::Oss::Struct::Cors.new(allowed_methods: ['get'], allowed_origins: ['*'])
	  bucket.enable_cors([rule])
	rescue Aliyun::Oss::RequestError => e
      puts "Set CORS fail", e.code, e.message, e.request_id
    end

More about the rules, visit [OSS API](https://docs.aliyun.com/#/pub/oss/api-reference/cors&PutBucketcors) and [Struct::Cors](http://www.rubydoc.info/gems/aliyun-oss-sdk/0.1.1/Aliyun/Oss/Struct/Cors)


### Get CORS Rules

To get current cors rules, you can use Client#bucket_get_cors:

    
    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    begin
      bucket = Aliyun::Oss::Struct::Bucket.new(client: client)
	  cors = bucket.cors!
	rescue Aliyun::Oss::RequestError => e
      puts "Get CORS fail", e.code, e.message, e.request_id
    end

    
### Disable CORS

If you want to diable CORS, just like below:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    # create a private bucket on oss-cn-beijing
    begin
      bucket = Aliyun::Oss::Struct::Bucket.new(client: client)
	  bucket.disable_cors
	rescue Aliyun::Oss::RequestError => e
      puts "Disable CORS fail", e.code, e.message, e.request_id
    end
    
Note: disable CORS will remove all existing CORS Rules.


Now, Let's go to next section: [LifeCycle](./lifecycle.md)      
