require 'test_helper'

describe Aliyun::Oss::Struct::Bucket do
  let(:bucket_name) { 'bucket-name' }
  let(:bucket_location) { 'oss-cn-beijing' }
  let(:host) { "#{bucket_location}.aliyuncs.com" }
  let(:endpoint) { "http://#{bucket_name}.#{host}/" }
  let(:access_key) { 'AASSJJKKW94324JJJJ' }
  let(:secret_key) { 'OtSSSSxIsf111A7SwPzILwy8Bw21TLhquhboDYROV' }
  let(:client) do
    Aliyun::Oss::Client.new(
      access_key,
      secret_key,
      host: host,
      bucket: bucket_name
    )
  end
  let(:bucket) do
    Aliyun::Oss::Struct::Bucket.new(
      name: bucket_name,
      location: location,
      client: client
    )
  end

  it '#location! should get via HTTP' do
    stub_get_request(endpoint + '?location=true', 'bucket/location.xml')
    assert_equal('oss-cn-hangzhou', bucket.location!)
  end

  describe '#logging!' do
    it 'should get via HTTP' do
      stub_get_request(endpoint + '?logging=true', 'bucket/logging.xml')
      logging = bucket.logging!

      assert_kind_of(Aliyun::Oss::Struct::Logging, logging)
      assert_equal(true, logging.logging_enabled)
      assert_equal('mybucketlogs', logging.target_bucket)
      assert_equal('mybucket-access_log/', logging.target_prefix)
    end

    it 'when not set logging' do
      stub_get_request(endpoint + '?logging=true', 'bucket/no_logging.xml')
      logging = bucket.logging!

      assert_kind_of(Aliyun::Oss::Struct::Logging, logging)
      assert_equal(false, logging.logging_enabled)
    end
  end

  it '#acl! should get via HTTP' do
    stub_get_request(endpoint + '?acl=true', 'bucket/acl.xml')
    assert_equal('private', bucket.acl!)
  end

  it '#website! should get via HTTP' do
    stub_get_request(endpoint + '?website=true', 'bucket/website.xml')
    obj = bucket.website!

    assert_kind_of(Aliyun::Oss::Struct::Website, obj)
    assert_equal('index.html', obj.suffix)
    assert_equal('error.html', obj.error_key)
  end

  describe '#referer!' do
    it 'should get via HTTP' do
      stub_get_request(endpoint + '?referer=true', 'bucket/referer.xml')
      obj = bucket.referer!

      assert_kind_of(Aliyun::Oss::Struct::Referer, obj)
      assert_equal(false, obj.allow_empty)
      assert_equal([
        'http://www.aliyun.com',
        'https://www.aliyun.com',
        'http://www.*.com',
        'https://www.?.aliyuncs.com'
      ], obj.referers)
    end

    it 'when not set referer' do
      stub_get_request(endpoint + '?referer=true', 'bucket/no_referer.xml')
      obj = bucket.referer!

      assert_kind_of(Aliyun::Oss::Struct::Referer, obj)
      assert_equal(true, obj.allow_empty)
    end
  end

  describe '#lifecycle!' do
    it 'for days lifecycle' do
      stub_get_request(endpoint + '?lifecycle=true', 'bucket/days_lifecycle.xml')
      bucket.lifecycle!.each do |obj|
        assert_kind_of(Aliyun::Oss::Struct::LifeCycle, obj)
        assert_equal('delete after one day', obj.id)
        assert_equal('logs/', obj.prefix)
        assert_equal(true, obj.enabled)
        assert_equal(1, obj.days)
      end
    end

    it 'for date lifecycle' do
      stub_get_request(endpoint + '?lifecycle=true', 'bucket/date_lifecycle.xml')
      bucket.lifecycle!.each do |obj|
        assert_kind_of(Aliyun::Oss::Struct::LifeCycle, obj)
        assert_equal('delete at date', obj.id)
        assert_equal('logs/', obj.prefix)
        assert_equal(true, obj.enabled)
        assert_equal('2022-10-11 00:00:00 UTC', obj.date.to_s)
      end
    end

    it 'when not set lifecycle' do
      path = endpoint + '?lifecycle=true'
      stub_get_request(path, 'bucket/no_lifecycle.xml', status: 404)
      assert_raises(Aliyun::Oss::RequestError) do
        bucket.lifecycle!
      end
    end
  end

  it '#cors! should get via HTTP' do
    stub_get_request(endpoint + '?cors=true', 'bucket/cors.xml')

    bucket.cors!.each do |obj|
      assert_kind_of(Aliyun::Oss::Struct::Cors, obj)
      assert_equal(['*'], obj.allowed_origin)
      assert_equal(['GET'], obj.allowed_method)
      assert_equal(['*'], obj.allowed_header)
      assert_equal(['x-oss-test'], obj.expose_header)
      assert_equal('100', obj.max_age_seconds)
    end
  end

  it '#enable_lifecycle should invoke #bucket_enable_lifecycle & return true' do
    stub_put_request(endpoint + '?lifecycle=true', '')
    rule = Aliyun::Oss::Struct::LifeCycle.new(
      prefix: 'oss-sdk',
      enabled: false,
      date: Time.now
    )
    assert bucket.enable_lifecycle([rule])
  end

  it '#enable_cors should invoke #bucket_enable_cors & return true' do
    stub_put_request(endpoint + '?cors=true', '')
    rule = Aliyun::Oss::Struct::Cors.new(
      allowed_method: ['get'],
      allowed_origin: ['*']
    )
    assert bucket.enable_cors([rule])
  end

  it '#enable_logging should invoke #bucket_enable_logging & return true' do
    stub_put_request(endpoint + '?logging=true', '')
    assert bucket.enable_logging('oss-sdk-dev-beijing')
  end

  it '#enable_website should invoke #bucket_enable_website & return true' do
    stub_put_request(endpoint + '?website=true', '')
    assert bucket.enable_website('index.html')
  end

  %w(website lifecycle cors logging).each do |prop|
    it "#disable_#{prop} should invoke #bucket_disable_#{prop} & return true" do
      stub_delete_request(endpoint + "?#{prop}=false", '')
      assert bucket.send("disable_#{prop}".to_sym)
    end
  end

  it '#set_referer should invoke #bucket_set_referer & return true' do
    stub_put_request(endpoint + '?referer=true', '')
    assert bucket.set_referer(['http://aliyun.com'], true)
  end

  it '#set_acl should invoke #bucket_set_acl & return true' do
    stub_put_request(endpoint + '?acl=true', '')
    assert bucket.set_acl('private')
  end

  it '#preflight! should return true' do
    stub_options_request(endpoint + 'index.html', '')
    assert bucket.preflight('index.html', '*', 'GET')
    assert bucket.options('index.html', '*', 'GET')
  end
end
