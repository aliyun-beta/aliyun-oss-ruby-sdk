
oss = Aliyun::OSS.new # accesskey, secretkey

oss.list_buckets # [OSSBucket 对象]

bucket.list_objects # 返回 bucket 中对象信息 [OSSObject 对象]

bucket.set_acl # 设置 acl
bucket.enable_logging # 开启日志
bucket.disable_logging # 关闭日志
bucket.enable_website(boolean) # 开启网站托管模式
bucket.disable_website(boolean) # 关闭网站托管模式
bucket.set_referer # 设置防盗链规则
bucket.set_lifecycle  # 设置生命周期
bucket.remove_lifecycle 删除生命周期规则
bucket.set_cors
bucket.remove_cors
bucket.preflight # 跨域访问preflight请求

# 实时获取
bucket.get_acl
bucket.get_location
bucket.get_logging
bucket.get_website
bucket.get_referer
bucket.get_lifecycle
bucket.get_cors

bucket.create_object # 创建对象 支持参数 post|put
bucket.copy_object
bucket.get_object 或者 object.get
bucket.delete_object  或者 object.delete
bucket.delete_objects
bucket.get_meta_object 或者 object.get_meta

multipart = bucket.init_multipart # multipart 对象
multipart = oss.get_multipart(id) # 用于不同的请求之间继续上传  更详细的场景
multipart.upload
multipart.copy_upload
multipart.complete
multipart.abort
multipart.list

bucket.list_multiparts # [multipart 对象]

