## Bucket

Bucket is a namespace in OSS, as well as management entity for high functions such as pricing, access control, logging; Bucket names are global uniqueness throughout the OSS services, and cannot be modified. Each Object stored in the OSS must contained in a Bucket. An application, such as the picture sharing website, can correspond to one or more Bucket. A user can create up to 10 Bucket, but each bucket can store unlimit objects, there is no limit to the number of storage capacity each buckte highest support 2 PB.

### Name Spec

+ Only contains lowercase letters, Numbers, dash (-)
+ Must begin with lowercase letters or Numbers
+ Length must be between 3-63 bytes


### Create Bucket

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
    
You can specify bucket name, location(default 'oss-cn-hangzhou') and acl(default: 'private') when create new bucket.


### List all buckets

To get all buckets use Client#list_buckets:

 
    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host)
    
    begin
      buckets = client.buckets.list
    rescue Aliyun::Oss::RequestError => e
      puts "List Buckets fail", e.code, e.message, e.request_id
    end    

### Set ACL

With Client#bucket_set_acl you can modify the ACL:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host, bucket = "oss-cn-hangzhou.aliyuncs.com", "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    bucket = Aliyun::Oss::Struct::Bucket.new(client: client)
    # supported value: public-read-write | public-read | private
    begin
      bucket.set_acl('public-read')
    rescue Aliyun::Oss::RequestError => e
      puts "Set ACL fail", e.code, e.message, e.request_id
    end  

Now, it support public-read-write | public-read | private, more detail visit: [Bucket ACL](https://docs.aliyun.com/#/pub/oss/product-documentation/acl&bucket-acl)


### Get ACL

To get current ACL of Bucket, use Client#bucket_get_acl:
       
    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host, bucket = "oss-cn-hangzhou.aliyuncs.com", "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    bucket = Aliyun::Oss::Struct::Bucket.new(client: client)
    begin
      acl = bucket.acl!
    rescue Aliyun::Oss::RequestError => e
      puts "Get ACL fail", e.code, e.message, e.request_id
    end    
    
### Get Bucket Location

Get bucket's data center location, use Client#bucket_get_location:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host, bucket = "oss-cn-hangzhou.aliyuncs.com", "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    bucket = Aliyun::Oss::Struct::Bucket.new(client: client)
    begin
      location = bucket.location!
    rescue Aliyun::Oss::RequestError => e
      puts "Get Location fail", e.code, e.message, e.request_id
    end 

To get more bucket information, visit Bucket#xxx! methods [here](http://www.rubydoc.info/gems/aliyun-oss-sdk/0.1.1/Aliyun/Oss/Struct/Bucket).


### Delete Bucket

If you do need one bucket, delete it with Client#bucket_delete:
    
    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host)    
    
    begin
      client.buckets.delete("deleted-bucket-name")
    rescue Aliyun::Oss::RequestError => e
      puts "Delete Bucket fail", e.code, e.message, e.request_id
    end
    
Note: when the bucket is not empty(existing object or [Multipart Uploaded](./multipart.md) parts), the delete will fail.


OK, Let's visit [Objects](./object.md)    
    