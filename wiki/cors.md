## CORS

CORS allow web application visit resources not belongs it's domain. OSS provide interface to help developer control the premissions.


### Set CORS


With Client#bucket_enable_cors, you can set cors easily:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    rule = Aliyun::Oss::Struct::Cors.new(allowed_methods: ['get'], allowed_origins: ['*'])
	res = client.bucket_enable_cors([rule])
    puts res.success?, res.headers

More about the rules, visit [OSS API](https://docs.aliyun.com/#/pub/oss/api-reference/cors&PutBucketcors) and [Struct::Cors]()


### Get CORS Rules

To get current cors rules, you can use Client#bucket_get_cors:

    
    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
	res = client.bucket_get_cors
    puts res.success?, res.parsed_response

    
### Disable CORS

If you want to diable CORS, just like below:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    # create a private bucket on oss-cn-beijing
	res = client.bucket_disable_cors
    puts res.success?, res.headers
    
Note: disable CORS will remove all existing CORS Rules.


Now, Let's go to next section: [LifeCycle](./lifecycle.md)      
