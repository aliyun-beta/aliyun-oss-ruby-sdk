## Getting started

Here, you can know how to do some basic operation with Aliyun OSS SDK.


### Step-1. Init a client

Mostly OSS API are handled by [Aliyun::Oss::Client](http://www.rubydoc.info/gems/aliyun-oss-sdk/Aliyun/Oss/Client) class, Let's create a instance first:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)

Here, access_key/secret_key is is your access credentials, Aliyun provide three ways to get access credentials, get more information [here](https://docs.aliyun.com/#/pub/oss/product-documentation/acl&RESTAuthentication).


### Step-2. Create Bucket

Buckets are global object in OSS, so find a uniqueness name for your bucket, Or it fail when create. It can used to store objects. Now, we create a bucket:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host)
    
    # create a private bucket on oss-cn-beijing
    begin
      client.buckets.create('new-bucket', 'oss-cn-beijing', 'private')
    rescue Aliyun::Oss::RequestError => e
      puts "Bucket create fail", e.code, e.message, e.request_id
    end


### Step-3 Upload Object

Object is the most basic unit of data in OSS, you can simple imagine it's just a file. here, we upload a object to OSS:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host, bucket = "oss-cn-hangzhou.aliyuncs.com", "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    file = File.new("path/to/test.txt")
    begin
      client.bucket_objects.create("test.txt", file)
    rescue Aliyun::Oss::RequestError => e
      puts "Upload Object fail", e.code, e.message, e.request_id
    end

### Step-4 list all object

After you complete some upload, maybe you want to list the objects in the bucket:


    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host, bucket = "oss-cn-hangzhou.aliyuncs.com", "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    begin
      objects = client.bucket_objects.list
    rescue Aliyun::Oss::RequestError => e
      puts "Cannot list objects", e.code, e.message, e.request_id
    end

With correct parameters, you can get more flexible result. you can get detailed Paramters [here](http://www.rubydoc.info/gems/aliyun-oss-sdk/Aliyun%2FOss%2FClient%3Abucket_list_objects).


### Step-5. Get special object

Now, you want to get a special object:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host, bucket = "oss-cn-hangzhou.aliyuncs.com", "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    begin
      body = client.bucket_objects.get("test.txt")
      # save the response to your local file system
      File.open("test.txt", "wb") { |f| f << body.read }
    rescue Aliyun::Oss::RequestError => e
      puts "Get object fail", e.code, e.message, e.request_id
    end

Next, Visit more about [Bucket](./bucket.md)