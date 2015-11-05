# Aliyun OSS SDK

[![Build Status](https://travis-ci.org/zlx/aliyun-oss-sdk.svg?branch=develop)](https://travis-ci.org/zlx/aliyun-oss-sdk)
[![Code Climate](https://codeclimate.com/repos/56349060695680028b00b4a5/badges/fccd40948ea96a4eb507/gpa.svg)](https://codeclimate.com/repos/56349060695680028b00b4a5/feed)
[![Coverage Status](https://coveralls.io/repos/zlx/aliyun-oss-sdk/badge.svg?branch=develop&service=github)](https://coveralls.io/github/zlx/aliyun-oss-sdk?branch=develop)

-----


It is a full-featured Ruby Library for Aliyun OSS API. We provide two ways to help you use the API: Function based and Object based. Besides, We try to keep things natural and reasonable, but there are always some leaky, welcome to give us advice and modification. Enjoy it!



## Installation

It's a Ruby Gem, so you can install it like any Gem:

    gem install aliyun-oss-sdk

If you use Gemfile manage your Gems, Add below to your Gemfile.

    gem "aliyun-oss-sdk", require: 'aliyun/oss'

And run:

    bundle install  

## Document

Here is original Restful API, It has the most detailed and authoritative explanation for every API.

+ [https://docs.aliyun.com/#/pub/oss/api-reference/overview](https://docs.aliyun.com/#/pub/oss/api-reference/overview)

Here is thr RDoc Document for this Library, use to find mostly usage for methods.

+ [RDoc Document](http://www.rubydoc.info/gems/aliyun-oss-sdk/0.1.1)


Here are some more guides for help you. Welcome to advice.

### Function Based

+ [Installation](./wiki/installation.md)
+ [Getting Started](./wiki/get_start.md)
+ [Bucket](./wiki/bucket.md)
+ [Object](./wiki/object.md)
+ [Multipart Upload](./wiki/multipart.md)
+ [CORS](./wiki/cors.md)
+ [LifeCycle](./wiki/lifecycle.md)
+ [Error](./wiki/error.md)

### Object Based

+ [Installation](./wiki/object_based/installation.md)
+ [Getting Started](./wiki/object_based/get_start.md)
+ [Bucket](./wiki/object_based/bucket.md)
+ [Object](./wiki/object_based/object.md)
+ [Multipart Upload](./wiki/object_based/multipart.md)
+ [CORS](./wiki/object_based/cors.md)
+ [LifeCycle](./wiki/object_based/lifecycle.md)
+ [Error](./wiki/error.md)

## Usage

### Quick Start

#### Function Based

    require 'aliyun/oss'
    
    # ACCESS_KEY/SECRET_KEY is your access credentials
    # host: your bucket's data center host, eg: oss-cn-hangzhou.aliyuncs.com
    # Details: https://docs.aliyun.com/#/pub/oss/product-documentation/domain-region#menu2
    # bucket: your bucket name
	
	client = Aliyun::OSS::Client.new('ACCESS_KEY', 'SECRET_KEY', host: 'oss-cn-hangzhou.aliyuncs.com', bucket: 'oss-sdk-dev-hangzhou')
	
	
	# Upload object
	client.bucket_create_object('image.png', File.new('path/to/image.png'), { 'Content-Type' => 'image/png' })
	
	# Get Object
	client.bucket_get_object('image.png')
	
	
	# Get all objects in this bucket
	# use prefix，marker，delimiter, max-keys to filter results
	client.bucket_list_objects()

#### Object Based

    require 'aliyun/oss'
    
    # ACCESS_KEY/SECRET_KEY is your access credentials
    # host: your bucket's data center host, eg: oss-cn-hangzhou.aliyuncs.com
    # Details: https://docs.aliyun.com/#/pub/oss/product-documentation/domain-region#menu2
    # bucket: your bucket name
	
	client = Aliyun::OSS::Client.new('ACCESS_KEY', 'SECRET_KEY', host: 'oss-cn-hangzhou.aliyuncs.com', bucket: 'oss-sdk-dev-hangzhou')
	
	
	# Upload object
	client.bucket_objects.create('image.png', File.new('path/to/image.png'), { 'Content-Type' => 'image/png' })
	
	# Get Object
	client.bucket_objects.get('image.png')
	
	# Get all objects in this bucket
	# use prefix，marker，delimiter, max-keys to filter results
	client.bucket_objects.list()
	
	#### Objects #####        
	buckets = client.buckets
	bucket_objects = client.bucket_objects
	bucket_multiparts = client.bucket_multiparts
	bucket = client.buckets.list.first  || Aliyun::Oss::Struct::Bucket.new(name: bucket_name, client: client)
	multipart = client.bucket_multiparts.list.first || Aliyun::Oss::Struct::Multipart.new(upload_id: upload_id, key: object_key, client: client)
	bucket_object = client.bucket_objects.list.first || Aliyun::Oss::Struct::Object.new(key: object_key, client: client)
	file = client.bucket_objects.list.select(&:file?).first || Aliyun::Oss::Struct::File.new(key: object_key, client: client)
	directory = Client.bucket_objects.list.reject(&:file?) || Aliyun::Oss::Struct::Directory.new(key: object_key, client: client)

### Share your files

Sometimes, you want to share some file from your private bucket with your friends , but you donot want to share your AccessKey, thus, Aliyun provide alternative way: [Put signature in URL](https://docs.aliyun.com/#/pub/oss/api-reference/access-control&signature-url)

We provide a method to get share link for your object:

    # Generate Share link expired in 3600 seconds
    share_link = client.bucket_get_object_share_link('object-key', 3600)
    
    # OR
    file = Aliyun::Oss::Struct::File.new(key: 'object-key', client: client)
    share_link = file.share_link(3600)

Besides, if you need more control for temporary signature:     

    # Return Singature string
    Aliyun::Oss::Authorization.get_temporary_signature('SECRET_KEY', Time.now.to_i + 60*60, verb: 'GET', bucket: 'bucket-name', key: 'object-name')


### Directly POST file to Aliyun OSS

Sometime we may allow user directly upload image or file to Aliyun to improve the upload speed. thus you may need POST form: [Post Object](https://docs.aliyun.com/#/pub/oss/api-reference/object&PostObject)

With Post Form, we need Post Policy to restrict permissions, here we provide two methods that you may interesting:

     # policy your policy in hash
     # Return base64 string which can used to fill your form field: policy
     client.get_base64_policy(policy)
     
     # Get Signature for policy
     # Return Signature with policy, can used to fill your form field: Signature
     client.get_policy_signature(SECRET_KEY, policy)

Here, we provide a [DEMO](demo/app/views/home/new_post.html.erb).

### API Mapping

We provide two type API: Function Based, Object Based. To help you find your needed methods, here list a mapping from Original Restful API to our methods.

Note: 

+ All Function Based API are instance methods of `Aliyun::Oss::Client`
+ Object Based API belongs to some other class list below:

  + Bucket: `Aliyun::Oss::Client::BucketsService`
  + BucketObject: `Aliyun::Oss::Client::BucketObjectsService`
  + BucketMultipart: `Aliyun::Oss::Client::BucketMultipartsService`
  + Bucket: `Aliyun::Oss::Struct::Bucket`
  + Multipart: `Aliyun::Oss::Struct::Multipart`
  + Object: `Aliyun::Oss::Struct::Object`
  + File: `Aliyun::Oss::Struct::File`
  + Directory: `Aliyun::Oss::Strcut:Directory`


#### Service

| Restful API  |  Function Based |  Object Based |
| ------------ | --------------- | ------------- |
|[GetService (ListBucket)](https://docs.aliyun.com/#/pub/oss/api-reference/service&GetService)	|bucket_list	|Buckets#list	|

#### Bucket

| Restful API  |  Function Based |  Object Based |
| ------------ | --------------- | ------------- |
|[Put Bucket](https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucket)		|bucket_create	|	Buckets#create|
|[Put Bucket Acl](https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketACL)	|bucket_set_acl	|	Bucket#set_acl|
|[Put Bucket Logging](https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketLogging)|bucket_enable_logging	|	Bucket#enable_logging|
|[Put Bucket Website](https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketWebsite)	|bucket_enable_website	|	Bucket#enable_website|
|[Put Bucket Referer](https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketReferer)	|bucket_set_referer	|	Bucket#set_referer|
|[Put Bucket Lifecycle](https://docs.aliyun.com/#/pub/oss/api-reference/bucket&PutBucketLifecycle)	|	bucket_enable_lifecycle|	Bucket#enable_lifecycle|
|[Get Bucket (List Object)](https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucket)	|	bucket_list_objects|	Bucket_objects#list, Directory#list|
|[Get Bucket ACL](https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketAcl)	|	bucket_get_acl|	Bucket#acl!|
|[Get Bucket Location](https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketLocation)|	bucket_get_location|	Bucket#location!|
|[Get Bucket Logging](https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketLogging)	|	bucket_get_logging|	Bucket#logging!|
|[Get Bucket Website](https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketWebsite)	|	bucket_get_website|	Bucket#website!|
|[Get Bucket Referer](https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketReferer)	|	bucket_get_referer|	Bucket#referer!|
|[Get Bucket Lifecycle](https://docs.aliyun.com/#/pub/oss/api-reference/bucket&GetBucketLifecycle)	|	bucket_get_lifecycle|	Bucket#lifecycle!|
|[Delete Bucket](https://docs.aliyun.com/#/pub/oss/api-reference/bucket&DeleteBucket)	|	bucket_delete|	Buckets#delete|
|[Delete Bucket Logging](https://docs.aliyun.com/#/pub/oss/api-reference/bucket&DeleteBucketLogging)	|	bucket_disable_logging|	Bucket#disable_logging|
|[Delete Bucket Website](https://docs.aliyun.com/#/pub/oss/api-reference/bucket&DeleteBucketWebsite)	|	bucket_disable_website|	Bucket#disable_website|
|[Delete Bucket Lifecycle](https://docs.aliyun.com/#/pub/oss/api-reference/bucket&DeleteBucketLifecycle)	|	bucket_disable_lifecycle|	Bucket#disable_lifecycle|


#### Object

| Restful API  |  Function Based |  Object Based |
| ------------ | --------------- | ------------- |
|[Put Object](https://docs.aliyun.com/#/pub/oss/api-reference/object&PutObject)|	bucket_create_object|	BucketObject#create|
|[Copy Object](https://docs.aliyun.com/#/pub/oss/api-reference/object&CopyObject)	|	bucket_copy_object|	BucketObject#copy|
|[Get Object](https://docs.aliyun.com/#/pub/oss/api-reference/object&GetObject)	|	bucket_get_object|	BucketObject#get|
|[Append Object](https://docs.aliyun.com/#/pub/oss/api-reference/object&AppendObject)|	bucket_append_object|	BucketObject#append|
|[Delete Object](https://docs.aliyun.com/#/pub/oss/api-reference/object&DeleteObject)|	bucket_delete_object|	BucketObject#delete|
|[Delete Multiple Objects](https://docs.aliyun.com/#/pub/oss/api-reference/object&DeleteMultipleObjects)|	bucket_delete_objects|	BucketObject#delete_multiple|
|[Head Object](https://docs.aliyun.com/#/pub/oss/api-reference/object&HeadObject)	|	bucket_preflight|	Bucket#preflight, Bucket#options|
|[Put Object ACL](https://docs.aliyun.com/#/pub/oss/api-reference/object&PutObjectACL)	|	bucket_set_object_acl|	Object#set_acl|
|[Get Object ACL](https://docs.aliyun.com/#/pub/oss/api-reference/object&GetObjectACL)	|	bucket_get_object_acl|	Object#acl!|
|[Post Object](https://docs.aliyun.com/#/pub/oss/api-reference/object&PostObject)	|	[DEMO](demo/app/views/home/new_post.html.erb)|	[DEMO](demo/app/views/home/new_post.html.erb)|
| Share Link	| bucket_get_object_share_link	| file#share_link |


#### Multipart Upload

| Restful API  |  Function Based |  Object Based |
| ------------ | --------------- | ------------- |
|[Initiate Multipart Upload](https://docs.aliyun.com/#/pub/oss/api-reference/multipart-upload&InitiateMultipartUpload)	|	bucket_init_multipart|	BucketMultipart#init|
|[Upload Part](https://docs.aliyun.com/#/pub/oss/api-reference/multipart-upload&UploadPart)	|	bucket_multipart_upload|	Multipart#upload|
|[Upload Part Copy](https://docs.aliyun.com/#/pub/oss/api-reference/multipart-upload&UploadPartCopy)	|	bucket_multipart_copy_upload|	Multipart#copy|
|[Complete Multipart Upload](https://docs.aliyun.com/#/pub/oss/api-reference/multipart-upload&CompleteMultipartUpload)	|	bucket_complete_multipart|	Multipart#complete|
|[Abort Multipart Upload](https://docs.aliyun.com/#/pub/oss/api-reference/multipart-upload&AbortMultipartUpload)	|	bucket_abort_multipart|	Multipart#abort|
|[List Multipart Uploads](https://docs.aliyun.com/#/pub/oss/api-reference/multipart-upload&ListMultipartUploads)	|	bucket_list_multiparts|	BucketMultipart#list|
|[List Parts](https://docs.aliyun.com/#/pub/oss/api-reference/multipart-upload&ListParts)	|	bucket_list_parts|	Multipart#list_parts|

#### CORS

| Restful API  |  Function Based |  Object Based |
| ------------ | --------------- | ------------- |
|[Put Bucket cors](https://docs.aliyun.com/#/pub/oss/api-reference/cors&PutBucketcors)	|	bucket_enable_cors|	Bucket#enable_cors|
|[Get Bucket cors](https://docs.aliyun.com/#/pub/oss/api-reference/cors&GetBucketcors)	|	bucket_get_cors|	Bucket#cors!|
|[Delete Bucket cors](https://docs.aliyun.com/#/pub/oss/api-reference/cors&DeleteBucketcors)	|	bucket_disable_cors|	Bucket#disable_cors|
|[OPTIONS Object](https://docs.aliyun.com/#/pub/oss/api-reference/cors&OptionObject)|	bucket_get_meta_object|	Object#meta!|


## Test

We use minitest for test and rubocop for Syntax checker, If you want to make contribute to this library. Confirm below Command is success:

```
bundle exec rake test
```


## Authors && Contributors

- [Newell Zhu](https://github.com/zlx_star)


## License

licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0.html)
