## Error

### Handle Error

If a error occurs when visit the OSS, the OSS will be return a error code and error message, making it easy for users to locate problems, and make the appropriate treatment. For code not 2XX, you can get information:

    require 'aliyun/oss'
    
    client = Aliyun::OSS::Client.new('ACCESS_KEY', 'SECRET_KEY', host: 'oss-cn-hangzhou.aliyuncs.com', bucket: 'oss-sdk-dev-hangzhou')
    
    res = client.bucket_create("invalid_bucket_name")
    unless res.success?
      puts "Code: #{res.code}"
      puts "Message: #{res.message}"
      puts "Request id: #{res.parsed_response['Error']['RequestId']}"
    end
    
Here, 

+ Code: the error code
+ Message: the error message
+ requestId: It's the UUID to uniquely identifies this request; When you can't solve the problem, can the RequestId to request help from the OSS development engineer.   
    

# Error Code

| code  |  summary |
|---|---|
|AccessDenied	|Access denied |
|BucketAlreadyExists	| Bucket Already Exist|
|BucketNotEmpty	|Bucket Not Empty|
|EntityTooLarge	| Entry Too Large|
|EntityTooSmall	| Entry Too Small|
|FileGroupTooLarge	|File Group Too Large|
|FilePartNotExist	|File Part Not Exist|
|FilePartStale	| File Part Expired|
|InvalidArgument	|Invalid Argument|
|InvalidAccessKeyId | Access Key ID Not Exist|
|InvalidBucketName	| The specified bucket is not valid.|
|InvalidDigest	| Invalid Digest |
|InvalidObjectName	|Invalid Object Name|
|InvalidPart	| Invalid Part|
|InvalidPartOrder	|Invalid Part Order|
|InvalidTargetBucketForLogging	|Invalid Target Bucket For Logging|
|InternalError	|Internal Error|
|MalformedXML	|Malformed XML|
|MethodNotAllowed	|Method Not Allowed|
|MissingArgument	|Missing Argument|
|MissingContentLength	|Missing Content Length|
|NoSuchBucket	|No Such Bucket|
|NoSuchKey	|No Such Key|
|NoSuchUpload	|Multipart Upload ID Not Exist|
|NotImplemented	|Not Implemented|
|PreconditionFailed	|Precondition Failed|
|RequestTimeTooSkewed	|Request Time Large Than 15 minutes|
|RequestTimeout	|Request Timeout|
|SignatureDoesNotMatch	|Signature Does Not Match|
|TooManyBuckets	|Too Many Buckets|