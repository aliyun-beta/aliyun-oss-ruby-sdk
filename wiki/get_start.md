## Getting started

Here, you can know how to do some basic operation with Aliyun OSS SDK.

### Step-1. Init a client

Mostly API are handled by Aliyun::Oss::Client class, now Let's create a instance:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "oss-sdk-dev-test"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)

Here, access_key/secret_key is is your access credentials, Aliyun provide three ways to fetch them, read detail at https://docs.aliyun.com/#/pub/oss/product-documentation/acl&RESTAuthentication, more about the [Aliyun::Oss::Client]()


### Step-2. Create Bucket

Buckets are global in OSS, so keep your bucket name unique with others. It can used to store many objects. Now, we create a bucket:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host)
    
    # create a private bucket on oss-cn-beijing
    res = client.bucket_create('new-bucket', 'oss-cn-beijing', 'private')
    puts res.success?, res.headers
    
Default, most api return a [HttpartyResponse](http://www.rubydoc.info/github/jnunemaker/httparty/HTTParty/Response), you can use much methods to fetch your interesting message.

### Step-3 Upload Object

Object is the most basic unit of data in OSS, mostly it's a file. you can upload a object:

    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    file = File.new("path/to/test.txt")
    res = client.bucket_create_object("test.txt", file)
    puts res.success?, res.headers

### Step-4 list all object

After you complete some upload, maybe you want to list the objects in the bucket:

    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    res = client.bucket_list_objects()
    puts res.success?, res.parsed_response

With correct parameters, you can get more flexible result.

### Step-5. Get special object

Now, you want to get a special object:

    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    res = client.bucket_get_object("test.txt")
    puts res.success?, res.headers
    # save the response to your local file system
    File.open("file.png", "wb") { |f| f << res.parsed_response }

Next, Visit more about [Bucket](./bucket.md)