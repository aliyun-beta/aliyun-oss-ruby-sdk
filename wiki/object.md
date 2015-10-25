## Object

In Aliyun OSS, the basic data unit that user operation is the Object. A single Object maximum size varies according to the way of uploading data, Put the Object way most can't more than 5 GB, using multipart Object way to upload size must not exceed 48.8 TB. Object contains the key, meta, and data. Among them, the key is the name of the Object. Meta is user's description of the object consists of a series of name-value pairs; The data is the object data.


## Name Spec

+ Use utf-8 encoding
+ Length must be between 1 to 1023 bytes
+ Don't begin with "/" or "\" character
+ Can not contain "\r" or "\n"


## Upload Object

### Simple upload

Client#bucket_create_object support file or bin data to upload.

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    file = File.new("path/to/image.png")
    res = client.bucket_create_object("image.png", file, { 'Content-Type' => 'image/png' })
    puts res.success?, res.headers
    
    res = client.bucket_create_object("hello.txt", "Hello World", { 'Content-Type' => 'text/plain' })
    puts res.success?, res.headers
    

The Upload limit Data to 5 GB, if large than it, use [Multipart Upload](./multipart.md).


### Create a folder

To Create a folder, it's easy, just pass key with "/" at last:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    res = client.bucket_create_object("images/", "")
    puts res.success?, res.headers

Create simulations folder nature created a size of 0 object.Uploads and downloads, for this object can only console to end with "/" object to display the folder. So the user can use this way to implement to create simulation folder. And access to the folder can see files below the folder.

    
### Customize Http Header for object

OSS service allow users to customize the http headers of object. The following code set the expiration time for the Object:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    file = File.new("path/to/image.png")
    res = client.bucket_create_object("image.png", file, { 'Content-Type' => 'image/png', "Expires" => "Fri, 28 Feb 2012 05:38:42 GMT" })
    puts res.success?, res.headers
 
Except Expires, also support Cache-Control, Content-Disposition, Content-Encoding, Content-MD5, more details visit: [Client#bucket_create_object]().


### Set User Meta

OSS Support meta information for object.

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    file = File.new("path/to/image.png")
    res = client.bucket_create_object("image.png", file, { 'Content-Type' => 'image/png', 'x-oss-meta-user' => 'baymax' })
    puts res.success?, res.headers


user meta is information with "x-oss-meta" stored in headers, the maxinum limit is 2KB.

Note: the user meta key is case-insensitive, but value is case-sensitive.


### Append Upload

OSS Allow users to append data to a object, but only for appendable object, Objects created with Append Upload is Appendable object, Upload via simple upload is Normal object:


    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    # Step-1 create a appendable object
    position = 0
    res = client.bucket_append_object("secret.zip", "init information", position)
    
    # Step-2 get next append position
    position = res.headers['x-oss-next-append-position']
    
    # Step-3 append upload
    res = client.bucket_append_object("secret.zip", "append information", position)
    puts res.success?, res.headers
    
Users upload with Append mode, the important is to set position correctly. When a user creates an Appendable Object, additional position to 0. When the Appendable Object for additional content, additional location as the Object of the current length. There are two ways to get the Object length: one is through return after the upload additional content. Another is fetch by head object(Client#bucket_get_meta_object). the next position is store with header: x-oss-next-append.

Note: Only when create the appendable object can set object meta. Later if you need to change the object meta, can use copy object interface(Client#bucket_copy_object) -- source and destination for the same Object.  

## List objects in Bucket


### List Objects

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    res = client.bucket_list_objects
    puts res.success?, res.parsed_response
    

### More Parameters

the method support many Parameters to get flexible results:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    # list objects with prefix: pic and end with "/"
    res = client.bucket_list_objects(prefix: 'pic', delimiter: '/')
    puts res.success?, res.parsed_response

It list results with prefix: pic and end with "/", for example: "pic-people/". More about the Paramters, visit: [Client#bucket_list_objects]()

### Get Object

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    res = client.bucket_get_object('image.png')
    puts res.success?, res.parsed_response
    
It Support much Parameters, Range, If-Modified-Since, If-Unmodified-Since, If-Match, If-None-Match. With Range, we can get data from a object, it's useful for download partly and so on.

    
### Get Meta Object

To get meta information of a object, use Client#get_meta_object:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    res = client.bucket_get_meta_object('image.png')
    puts res.success?, res.headers

### Delete Object

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    # Delete one object
    res = client.bucket_delete_object('image.png')
    puts res.success?, res.headers
    
    
    # Delete many objects at once
    # the second Paramter used to control the response information. Quiet or Verbose
    res = client.bucket_delete_objects(['image1.png', 'image2.png'], true)
    puts res.success?, res.headers
    

### Copy Object


With Client#bucket_copy_object, we can copy objects from some bucket to others.

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    res = client.bucket_copy_object('new_image.png', 'origin-bucket-name', 'origin.png')
    puts res.success?, res.headers
    
Note: the origin bucket and target bucket must locate at same region.

Now, it allow to modify User meta information.


### Modify Object Meta

With Copy object, specify the source object and target object to the same one, we can implement modify user meta information.

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    headers = { "Content-Type" => "image/japeg" }
    res = client.bucket_copy_object('image.png', 'bucket-name', 'image.png', headers)
    puts res.success?, res.headers
 
 
 
That's it, Here we visit [Multipart Upload](./multipart.md)    
