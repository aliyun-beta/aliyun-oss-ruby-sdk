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

| code  |  summary |  HTTP Status|
|---|---|
|AccessDenied	|Access denied | 403|
|BucketAlreadyExists	| Bucket Already Exist|	409|
|BucketNotEmpty	|Bucket Not Empty|	409|
|EntityTooLarge	| Entry Too Large|	400|
|EntityTooSmall	| Entry Too Small|	400|
|FileGroupTooLarge	|File Group Too Large|	400|
|InvalidLinkName	| Object Link Same With Object| 400|
|LinkPartNotExist	| Object Not Exist| 400|
|ObjectLinkTooLarge	| Object Too Much | 400|
|FieldItemTooLong	| Field Too Large| 400|
|FilePartInterity	| File Part Already Changed| 400|
|FilePartNotExist	|File Part Not Exist|	400|
|FilePartStale	| File Part Expired|	400|
|IncorrectNumberOfFilesInPOSTRequest|	File Count Invalid| 400|
|InvalidArgument	|Invalid Argument|	400|
|InvalidAccessKeyId | Access Key ID Not Exist| 403|
|InvalidBucketName	| The specified bucket is not valid.| 400|
|InvalidDigest	| Invalid Digest | 400|
|InvalidEncryptionAlgorithmError	| Specified Encoding-Type Error | 400|
|InvalidObjectName	|Invalid Object Name| 400
|InvalidPart	| Invalid Part| 400|
|InvalidPartOrder	|Invalid Part Order| 400|
|InvalidPolicyDocument	| Invalid Policy| 400|
|InvalidTargetBucketForLogging	|Invalid Target Bucket For Logging| 400|
|InternalError	|Internal Error| 500|
|MalformedXML	|	XML Invalid| 400|
|MalformedPOSTRequest | Requested XML Invalid | 400|
|MaxPOSTPreDataLengthExceededError	| Body except file Too Large | 400|
|MethodNotAllowed	|Method Not Allowed| 405|
|MissingArgument	|Missing Argument| 411|
|MissingContentLength	|Missing Content Length| 411|
|NoSuchBucket	|No Such Bucket| 404|
|NoSuchKey	|No Such Key| 404|
|NoSuchUpload	|Multipart Upload ID Not Exist| 404|
|NotImplemented	|Not Implemented| 501|
|PreconditionFailed	|Precondition Failed| 412|
|RequestTimeTooSkewed	|Request Time Large Than 15 minutes| 403|
|RequestTimeout	|Request Timeout| 400|
|RequestIsNotMultiPartContent | Content-Type Invalid| 400|
|SignatureDoesNotMatch	|Signature Does Not Match|403|
|TooManyBuckets	|Too Many Buckets| 400|