## LifeCycle

OSS provide LifeCycle to help user manage lifecycle of object. User can create LifeCycle rules to manage objects. At present, user can create rule to auto delete Objects. Each rule is composed by following several parts:

+ Prefix of Object name, only match the prefix will apply this rule.
+ Operation, user want to take for the matched objects.
+ Date or Days, which user can specify expired date or days to expire.


### Set LifeCycle


In the LifeCycle, you can contains 1000 rules at max.

Each rule contains:

+ ID: each rule ID must keep uniqueness and cannot contain others(eg: abc and abcd).
+ Prefix: it can used to apply rule for object with the prefix
+ Status: defined the status for the rule, Only support Enabled and Disabled.
+ Expiration: Date or Days, used to specify expired date or specify expired after x days from last modified date.

In our Library, to use Struct::LifeCycle to define a rule:

     # Define a rule to auto delete objects with prefix: logs-prod- after 7 days since last modified date
    rule1 = Aliyun::Oss::Struct::LifeCycle.new({ prefix: 'logs-prod-', days: 7, enable: true })
	
	# Defome a ri;e tp auto delete objects with prefix: logs-dev- at Time.now + 24*60*60
	rule2 = Aliyun::Oss::Struct::LifeCycle.new({ prefix: 'logs-dev', date: Time.now + 24*60*60, enable: true })
	

To set your LifeCycle with this rules:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    res = client.bucket_enable_lifecycle([rule1, rule2])	puts res.success?, res.headers

### Get LifeCycle

To get LifeCycle for bucket, use Client#bucket_get_lifecycle:

    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    res = client.bucket_get_lifecycle
    puts res.success?, res.parsed_response
    

### Disable LifeCycle


With Client#bucket_disable_lifecycle, you can disable LifeCycle:


    require 'aliyun/oss'
    
    access_key, secret_key = "your id", "your secret"
    host = "oss-cn-hangzhou.aliyuncs.com"
    bucket = "bucket-name"
    client = Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket)
    
    res = client.bucket_disable_lifecycle
    puts res.success?, res.headers
    

Next, Let's discuss about [Error](./error.md)        
       
