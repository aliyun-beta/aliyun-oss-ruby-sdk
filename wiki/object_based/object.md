## Object

In Aliyun OSS, the basic data unit that user operation is the Object. A single Object maximum size varies according to the way of uploading data, Put the Object way most can't more than 5 GB, using multipart Object way to upload size must not exceed 48.8 TB. Object contains the key, meta, and data. Among them, the key is the name of the Object. Meta is user's description of the object consists of a series of name-value pairs; The data is the object data.


## Name Spec

+ Use utf-8 encoding
+ Length must be between 1 to 1023 bytes
+ Don't begin with "/" or "\" character
+ Can not contain "\r" or "\n"


## Upload Object

### Simple upload

BucketObjects#create support file or bin data to upload.

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    file = File.new("path/to/image.png")
    begin
      client.bucket_objects.create("image.png", file, { 'Content-Type' => 'image/png' })
    rescue Aliyun::Oss::RequestError => e
      puts "Create Object fail", e.code, e.message, e.request_id
    end
    
    begin
      client.bucket_objects.create("hello.txt", "Hello World", { 'Content-Type' => 'text/plain' })
    rescue Aliyun::Oss::RequestError => e
      puts "Create Object fail", e.code, e.message, e.request_id
    end
    

The Upload limit Data to 5 GB, if large than, visit [Multipart Upload](./multipart.md).


### Create a folder

To Create a folder, it's easy, just pass key end with "/":

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    begin
      client.bucket_objects.create("images/", "")
    rescue Aliyun::Oss::RequestError => e
      puts "Create folder fail", e.code, e.message, e.request_id
    end

Create simulations folder nature created a object with size equals 0. Uploads and downloads, for this object can only console to end with "/" object to display the folder. So the user can use this way to implement to create simulation folder. And access to the folder can see files below the folder.

    
### Customize Http Header for object

OSS allow users to customize the http headers of object. The following code set the expiration time for the Object:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    file = File.new("path/to/image.png")
    begin
      client.bucket_objects.create("image.png", file, { 'Content-Type' => 'image/png', "Expires" => "Sun, 25 Oct 2015 05:38:42 GMT" })
    rescue Aliyun::Oss::RequestError => e
      puts "Create Object fail", e.code, e.message, e.request_id
    end
     
Except Expires, it also support Cache-Control, Content-Disposition, Content-Encoding, Content-MD5, more details visit: [BucketObjects#create](http://www.rubydoc.info/gems/aliyun-oss-sdk/0.1.1/Aliyun/Oss/Client/BucketObjects#create-instance_method).


### Set User Meta

OSS Support set some user meta information for object. Here we set x-oss-meta-user to username for object:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    file = File.new("path/to/image.png")
    begin
      client.bucket_objects.create("image.png", file, { 'Content-Type' => 'image/png', 'x-oss-meta-user' => 'baymax' })
    rescue Aliyun::Oss::RequestError => e
      puts "Create Object fail", e.code, e.message, e.request_id
    end


user meta information stored as headers with prefix: "x-oss-meta", the maxinum limit is 2KB for all meta information.

Note: the user meta key is case-insensitive, but value is case-sensitive.


### Append Upload

OSS Allow users to append data to a object, but only for appendable object, Objects created with Append Upload is Appendable object, Upload via Simple Upload is Normal object:


    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    # Step-1 create a appendable object
    begin
    position = 0    
      headers = client.bucket_objects.append("secret.zip", "init information", position)
      # Step-2 get next append position
      position = headers['x-oss-next-append-position']
      # Step-3 append upload
      client.bucket_objects.append("secret.zip", "append information", position)
    rescue Aliyun::Oss::RequestError => e
      puts "Append Object fail", e.code, e.message, e.request_id
    end
    
Users upload with Append mode, the most important is to set position correctly: When a user creates an appendable object, should set position to 0; When append content for the object, the postion is the current size of the object. 

There are two ways to get the object size: one is the return of BucketObject#append. Another is invoke Object#meta! with the object.

Note: You can set meta information only when create appendable object(the first append). Later, if you want to change the meta, use BucketObject#copy(set source and destination to the same object).



## List objects in Bucket


### List Objects

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    objects = client.bucket_objects.list    
    

### More Parameters

the method support many Parameters to get flexible results:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    # list objects with prefix: pic and end with "/"
    objects = client.bucket_objects.list(prefix: 'pic', delimiter: '/')
    

It list results with prefix: pic and end with "/", for example: "pic-people/". More about the Paramters, visit: [BucketObjects#list](http://www.rubydoc.info/gems/aliyun-oss-sdk/0.1.1/Aliyun/Oss/Client/BucketObjects#list-instance_method)


### Simulate Directory

In OSS, there is not real directory, the direcory we have seen actually is object with key end with /.

So, we can list objects by directory with prefix and delimiter.

For example, We have four objects:

+ fun/movie/001.avi
+ fun/movie/007.avi
+ fun/test.jpg
+ oss.jpg

There are two directory object: fun/ and fun/movie/;

Now, If we invoke:

1. list() will return 4 objects + two directory object;
2. list(prefix: 'fun/') will return first 3 objects and two directory object;
3. list(prefix: 'fun/', delimiter='/') will only return fun/test.jpg, fun/ and fun/movie/.

So we can use this two paramters to list objects by directory.

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    # list objects with prefix: fun/ and end with "/"
    results = client.bucket_objects.list(prefix: 'fun/', delimiter: '/')
    
    results.each do |object|
      if object.is_a?(Aliyun::Oss::Struct::Directory)
        puts object.key
        sub_objects = object.list(delimiter: '/')
      else
        puts object.key
      end
    end
    
Note: the results maybe instance of Aliyun::Oss::Struct::File or Aliyun::Oss::Struct::Directory, they are both subclass of Aliyun::Oss::Struct::Object, but Directory has method: #list to list objects under it.     
    

### Get Object

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    begin
      body = client.bucket_objects.get('image.png')
      File.open('image.png', 'wb') {|f| f.write body.read }
    rescue Aliyun::Oss::RequestError => e
      puts "Get Object fail", e.code, e.message, e.request_id
    end
        
It Support Parameters, Range, If-Modified-Since, If-Unmodified-Since, If-Match, If-None-Match. With Range, we can get range data from a object, it's useful for download partly and so on.

    
### Get Meta Object

To get meta information of a object, use Client#get_meta_object:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    begin
      headers = client.bucket_objects.meta!('image.png')
    rescue Aliyun::Oss::RequestError => e
      puts "Get Object meta information fail", e.code, e.message, e.request_id
    end

### Delete Object

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    # Delete one object
    begin
      client.bucket_objects.delete('image.png')
    rescue Aliyun::Oss::RequestError => e
      puts "Delete Object fail", e.code, e.message, e.request_id
    end
    
    
    # Delete many objects at once
    # the second Paramter used to control the response information. Quiet or Verbose
    begin
      client.bucket_objects.delete_multiple(['image1.png', 'image2.png'], true)
    rescue Aliyun::Oss::RequestError => e
      puts "Delete Objects fail", e.code, e.message, e.request_id
    end
    

### Copy Object


With BucketObjects#copy, we can copy objects from some bucket to others.

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    begin
      client.bucket_objects.copy('new_image.png', 'origin-bucket-name', 'origin.png')
    rescue Aliyun::Oss::RequestError => e
      puts "Copy Objects fail", e.code, e.message, e.request_id
    end
    
Note: the origin bucket and target bucket must locate at same region.

Now, it allow to modify User meta information.


### Modify Object Meta

With Copy object, specify the source object and target object to the same one, we can implement modify user meta information.

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    begin
      headers = { "Content-Type" => "image/japeg" }
      client.bucket_objects.copy('image.png', 'bucket-name', 'image.png', headers)
    rescue Aliyun::Oss::RequestError => e
      puts "Copy Objects fail", e.code, e.message, e.request_id
    end
 
 
 
That's it, Here we visit [Multipart Upload](./multipart.md)    
