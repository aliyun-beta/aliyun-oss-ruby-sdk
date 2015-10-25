### Multipart Upload

     require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    # Step-1 Init a Multipart Upload
    client.bucket_init_multipart("Exciting-Ruby.mp4", { 'Content-Type' => 'video/mp4' })  
    
    # Step-2 Upload parts
    client.bucket_multipart_upload("Exciting-Ruby.mp4", 1, "98A6524428734723BE8F81D72B5295EE", file1)
    client.bucket_multipart_upload("Exciting-Ruby.mp4", 2, "98A6524428734723BE8F81D72B5295EE", file2)
    
    # Step-3 Complete Multipart Upload
    
    file = File.new("path/to/image.png")
    res = client.bucket_create_object("image.png", file, { 'Content-Type' => 'image/png' })
    puts res.success?, res.headers
    
    res = client.bucket_create_object("hello.txt", "Hello World", { 'Content-Type' => 'text/plain' })
    puts res.success?, res.headers  