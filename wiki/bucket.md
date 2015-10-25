## Bucket

Bucket is namespace in OSS, as well as management entity for high functions such as pricing, access control, logging; Bucket names are global uniqueness throughout the OSS services, and cannot be modified. Each Object stored in the OSS must contained in a Bucket. An application, such as the picture sharing website, can correspond to one or more Bucket. A user can create up to 10 Bucket, but each bucket can store unlimit objects, there is no limit to the number of storage capacity each buckte highest support 2 PB.

### Name Spec

+ only contains lowercase letters, Numbers, dash (-)
+ Must begin with lowercase letters or Numbers
+ Length must be between 3-63 bytes


### Create Bucket

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host)
    
    # create a private bucket on oss-cn-beijing
    res = client.bucket_create('new-bucket', 'oss-cn-beijing', 'private')
    puts res.success?, res.headers
    
You can specify bucket name, location and acl when create new bucket. More about this method, visit [Client#bucket_create]()

### List all buckets

To get all buckets use Client#list_buckets:

 
    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host)
    
    res = client.list_buckets
    puts res.parsed_response
    

### Set ACL for Bucket

With Client#bucket_set_acl you can modify the ACL for bucket:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    # supported value: public-read-write | public-read | private
    res = client.bucket_set_acl("public-read")
    puts res.parsed_response

Now, it support public-read-write | public-read | private, more detail visit: [Bucket ACL](https://docs.aliyun.com/#/pub/oss/product-documentation/acl&bucket-acl)

### Get ACL of Bucket

To get current ACL of Bucket, use Client#bucket_get_acl

       
    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    res = client.bucket_get_acl
    puts res.parsed_response
    
    
### Get Bucket Location

Get bucket's data center location, use Client#bucket_get_location:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    res = client.bucket_get_location
    puts res.parsed_response

More bucket information can fetch via Client#bucket_get_xxx methods. View the [Ruby Document]()

### Delete Bucket

If you donot need the bucket, delete it with Client#bucket_delete
    
    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host)    
    
    res = client.bucket_delete("deleted-bucket-name")
    puts res.success?, res.headers
    
Note: when the bucket is not empty(existing object or parts upload via Multipart), the delete may be fail.

OK, Let's visit [Objects](./object.md)    
    