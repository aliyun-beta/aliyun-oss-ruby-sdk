require 'test_helper'

describe Aliyun::Oss::Client do
  let(:host) { 'oss-cn-beijing.aliyuncs.com' }
  let(:bucket) { 'oss-sdk-dev-beijing' }
  let(:access_key) { '44CF9590006BF252F707' }
  let(:secret_key) { 'OtxrzxIsfpFjA7SwPzILwy8Bw21TLhquhboDYROV' }
  let(:default_headers) do
    {
      'User-Agent' => "aliyun-oss-sdk-ruby/#{Aliyun::Oss::VERSION} (#{RbConfig::CONFIG['host_os']} ruby-#{RbConfig::CONFIG['ruby_version']})",
      'Date' => 'Sun, 25 Oct 2015 00:46:00 GMT'
    }
  end

  let(:file) { File.new(File.join(File.dirname(__FILE__), '../fixtures/sample.txt')) }
  let(:client) { Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket) }

  before do
    Timecop.freeze(Time.parse('2015-10-25 08:46:00 +0800'))
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

    headers = default_headers.merge(response[:headers] || {}).merge('Host' => new_host)

    stub_request1 = stub_request(response[:verb], endpoint)
    .with(Aliyun::Oss::Utils
          .hash_slice(response, :query, :body, :headers)
          .merge(headers: headers))
    .to_return(status: 200, body: '', headers: {})
    client.send(method, *request)
    assert_requested(stub_request1)
  end

  %w(acl location referer website cors lifecycle).each do |property|
    it 'should get #{property}' do
      assert_aliyun_api("bucket_get_#{property}", [],
                        verb: :get,
                        bucket: bucket,
                        query: {
                          property => true
                        },
                        headers: {
                          'Authorization' => /OSS #{access_key}:\S*/,
                          'Host' => host
                        }
                       )
    end
  end

  %w(website cors lifecycle).each do |property|
    it 'should disable #{property}' do
      assert_aliyun_api("bucket_disable_#{property}", [],
                        verb: :delete,
                        bucket: bucket,
                        query: {
                          property => false
                        },
                        headers: {
                          'Authorization' => /OSS #{access_key}:\S*/,
                          'Content-Type' => 'application/x-www-form-urlencoded',
                          'Host' => host
                        }
                       )
    end
  end

  it 'should list buckets' do
    assert_aliyun_api(:list_buckets, [{ 'prefix' => 'oss-sdk' }], {
      verb: :get,
      query: {
        'prefix' => 'oss-sdk'
      },
      headers: {
        'Authorization' => /OSS #{access_key}:\S*/,
        'Host' => host
      }
    })
  end

  it 'should list objects for bucket' do
    assert_aliyun_api(:bucket_list_objects, [
      'prefix' => 'test-',
      'max-keys' => 10
    ],
    verb: :get,
    bucket: bucket,
    query: {
      'prefix' => 'test-',
      'max-keys' => 10
    },
    headers: {
      'Authorization' => /OSS #{access_key}:\S*/,
      'Host' => host
    }
                     )
  end

  it 'should set acl' do
    assert_aliyun_api(:bucket_set_acl, ['private'], {
      verb: :put,
      bucket: bucket,
      query: {
        'acl' => true
      },
      headers: {
        'Authorization' => /OSS #{access_key}:\S*/,
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Host' => host
      }
    })
  end

  it 'should enable logging' do
    assert_aliyun_api(:bucket_enable_logging, [
      'oss-sdk-dev-beijing'
    ],
    verb: :put,
    bucket: bucket,
    query: {
      'logging' => true
    },
    body: {
      "<?xml version"=>"\"1.0\" encoding=\"UTF-8\"?><BucketLoggingStatus><LoggingEnabled><TargetBucket>oss-sdk-dev-beijing</TargetBucket></LoggingEnabled></BucketLoggingStatus>"
    },
    headers: {
      'Authorization' => /OSS #{access_key}:\S*/,
      'Content-Length' => '162',
      'Content-Md5' => 'CjCvBqCfaTvwyyYko+mvGQ==',
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Host' => host
    }
                     )
  end

  it 'should enable website' do
    assert_aliyun_api(:bucket_enable_website, [
      'index.html'
    ],
    verb: :put,
    bucket: bucket,
    query: {
      'website' => true
    },
    headers: {
      'Authorization' => /OSS #{access_key}:\S*/,
      'Content-Length' => '141',
      'Content-Md5' => '2XgAS1GvtZHgjAJxFzd2Ew==',
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Host' => host
    }
                     )
  end

  it 'should set referer' do
    assert_aliyun_api(:bucket_set_referer, [
      ['http://aliyun.com'],
      true
    ],
    verb: :put,
    bucket: bucket,
    query: {
      'referer' => true
    },
    body: {
      '<?xml version' => "\"1.0\" encoding=\"UTF-8\"?><RefererConfiguration><AllowEmptyReferer>true</AllowEmptyReferer><RefererList><Referer>http://aliyun.com</Referer></RefererList></RefererConfiguration>"
    },
    headers: {
      'Authorization' => /OSS #{access_key}:\S*/,
      'Content-Length' => '189',
      'Content-Md5' => 'PcZd/oWyIQiSbnmz6it1Yg==',
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Host' => host
    }
                     )
  end

  describe 'should enable lifecycle' do
    it 'with days' do
      rule = Aliyun::Oss::Struct::LifeCycle.new(
        prefix: 'oss-sdk',
        enabled: true,
        days: 2
       )
      assert_aliyun_api(:bucket_enable_lifecycle, [[rule]], {
        verb: :put,
        bucket: bucket,
        query: {
          'lifecycle' => true
        },
        body: {
          '<?xml version' => "\"1.0\" encoding=\"UTF-8\"?><LifecycleConfiguration><Rule><ID></ID><Prefix>oss-sdk</Prefix><Status>Enabled</Status><Expiration><Days>2</Days></Expiration></Rule></LifecycleConfiguration>"
        },
        headers: {
          'Authorization' => /OSS #{access_key}:\S*/,
          'Content-Length' => '196',
          'Content-Md5' => 'bd4TR+aF4bYcGgU9ZEIZHA==',
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Host' => host
        }
      })
    end

    it 'with date' do
      rule = Aliyun::Oss::Struct::LifeCycle.new(
        prefix: 'oss-sdk',
        enabled: false,
        date: Time.now
      )
      assert_aliyun_api(:bucket_enable_lifecycle, [[rule]], {
        verb: :put,
        bucket: bucket,
        query: {
          'lifecycle' => true
        },
        body: {
          '<?xml version' => "\"1.0\" encoding=\"UTF-8\"?><LifecycleConfiguration><Rule><ID></ID><Prefix>oss-sdk</Prefix><Status>Disabled</Status><Expiration><Date>2015-10-25T00:00:00.000Z</Date></Expiration></Rule></LifecycleConfiguration>"
        },
        headers: {
          'Authorization' => /OSS #{access_key}:\S*/,
          'Content-Length' => '220',
          'Content-Md5' => 'sGaWdrpJauJCWQyLLgpwhQ==',
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Host' => host
        }
      })
    end

    it 'modify rule with id' do
      rule = Aliyun::Oss::Struct::LifeCycle.new(
        prefix: 'oss-sdk',
        enabled: false,
        date: Time.now,
        id: 1
      )
      assert_aliyun_api(:bucket_enable_lifecycle, [
        [rule]
      ],
      verb: :put,
      bucket: bucket,
      query: {
        'lifecycle' => true
      },
      body: {
        '<?xml version' => "\"1.0\" encoding=\"UTF-8\"?><LifecycleConfiguration><Rule><ID>1</ID><Prefix>oss-sdk</Prefix><Status>Disabled</Status><Expiration><Date>2015-10-25T00:00:00.000Z</Date></Expiration></Rule></LifecycleConfiguration>"
      },
      headers: {
        'Authorization' => /OSS #{access_key}:\S*/,
        'Content-Length' => '221',
        'Content-Md5' => 'bo7NQXBC+und0jZOF6mzhw==',
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Host' => host
      }
                       )
    end

    it 'should raise InvalidLifeCycleRuleError' do
      rule = Aliyun::Oss::Struct::LifeCycle.new
      assert_raises(Aliyun::Oss::InvalidLifeCycleRuleError) do
        client.bucket_enable_lifecycle(rule)
      end
    end
  end

  describe "enable_cors" do
    it 'should work' do
      rule = Aliyun::Oss::Struct::Cors.new(
        allowed_method: ['get'],
        allowed_origin: ['*']
      )
      assert_aliyun_api(:bucket_enable_cors, [
        [rule]
      ],
      verb: :put,
      bucket: bucket,
      query: { 'cors' => true },
      body: {
        '<?xml version' => "\"1.0\" encoding=\"UTF-8\"?><CORSConfiguration><CORSRule><AllowedOrigin>*</AllowedOrigin><AllowedMethod>GET</AllowedMethod></CORSRule></CORSConfiguration>"
      },
      headers: {
        'Authorization' => /OSS #{access_key}:\S*/,
        'Content-Length' => '164',
        'Content-Md5' => 'WkO98hpPTvaWHVX6JdU94A==',
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Host' => host
      })
    end

    it 'should raise Invalid Cors Rule Error' do
      rule = Aliyun::Oss::Struct::Cors.new(
        allowed_method: ['get']
      )
      assert_raises(Aliyun::Oss::InvalidCorsRuleError) do
        client.bucket_enable_cors(rule)
      end
    end
  end

  it 'should options preflight' do
    assert_aliyun_api(:bucket_preflight, ['index.html', '*', 'GET'], {
      verb: :options,
      bucket: bucket,
      key: 'index.html',
      headers: {
        'Access-Control-Request-Method' => 'GET',
        'Authorization' => /OSS #{access_key}:\S*/,
        'Origin' => '*',
        'Host' => host
      }
    })
  end

  it 'should create bucket' do
    assert_aliyun_api(:bucket_create, ['oss-sdk-dev-beijingasdf1'],
                      verb: :put,
                      bucket: 'oss-sdk-dev-beijingasdf1',
                      location: 'oss-cn-hangzhou',
                      query: {
                        'acl' => true
                      },
                      body: {
                        '<?xml version' => "\"1.0\" encoding=\"UTF-8\"?><CreateBucketConfiguration><LocationConstraint>oss-cn-hangzhou</LocationConstraint></CreateBucketConfiguration>"
                      },
                      headers: {
                        'Authorization' => /OSS #{access_key}:\S*/,
                        'Content-Length' => '149',
                        'Content-Md5' => 'xWIloG4+cjhzOjKOfM+neA==',
                        'Content-Type' => 'application/x-www-form-urlencoded',
                        'X-Oss-Acl' => 'private',
                        'Host' => 'oss-sdk-dev-beijingasdf1.oss-cn-hangzhou.aliyuncs.com'
                      }
                     )
  end

  it 'should delete bucket' do
    assert_aliyun_api(:bucket_delete, ['oss-sdk-dev-beijingasdf1'], {
      verb: :delete,
      bucket: 'oss-sdk-dev-beijingasdf1',
      headers: {
        'Authorization' => /OSS #{access_key}:\S*/,
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Host' => 'oss-sdk-dev-beijingasdf1.oss-cn-beijing.aliyuncs.com'
      }
    })
  end

  it 'should create object' do
    assert_aliyun_api(:bucket_create_object, [
      'sample.txt',
      file,
      'Content-Type' => 'text/plain',
      'Expires' => (Time.now + 60 * 60 * 24).to_s,
      'x-oss-object-acl' => 'private'
    ], {
      verb: :put,
      bucket: bucket,
      key: 'sample.txt',
      body: "Hello Aliyun!\n",
      headers: {
        'Authorization' => /OSS #{access_key}:\S*/,
        'Content-Length' => '14',
        'Content-Md5' => 'm9ZRM//n4gnKcX4iiVVQEQ==',
        'Content-Type' => 'text/plain',
        'X-Oss-Object-Acl' => 'private',
        'Expires' => (Time.now + 60 * 60 * 24).to_s,
        'Host' => host
      }
    })
  end

  it 'should delete object' do
    assert_aliyun_api(:bucket_delete_object, ['sample.txt'], {
      verb: :delete,
      bucket: bucket,
      key: 'sample.txt',
      headers: {
        'Authorization' => /OSS #{access_key}:\S*/,
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Host' => host
      }
    })
  end

  it 'should delete objects' do
    assert_aliyun_api(:bucket_delete_objects, [['sample.txt', '1.png']],
                      verb: :post,
                      bucket: bucket,
                      query: {
                        'delete' => true
                      },
                      body: {
                        '<?xml version' => "\"1.0\" encoding=\"UTF-8\"?><Delete><Object><Key>sample.txt</Key></Object><Object><Key>1.png</Key></Object><Quiet>false</Quiet></Delete>"
                      },
                      headers: {
                        'Authorization' => /OSS #{access_key}:\S*/,
                        'Content-Length' => '146',
                        'Content-Md5' => '8lzvY5zEmkiZPH/k5SeZew==',
                        'Content-Type' => 'application/x-www-form-urlencoded',
                        'Host' => host
                      }
                     )
  end

  it 'should get object' do
    assert_aliyun_api(:bucket_get_object, [
      'sample.txt',
      { 'response-content-type' => 'text' },
      { 'Range' => 'bytes=0-10' }
    ],
    verb: :get,
    key: 'sample.txt',
    bucket: bucket,
    query: {
      'response-content-type' => 'text'
    },
    headers: {
      'Authorization' => /OSS #{access_key}:\S*/,
      'Range' => 'bytes=0-10',
      'Host' => host
    }
                     )
  end

  it 'should set object acl' do
    assert_aliyun_api(:bucket_set_object_acl, [
      'sample.txt',
      'public-write'
    ],
    verb: :put,
    bucket: bucket,
    key: 'sample.txt',
    query: {
      'acl' => true
    },
    headers: {
      'Authorization' => /OSS #{access_key}:\S*/,
      'Content-Type' => 'application/x-www-form-urlencoded',
      'x-oss-object-acl' => 'public-write',
      'Host' => host
    })
  end

  it 'should get object acl' do
    assert_aliyun_api(:bucket_get_object_acl, ['sample.txt'], {
      verb: :get,
      bucket: bucket,
      key: 'sample.txt',
      query: {
        'acl' => true
      },
      headers: {
        'Authorization' => /OSS #{access_key}:\S*/,
        'Host' => host
      }
    })
  end

  it 'should get object meta information' do
    assert_aliyun_api(:bucket_get_meta_object, ['sample.txt', { 'If-Match' => 'xxssddsewww' }], {
      verb: :head,
      bucket: bucket,
      key: 'sample.txt',
      headers: {
        'Authorization' => /OSS #{access_key}:\S*/,
        'If-Match' => 'xxssddsewww',
        'Host' => host
      }
    })
  end

  it 'should copy object' do
    assert_aliyun_api(:bucket_copy_object, ['sample1.txt', 'oss-sdk-dev-beijing', 'sample.txt', { 'x-oss-metadata-directive' => 'REPLACE' }], {
      verb: :put,
      bucket: bucket,
      key: 'sample1.txt',
      headers: {
        'Authorization' => /OSS #{access_key}:\S*/,
        'X-Oss-Copy-Source' => '/oss-sdk-dev-beijing/sample.txt',
        'X-Oss-Metadata-Directive' => 'REPLACE',
        'Host' => host
      }
    })
  end

  it 'should append object' do
    assert_aliyun_api(:bucket_append_object, ['sample2.txt', file, 0], {
      verb: :post,
      bucket: bucket,
      key: 'sample2.txt',
      query: {
        'append' => true,
        'position' => 0
      },
      body: {
        "Hello Aliyun!\n" => true
      },
      headers: {
        'Authorization' => /OSS #{access_key}:\S*/,
        'Content-Length' => '14',
        'Content-Md5' => 'm9ZRM//n4gnKcX4iiVVQEQ==',
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Host' => host
      }
    })
  end

  it 'should list parts of multipart' do
    assert_aliyun_api(:bucket_list_parts, [
      '98A6524428734723BE8F81D72B5295EE',
      'sample_multipart.data'
    ], {
      verb: :get,
      bucket: bucket,
      key: 'sample_multipart.data',
      query: {
        'uploadId' => '98A6524428734723BE8F81D72B5295EE'
      },
      headers: {
        'Authorization' => /OSS #{access_key}:\S*/,
        'Host' => host
      }
    })
  end

  it 'should complete multipart' do
    part1 = Aliyun::Oss::Struct::Part.new(
      number: 1, etag: 'EDB4BC6E69180BC4759633E7B0EED0E0'
    )
    part2 = Aliyun::Oss::Struct::Part.new(
      number: 2,
      etag: 'EDB4BC6E69180BC4759633E7B0ESJKHW'
    )
    assert_aliyun_api(:bucket_complete_multipart, [
      '98A6524428734723BE8F81D72B5295EE',
      'sample_multipart.data',
      [part1, part2]
    ],
    verb: :post,
    bucket: bucket,
    key: 'sample_multipart.data',
    query: {
      'uploadId' => '98A6524428734723BE8F81D72B5295EE'
    },
    body: {
      '<?xml version' => "\"1.0\" encoding=\"UTF-8\"?><CompleteMultipartUpload><Part><PartNumber>1</PartNumber><ETag>EDB4BC6E69180BC4759633E7B0EED0E0</ETag></Part><Part><PartNumber>2</PartNumber><ETag>EDB4BC6E69180BC4759633E7B0ESJKHW</ETag></Part></CompleteMultipartUpload>"
    },
    headers: {
      'Authorization' => /OSS #{access_key}:\S*/,
      'Content-Length' => '257',
      'Content-Md5' => 'tUnMAspz0Ipv/7qrTr038w==',
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Host' => host
    })
  end

  it 'should init multipart' do
    assert_aliyun_api(:bucket_init_multipart, [
      'sample_multipart.data',
      { 'Content-Type' => 'video/avi' }
    ],
    verb: :post,
    bucket: bucket,
    key: 'sample_multipart.data',
    query: {
      'uploads' => true
    },
    headers: {
      'Authorization' => /OSS #{access_key}:\S*/,
      'Content-Type' => 'video/avi',
      'Host' => host
    })
  end

  it 'should multipart upload' do
    assert_aliyun_api(:bucket_multipart_upload, [
      '98A6524428734723BE8F81D72B5295EE',
      'sample_multipart.data',
      1,
      file
    ],
    verb: :put,
    bucket: bucket,
    key: 'sample_multipart.data',
    query: {
      'partNumber' => 1,
      'uploadId' => '98A6524428734723BE8F81D72B5295EE'
    },
    body: {
      "Hello Aliyun!\n" => true
    },
    headers: {
      'Authorization' => /OSS #{access_key}:\S*/,
      'Content-Length' => '14',
      'Content-Md5' => 'm9ZRM//n4gnKcX4iiVVQEQ==',
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Host' => host
    })
  end

  it 'should multipart copy upload' do
    assert_aliyun_api(:bucket_multipart_copy_upload, [
      '98A6524428734723BE8F81D72B5295EE',
      'sample_multipart.data',
      1,
      source_bucket: 'oss-sdk-dev-beijing',
      source_key: 'sample.png',
      range: 'bytes=0-100'
    ],
    verb: :put,
    bucket: bucket,
    key: 'sample_multipart.data',
    query: {
      'partNumber' => 1,
      'uploadId' => '98A6524428734723BE8F81D72B5295EE'
    },
    body: {
    },
    headers: {
      'Authorization' => /OSS #{access_key}:\S*/,
      'Content-Type' => 'application/x-www-form-urlencoded',
      'X-Oss-Copy-Source' => '/oss-sdk-dev-beijing/sample.png',
      'X-Oss-Copy-Source-Range' => 'bytes=0-100',
      'Host' => host
    })
  end

  it 'should abort multipart' do
    assert_aliyun_api(:bucket_abort_multipart, [
      '9FB6F32C2DC24E04B813963B58E29E68',
      'sample_multipart.data',
    ],
    verb: :delete,
    bucket: bucket,
    key: 'sample_multipart.data',
    query: {
      'uploadId' => '9FB6F32C2DC24E04B813963B58E29E68'
    },
    headers: {
      'Authorization' => /OSS #{access_key}:\S*/,
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Host' => host
    })
  end

  it 'should list multiparts' do
    assert_aliyun_api(:bucket_list_multiparts, [], {
      verb: :get,
      bucket: bucket,
      query: {
        'uploads' => true
      },
      headers: {
        'Authorization' => /OSS #{access_key}:\S*/,
        'Host' => host
      }
    })
  end
end
