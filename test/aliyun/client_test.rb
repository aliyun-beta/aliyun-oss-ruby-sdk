require 'test_helper'

describe Aliyun::Oss::Client do
  let(:host) { "oss-cn-beijing.aliyuncs.com" }
  let(:bucket) { "oss-sdk-dev-beijing" }
  let(:access_key) { "44CF9590006BF252F707" }
  let(:secret_key) { "OtxrzxIsfpFjA7SwPzILwy8Bw21TLhquhboDYROV" }
  let(:default_headers) do
    {
      'User-Agent' => "aliyun-oss-sdk-ruby/#{Aliyun::Oss::VERSION} (#{RbConfig::CONFIG['host_os']} ruby-#{RbConfig::CONFIG['ruby_version']})",
      'Date'=>'Sun, 25 Oct 2015 00:46:00 GMT',
    }
  end

  let(:file) { File.new(File.join(File.dirname(__FILE__), "../fixtures/sample.txt")) }
  let(:client) { Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket) }

  before do
    Timecop.freeze(Time.parse("2015-10-25 08:46:00 +0800"))
    WebMock.reset!
  end

  after do
    Timecop.return
  end

  def assert_aliyun_api(method, request = [], response = {})
    new_host =
      if response[:location] && response[:bucket]
        "#{response[:bucket]}.#{response[:location]}.aliyuncs.com"
      elsif response[:bucket]
        "#{response[:bucket]}.#{host}"
      else
        host
      end
    endpoint = "http://#{new_host}/#{response[:key]}"

    headers = default_headers.merge(response[:headers]||{}).merge('Host' => new_host)

    stub_request1 = stub_request(response[:verb], endpoint).
      with(Aliyun::Oss::Utils.hash_slice(response, :query, :body, :headers).merge(headers: headers)).
      to_return(:status => 200, :body => "", :headers => {})
    client.send(method, *request)
    assert_requested(stub_request1)
  end

  it "should list buckets" do
    assert_aliyun_api(:list_buckets, [{ 'prefix' => 'oss-sdk' }], {
      verb: :get,
      query: {
        'prefix' => 'oss-sdk'
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:mrqTxcoyFi9EQbbuxeVZqmbHxyU=",
        'Host'=>host
      }
    })
  end

  it "should list objects for bucket" do
    assert_aliyun_api(:bucket_list_objects, [ 'prefix' => 'test-', 'max-keys' => 10 ], {
      verb: :get,
      bucket: bucket,
      query: {
        'prefix' => 'test-',
        'max-keys' => 10
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:tEjpM9FeBqYU9+0xMHMUyIY38tI=",
        'Host'=>host
      }
    })
  end

  it "should set acl" do
    assert_aliyun_api(:bucket_set_acl, ['private'], {
      verb: :put,
      bucket: bucket,
      query: {
        "acl" => true
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:MuVkXCBd0yK1Nxfjjo8SlnutLS8=",
        'Content-Type'=>'application/x-www-form-urlencoded',
        'Host'=>host
      }
    })
  end

  it "should enable logging" do
    assert_aliyun_api(:bucket_enable_logging, ['oss-sdk-dev-beijing'], {
      verb: :put,
      bucket: bucket,
      query: {
        "logging" => true
      },
      body: {
        "<?xml version"=>"\"1.0\" encoding=\"UTF-8\"?><BucketLoggingStatus><LoggingEnabled><TargetBucket>oss-sdk-dev-beijing</TargetBucket></LoggingEnabled></BucketLoggingStatus>"
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:iR1Q+7Ne6j2iOqxEtv4xSzNKYgg=",
        'Content-Length'=>'162',
        'Content-Md5'=>'CjCvBqCfaTvwyyYko+mvGQ==',
        'Content-Type'=>'application/x-www-form-urlencoded',
        'Host'=>host
      }
    })
  end

  it "should disable logging" do
    assert_aliyun_api(:bucket_disable_logging, [], {
      verb: :delete,
      bucket: bucket,
      query: {
        "logging" => false
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:+FphnCDDR24XaUPNDnSar42C4NY=",
        'Content-Type'=>'application/x-www-form-urlencoded',
        'Host'=>host
      }
    })
  end

  it "should enable website" do
    assert_aliyun_api(:bucket_enable_website, ['index.html'], {
      verb: :put,
      bucket: bucket,
      query: {
        "website" => true
      },
      body: {
        "<?xml version"=>"\"1.0\" encoding=\"UTF-8\"?><WebsiteConfiguration><IndexDocument><Suffix>index.html</Suffix></IndexDocument></WebsiteConfiguration>"
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:XN7S00DlNeuAKTVnBw07j1S9gq0=",
        'Content-Length'=>'141',
        'Content-Md5'=>'2XgAS1GvtZHgjAJxFzd2Ew==',
        'Content-Type'=>'application/x-www-form-urlencoded',
        'Host'=>host
      }
    })
  end

  it "should disable website" do
    assert_aliyun_api(:bucket_disable_website, [], {
      verb: :delete,
      bucket: bucket,
      query: {
        "website" => false
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:W2QUdzNWTWxY3U168S0B8nGU89M=",
        'Content-Type'=>'application/x-www-form-urlencoded',
        'Host'=>host
      }
    })
  end

  it "should set referer" do
    assert_aliyun_api(:bucket_set_referer, [['http://aliyun.com'], true], {
      verb: :put,
      bucket: bucket,
      query: {
        "referer" => true
      },
      body: {
        "<?xml version"=>"\"1.0\" encoding=\"UTF-8\"?><RefererConfiguration><AllowEmptyReferer>true</AllowEmptyReferer><RefererList><Referer>http://aliyun.com</Referer></RefererList></RefererConfiguration>"
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:BYDY2X0MjoVPFNCAc8xUbCkr7r0=",
        'Content-Length'=>'189',
        'Content-Md5'=>'PcZd/oWyIQiSbnmz6it1Yg==',
        'Content-Type'=>'application/x-www-form-urlencoded',
        'Host'=>host
      }
    })
  end

  describe "should enable lifecycle" do
    it "with days" do
      rule = Aliyun::Oss::Rule::LifeCycle.new({prefix: 'oss-sdk', enable: true, days: 2})
      assert_aliyun_api(:bucket_enable_lifecycle, [[rule]], {
        verb: :put,
        bucket: bucket,
        query: {
          "lifecycle" => true
        },
        body: {
          "<?xml version"=>"\"1.0\" encoding=\"UTF-8\"?><LifecycleConfiguration><Rule><ID></ID><Prefix>oss-sdk</Prefix><Status>Enabled</Status><Expiration><Days>2</Days></Expiration></Rule></LifecycleConfiguration>"
        },
        headers: {
          'Authorization'=>"OSS #{access_key}:JF1GLykNBZ35mWYTnNlbH82HNm4=",
          'Content-Length'=>'196',
          'Content-Md5'=>'bd4TR+aF4bYcGgU9ZEIZHA==',
          'Content-Type'=>'application/x-www-form-urlencoded',
          'Host'=>host
        }
      })
    end

    it "with date" do
      rule = Aliyun::Oss::Rule::LifeCycle.new({prefix: 'oss-sdk', enable: false, date: Time.now})
      assert_aliyun_api(:bucket_enable_lifecycle, [[rule]], {
        verb: :put,
        bucket: bucket,
        query: {
          "lifecycle" => true
        },
        body: {
          "<?xml version"=>"\"1.0\" encoding=\"UTF-8\"?><LifecycleConfiguration><Rule><ID></ID><Prefix>oss-sdk</Prefix><Status>Disabled</Status><Expiration><Date>2015-10-25T00:00:00.000Z</Date></Expiration></Rule></LifecycleConfiguration>"
        },
        headers: {
          'Authorization'=>"OSS #{access_key}:IQYkF96EfNRM6ja81x4MNky3+vI=",
          'Content-Length'=>'220',
          'Content-Md5'=>'sGaWdrpJauJCWQyLLgpwhQ==',
          'Content-Type'=>'application/x-www-form-urlencoded',
          'Host'=>host
        }
      })
    end

    it "modify rule with id" do
      rule = Aliyun::Oss::Rule::LifeCycle.new({prefix: 'oss-sdk', enable: false, date: Time.now, id: 1})
      assert_aliyun_api(:bucket_enable_lifecycle, [[rule]], {
        verb: :put,
        bucket: bucket,
        query: {
          "lifecycle" => true
        },
        body: {
          "<?xml version"=>"\"1.0\" encoding=\"UTF-8\"?><LifecycleConfiguration><Rule><ID>1</ID><Prefix>oss-sdk</Prefix><Status>Disabled</Status><Expiration><Date>2015-10-25T00:00:00.000Z</Date></Expiration></Rule></LifecycleConfiguration>"
        },
        headers: {
          'Authorization'=>"OSS #{access_key}:weTefs2T9go6bvvbnrebb/Gajbs=",
          'Content-Length'=>'221',
          'Content-Md5'=>'bo7NQXBC+und0jZOF6mzhw==',
          'Content-Type'=>'application/x-www-form-urlencoded',
          'Host'=>host
        }
      })
    end
  end

  it "should disable lifecycle" do
    assert_aliyun_api(:bucket_disable_lifecycle, [], {
      verb: :delete,
      bucket: bucket,
      query: {
        "lifecycle" => false
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:AFL3V4C+8rZWREXxQk0ao+j22fI=",
        'Content-Type'=>'application/x-www-form-urlencoded',
        'Host'=>host
      }
    })
  end

  it "should enable cors" do
    rule = Aliyun::Oss::Rule::Cors.new({allowed_methods: ['get'], allowed_origins: ['*']})
    assert_aliyun_api(:bucket_enable_cors, [[rule]], {
      verb: :put,
      bucket: bucket,
      query: {
        "cors" => true
      },
      body: {
        "<?xml version"=>"\"1.0\" encoding=\"UTF-8\"?><CORSConfiguration><CORSRule><AllowedOrigin>*</AllowedOrigin><AllowedMethod>GET</AllowedMethod></CORSRule></CORSConfiguration>"
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:VZYmWdCcX//8npb0rXApKXt/KnM=",
        'Content-Length'=>'164',
        'Content-Md5'=>'WkO98hpPTvaWHVX6JdU94A==',
        'Content-Type'=>'application/x-www-form-urlencoded',
        'Host'=>host
      }
    })
  end

  it "should disable cors" do
    assert_aliyun_api(:bucket_disable_cors, [], {
      verb: :delete,
      bucket: bucket,
      query: {
        "cors" => false
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:kiu/cBLTnY0opBpFsYTpqq/EnJ8=",
        'Content-Type'=>'application/x-www-form-urlencoded',
        'Host'=>host
      }
    })
  end

  it "should options preflight" do
    assert_aliyun_api(:bucket_preflight, ['*', 'GET', [], 'index.html'], {
      verb: :options,
      bucket: bucket,
      key: 'index.html',
      headers: {
        'Access-Control-Request-Method'=>'GET',
        'Authorization'=>"OSS #{access_key}:fw0ssgeHFqMKUO0S1Lz0+Y8eZ4c=",
        'Origin'=>'*',
        'Host'=>host
      }
    })
  end

  it "should get acl" do
    assert_aliyun_api(:bucket_get_acl, [], {
      verb: :get,
      bucket: bucket,
      query: {
        "acl" => true
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:XFgxCKQf8vt6mRjrDIpL99KdXlI=",
        'Host'=>host
      }
    })
  end

  it "should get location" do
    assert_aliyun_api(:bucket_get_location, [], {
      verb: :get,
      bucket: bucket,
      query: {
        "location" => true
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:/kLkFDoUYU7g9QCdV6IOskpZTQQ=",
        'Host'=>host
      }
    })
  end

  it "should get referel" do
    assert_aliyun_api(:bucket_get_referer, [], {
      verb: :get,
      bucket: bucket,
      query: {
        "referer" => true
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:xY1upeRZvwcbOU0dluKwM6wQ+9s=",
        'Host'=>host
      }
    })
  end

  it "should get website" do
    assert_aliyun_api(:bucket_get_website, [], {
      verb: :get,
      bucket: bucket,
      query: {
        "website" => true
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:vvb0DajHf0u97NEFB+0wdY6QM/U=",
        'Host'=>host
      }
    })
  end

  it "should get lifecycle" do
    assert_aliyun_api(:bucket_get_lifecycle, [], {
      verb: :get,
      bucket: bucket,
      query: {
        "lifecycle" => true
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:w3HHVgoBn5xjVcm8D6pz4h182m0=",
        'Host'=>host
      }
    })
  end

  it "should get cors" do
    assert_aliyun_api(:bucket_get_cors, [], {
      verb: :get,
      bucket: bucket,
      query: {
        "cors" => true
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:rkF/gD5LywGqO1fXpsi1OI2mXy0=",
        'Host'=>host
      }
    })
  end

  it "should create bucket" do
    assert_aliyun_api(:bucket_create, ['oss-sdk-dev-beijingasdf1'], {
      verb: :put,
      bucket: 'oss-sdk-dev-beijingasdf1',
      location: 'oss-cn-hangzhou',
      query: {
        'acl' => true
      },
      body: {
        "<?xml version"=>"\"1.0\" encoding=\"UTF-8\"?><CreateBucketConfiguration><LocationConstraint>oss-cn-hangzhou</LocationConstraint></CreateBucketConfiguration>"
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:1xR363c082uMzJ4cvcfdH0ksoRI=",
        'Content-Length'=>'149',
        'Content-Md5'=>'xWIloG4+cjhzOjKOfM+neA==',
        'Content-Type'=>'application/x-www-form-urlencoded',
        'X-Oss-Acl'=>'private',
        'Host'=>'oss-sdk-dev-beijingasdf1.oss-cn-hangzhou.aliyuncs.com'
      }
    })
  end

  it "should delete bucket" do
    assert_aliyun_api(:bucket_delete, ['oss-sdk-dev-beijingasdf1'], {
      verb: :delete,
      bucket: 'oss-sdk-dev-beijingasdf1',
      headers: {
        'Authorization'=>"OSS #{access_key}:Hzf/LrQL34R8egT65PofEVAdRJQ=",
        'Content-Type'=>'application/x-www-form-urlencoded',
        'Host'=>'oss-sdk-dev-beijingasdf1.oss-cn-beijing.aliyuncs.com'
      }
    })
  end

  it "should create object" do
    assert_aliyun_api(:bucket_create_object, ['sample.txt', file, 'Content-Type' => 'text/plain', 'Expires' => (Time.now + 60*60*24).to_s, 'x-oss-object-acl' => 'private'], {
      verb: :put,
      bucket: bucket,
      key: 'sample.txt',
      body: "Hello Aliyun!\n",
      headers: {
        'Authorization'=>"OSS #{access_key}:HvKL8lVNOdRKT4nnR1Nk5ST6iT4=",
        'Content-Length'=>'14',
        'Content-Md5'=>'m9ZRM//n4gnKcX4iiVVQEQ==',
        'Content-Type'=>'text/plain',
        'X-Oss-Object-Acl'=>'private',
        'Expires'=>'2015-10-26 08:46:00 +0800',
        'Host'=>host
      }
    })
  end

  it "should delete object" do
    assert_aliyun_api(:bucket_delete_object, ['sample.txt'], {
      verb: :delete,
      bucket: bucket,
      key: 'sample.txt',
      headers: {
        'Authorization'=>"OSS #{access_key}:ImZcptGREHlIcofGVeHYqEArrSM=",
        'Content-Type'=>'application/x-www-form-urlencoded',
        'Host'=>host
      }
    })
  end

  it "should delete objects" do
    assert_aliyun_api(:bucket_delete_objects, [['sample.txt', '1.png']], {
      verb: :post,
      bucket: bucket,
      query: {
        "delete" => true
      },
      body: {
        "<?xml version"=>"\"1.0\" encoding=\"UTF-8\"?><Delete><Object><Key>sample.txt</Key></Object><Object><Key>1.png</Key></Object><Quiet>false</Quiet></Delete>"
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:ha8ZyCSRQR5E+5uLr3xuw/iI2KI=",
        'Content-Length'=>'146',
        'Content-Md5'=>'8lzvY5zEmkiZPH/k5SeZew==',
        'Content-Type'=>'application/x-www-form-urlencoded',
        'Host'=>host
      }
    })
  end

  it "should get object" do
    assert_aliyun_api(:bucket_get_object, ['sample.txt', { 'response-content-type' => 'text' }, {'Range' => 'bytes=0-10'}], {
      verb: :get,
      key: 'sample.txt',
      bucket: bucket,
      query: {
        "response-content-type" => 'text'
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:N8RmknYZRIgmooGLSmWfwwuJWAU=",
        'Range'=>'bytes=0-10',
        'Host'=>host
      }
    })
  end

  it "should set object acl" do
    assert_aliyun_api(:bucket_set_object_acl, ['sample.txt', 'public-write'], {
      verb: :put,
      bucket: bucket,
      key: 'sample.txt',
      query: {
        "acl" => true
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:DkcVkAyXw+goQ8Bci9cyTTITbKI=",
        'Content-Type'=>'application/x-www-form-urlencoded',
        'x-oss-object-acl'=>'public-write',
        'Host'=>host
      }
    })
  end

  it "should get object acl" do
    assert_aliyun_api(:bucket_get_object_acl, ['sample.txt'], {
      verb: :get,
      bucket: bucket,
      key: 'sample.txt',
      query: {
        "acl" => true
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:hztfJWk6W75LWVtb3vuu4F4CsbU=",
        'Host'=>host
      }
    })
  end

  it "should get object meta information" do
    assert_aliyun_api(:bucket_get_meta_object, ['sample.txt', { 'If-Match' => 'xxssddsewww' }], {
      verb: :head,
      bucket: bucket,
      key: 'sample.txt',
      headers: {
        'Authorization'=>"OSS #{access_key}:p/dcGaI5r8KPInPRVZbDwXu1y6I=",
        'If-Match' => 'xxssddsewww',
        'Host'=>host
      }
    })
  end

  it "should copy object" do
    assert_aliyun_api(:bucket_copy_object, ['sample1.txt', 'oss-sdk-dev-beijing', 'sample.txt', { 'x-oss-metadata-directive' => 'REPLACE'}], {
      verb: :put,
      bucket: bucket,
      key: 'sample1.txt',
      headers: {
        'Authorization'=>"OSS #{access_key}:IKd5Ea4oYZNVZIfsWNr3iP8y6bQ=",
        'X-Oss-Copy-Source'=>'/oss-sdk-dev-beijing/sample.txt',
        'X-Oss-Metadata-Directive'=>'REPLACE',
        'Host'=>host
      }
    })
  end

  it "should append object" do
    assert_aliyun_api(:bucket_append_object, ['sample2.txt', file, 0], {
      verb: :post,
      bucket: bucket,
      key: 'sample2.txt',
      query: {
        "append" => true,
        "position" => 0
      },
      body: {
        "Hello Aliyun!\n" => true
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:SMB4hza4OlNGl0PsFQqkHUJ5f3g=",
        'Content-Length'=>'14',
        'Content-Md5'=>'m9ZRM//n4gnKcX4iiVVQEQ==',
        'Content-Type'=>'application/x-www-form-urlencoded',
        'Host'=>host
      }
    })
  end

  it "should list parts of multipart" do
    assert_aliyun_api(:bucket_list_parts, ["sample_multipart.data", "98A6524428734723BE8F81D72B5295EE"], {
      verb: :get,
      bucket: bucket,
      key: 'sample_multipart.data',
      query: {
        "uploadId" => "98A6524428734723BE8F81D72B5295EE"
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:Jgy2nPjPHHvWR4TO0RYmO1d4nro=",
        'Host'=>host
      }
    })
  end

  it "should complete multipart" do
    part1 = Aliyun::Oss::Multipart::Part.new({ number: 1, etag: "EDB4BC6E69180BC4759633E7B0EED0E0" })
    part2 = Aliyun::Oss::Multipart::Part.new({ number: 2, etag: "EDB4BC6E69180BC4759633E7B0ESJKHW" })
    assert_aliyun_api(:bucket_complete_multipart, ["sample_multipart.data", "98A6524428734723BE8F81D72B5295EE", [part1, part2]], {
      verb: :post,
      bucket: bucket,
      key: 'sample_multipart.data',
      query: {
        "uploadId" => "98A6524428734723BE8F81D72B5295EE"
      },
      body: {
        "<?xml version"=>"\"1.0\" encoding=\"UTF-8\"?><CompleteMultipartUpload><Part><PartNumber>1</PartNumber><ETag>EDB4BC6E69180BC4759633E7B0EED0E0</ETag></Part><Part><PartNumber>2</PartNumber><ETag>EDB4BC6E69180BC4759633E7B0ESJKHW</ETag></Part></CompleteMultipartUpload>"
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:5XzwIMUQ30Qc7vWT/rNkDIBNy4Q=",
        'Content-Length'=>'257',
        'Content-Md5'=>'tUnMAspz0Ipv/7qrTr038w==',
        'Content-Type'=>'application/x-www-form-urlencoded',
        'Host'=>host
      }
    })
  end

  it "should init multipart" do
    assert_aliyun_api(:bucket_init_multipart, ["sample_multipart.data", { 'Content-Type' => 'video/avi' }], {
      verb: :post,
      bucket: bucket,
      key: 'sample_multipart.data',
      query: {
        "uploads" => true
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:GgXYHLxr6gIobvydSmiSpudFtZg=",
        'Content-Type' => 'video/avi',
        'Host'=>host
      }
    })
  end

  it "should multipart upload" do
    assert_aliyun_api(:bucket_multipart_upload, ["sample_multipart.data", 1, "98A6524428734723BE8F81D72B5295EE", file], {
      verb: :put,
      bucket: bucket,
      key: 'sample_multipart.data',
      query: {
        "partNumber" => 1,
        "uploadId" => "98A6524428734723BE8F81D72B5295EE"
      },
      body: {
        "Hello Aliyun!\n"=>true
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:aOlDC/cCiov7kXBhPYnjsbKyup0=",
        'Content-Length'=>'14',
        'Content-Md5'=>'m9ZRM//n4gnKcX4iiVVQEQ==',
        'Content-Type'=>'application/x-www-form-urlencoded',
        'Host'=>host
      }
    })
  end

  it "should multipart copy upload" do
    assert_aliyun_api(:bucket_multipart_copy_upload, ["sample_multipart.data", 1, "98A6524428734723BE8F81D72B5295EE", source_bucket: 'oss-sdk-dev-beijing', source_key: 'sample.png', range: 'bytes=0-100'], {
      verb: :put,
      bucket: bucket,
      key: 'sample_multipart.data',
      query: {
        "partNumber" => 1,
        "uploadId" => "98A6524428734723BE8F81D72B5295EE"
      },
      body: {
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:MxvSGFFnTZPGungmIkgIABin1CM=",
        'Content-Type'=>'application/x-www-form-urlencoded',
        'X-Oss-Copy-Source'=>'/oss-sdk-dev-beijing/sample.png',
        'X-Oss-Copy-Source-Range'=>'bytes=0-100',
        'Host'=>host
      }
    })
  end

  it "should abort multipart" do
    assert_aliyun_api(:bucket_abort_multipart, ["sample_multipart.data", "9FB6F32C2DC24E04B813963B58E29E68"], {
      verb: :delete,
      bucket: bucket,
      key: 'sample_multipart.data',
      query: {
        "uploadId" => "9FB6F32C2DC24E04B813963B58E29E68"
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:6CkOOtUdQzJC5kmb2qDcjFHOwV8=",
        'Content-Type'=>'application/x-www-form-urlencoded',
        'Host'=>host
      }
    })
  end

  it "should list multiparts" do
    assert_aliyun_api(:bucket_list_multiparts, [], {
      verb: :get,
      bucket: bucket,
      query: {
        "uploads" => true
      },
      headers: {
        'Authorization'=>"OSS #{access_key}:fcrsrhiYJ41N11dNCjzLDg9qLgY=",
        'Host'=>host
      }
    })
  end

end
