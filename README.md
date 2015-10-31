# Aliyun OSS SDK

[![Build Status](https://travis-ci.org/zlx/aliyun-oss-sdk.svg)](https://travis-ci.org/zlx/aliyun-oss-sdk)
[![Code Climate](https://codeclimate.com/github/zlx/aliyun-oss-sdk/badges/gpa.svg)](https://codeclimate.com/github/zlx/aliyun-oss-sdk)
[![Coverage Status](https://coveralls.io/repos/zlx/aliyun-oss-sdk/badge.svg?branch=master&service=github)](https://coveralls.io/github/zlx/aliyun-oss-sdk?branch=master)

-----


It provide One-to-one Ruby interface for Aliyun OSS Restful API. I try to keep things natural and reasonable, but there are always some places are leaky, welcome to give me advice and modification. Enjoy it!



## Installation

It's a Ruby Gem, so you can install it like any Gem:

    gem install aliyun-oss-sdk

If you use Gemfile manage your Gems, Add below to your Gemfile.

    gem "aliyun-oss-sdk"

And run:

    bundle install  


## Usage    

### Quick Start

    require 'aliyun/oss'
    
    # ACCESS_KEY/SECRET_KEY is your access credentials
    # host: your bucket's data center host, eg: oss-cn-hangzhou.aliyuncs.com
    # Details: https://docs.aliyun.com/#/pub/oss/product-documentation/domain-region#menu2
    # bucket: your bucket name
	
	client = Aliyun::OSS::Client.new('ACCESS_KEY', 'SECRET_KEY', host: 'oss-cn-hangzhou.aliyuncs.com', bucket: 'oss-sdk-dev-hangzhou')
	
	
	# Upload objects
	client.bucket_create_object('image.png', File.new('path/to/image.png'), { 'Content-Type' => 'image/png' })
	
	# Get Object
	client.bucket_get_object('image.png')
	
	
	
	# Get all objects in this bucket
	# use prefix，marker，delimiter, max-keys to filter results
	client.bucket_list_objects()
    

### Share your files

Sometimes, you want to share some file in your private bucket with your friends , but you donot want to share your AccessKey, thus, Aliyun provide alternative way: [Put signature in URL](https://docs.aliyun.com/#/pub/oss/api-reference/access-control&signature-url)

We provide a method to calculate signature for you:

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


### Full API


    ###### Bucket #####
    
    # Get all buckets information
	client.list_buckets
	
	# Create new buckets
	client.bucket_create('oss-sdk-dev-beijing-no1', 'oss-cn-beijing', 'public-read')
	
	# Delete bucket
	client.bucket_delete(name)
	
	# Get all objects in this bucket
	# use prefix，marker，delimiter, max-keys to filter results
	client.bucket_list_objects()
	
		
	#### Get information of this bucket  ####
	
	client.bucket_get_acl
	client.bucket_get_cors
	client.bucket_get_lifecycle
	client.bucket_get_location
	client.bucket_get_logging
	client.bucket_get_referer
	client.bucket_get_website
	
	
	##### Set the bucket properties  ####
	
	# set cors for bucket
	rule = Aliyun::Oss::Struct::Cors.new({ allowed_methods: ['get'], allowed_origins: ['*'] })
	client.bucket_enable_cors([rule])
	client.bucket_disable_cors	# Disable and remove existing cors
	
	# Set lifecycle for bucket
	rule1 = Aliyun::Oss::Struct::LifeCycle.new({ prefix: 'logs-prod-', days: 7, enable: true })
	rule2 = Aliyun::Oss::Struct::LifeCycle.new({ prefix: 'logs-dev', date: Time.now + 24*60*60, enable: true })
	client.bucket_enable_lifecycle([rule1, rule2])
	client.bucket_disable_lifecycle  # Disable and remove existing lifecycle
	
	# Enable  access logging for bucket
	client.bucket_enable_logging('logs-oss-sdk', 'logs-')
	client.bucket_disable_logging  # Disable logging
	
	# Set bucket to static web sites hosted mode.
	client.bucket_enable_website('index.html', 'error.html')
	client.bucket_disable_website  # Disable static web sites hosted mode
	
	# Set Referer for this bucket
	client.bucket_set_referer(['http://www.aliyun.com'], false)
	
	# Set ACL for bucket
	# supported value: public-read-write | public-read | private
	client.bucket_set_acl('public-read')
	
	
	#### Object ####
	
	# Upload object to bucket
	client.bucket_create_object("image.png", File.new("path/to/image.png"), { 'Content-Type' => 'image/png' })
	
	# Copy object from other bucket
	client.bucket_copy_object('new_image.png', 'origin-bucket-name', 'origin.png', { 'x-oss-metadata-directive' => 'REPLACE' })
	
	# Get a Object
	client.bucket_get_object("image.png")
	
	# Get meta information of object
	client.bucket_get_meta_object("image.png")
	
	# Get object ACL
	client.bucket_get_object_acl("image.png")
	
	# Set object ACL
	client.bucket_set_object_acl("image.png", 'public-read-write')
	
	# upload object with append
	# it will create a Appendable object
	# https://docs.aliyun.com/#/pub/oss/api-reference/object&AppendObject
	client.bucket_append_object("secret.zip", Bin Data, 0)  # return the last position, 100203
	client.bucket_append_object("secret.zip", Bin Data, 100203)
	
	# Delete Object
	client.bucket_delete_object('secret.zip)
	
	# Delete Multiple objects
	client.bucket_delete_objects(['secret.zip', 'image.png'], true)
	
	
	
	#### Multipart Upload  ####  
	
	# Init a Multipart Upload event
	client.bucket_init_multipart("Exciting-Ruby.mp4", { 'Content-Type' => 'video/mp4' })  # return upload ID "98A6524428734723BE8F81D72B5295EE"
	
	# Upload files
	client.bucket_multipart_upload("Exciting-Ruby.mp4", 1, "98A6524428734723BE8F81D72B5295EE", file1)  # return etag for use later
	client.bucket_multipart_upload("Exciting-Ruby.mp4", 2, "98A6524428734723BE8F81D72B5295EE", file2)
	client.bucket_multipart_upload("Exciting-Ruby.mp4", 3, "98A6524428734723BE8F81D72B5295EE", file3)
	
	# Copy from existing object
	client.bucket_multipart_copy_upload("Exciting-Ruby.mp4", 4, "98A6524428734723BE8F81D72B5295EE", source_bucket: 'original-bucket-name', source_key: 'original-file', range: 'bytes=0-10000')
	
	# List uploaded parts for a Multipart Upload event
	client.bucket_list_parts("sample_multipart.data", "98A6524428734723BE8F81D72B5295EE")  
	
	# Complete a Multipart Upload event
	part1 = Aliyun::Oss::Struct::Part.new({ number: 1, etag: 'etag1' })
	part2 = Aliyun::Oss::Struct::Part.new({ number: 2, etag: 'etag2' })
	part3 = Aliyun::Oss::Struct::Part.new({ number: 3, etag: 'etag3' })
	client.bucket_complete_multipart("Exciting-Ruby.mp4", "98A6524428734723BE8F81D72B5295EE", [part1, part2, part3])
	
	# Abort a Multipart Upload event
	# abort will remove all uploaded parts
	# invoke a few time to confirm all parts are deleted for concurrency access
	client.bucket_abort_multipart("Exciting-Ruby.mp4", "9FB6F32C2DC24E04B813963B58E29E68")




## Document

Here is original Restful API, It has the most detailed and authoritative explanation for every API.

+ [https://docs.aliyun.com/#/pub/oss/api-reference/overview](https://docs.aliyun.com/#/pub/oss/api-reference/overview)

Here is thr Ruby Document for this Library, use to find more usage for methods.

+ [Ruby API Document](http://www.rubydoc.info/gems/aliyun-oss-sdk/0.0.1)


Here are some more guides for help you. Welcome to advice.

+ [Installation](./wiki/installation.md)
+ [Getting Started](./wiki/get_start.md)
+ [Bucket](./wiki/bucket.md)
+ [Object](./wiki/object.md)
+ [Multipart Upload](./wiki/multipart.md)
+ [CORS](./wiki/cors.md)
+ [LifeCycle](./wiki/lifecycle.md)
+ [Error](./wiki/error.md)



## Authors && Contributors

- [Newell Zhu](https://github.com/zlx_star)


## License

licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0.html)
