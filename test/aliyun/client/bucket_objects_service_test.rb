require 'test_helper'
require 'aliyun/oss/client/clients'
require 'aliyun/oss/error'

describe Aliyun::Oss::Client::BucketObjectsService do
  let(:host) { 'oss-cn-beijing.aliyuncs.com' }
  let(:bucket) { 'oss-sdk-dev-beijing' }
  let(:access_key) { '44CF9590006BF252F707' }
  let(:secret_key) { 'OtxrzxIsfpFjA7SwPzILwy8Bw21TLhquhboDYROV' }
  let(:client) { Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket) }

  let(:object_key) { 'object-key' }

  it '#list should return objects' do
    stub_get_request("http://#{bucket}.#{host}/", 'bucket_objects/list.xml')
    client.bucket_objects.list.each do |obj|
      assert_kind_of(Aliyun::Oss::Struct::Object, obj)
    end
  end

  describe '#create' do
    let(:path) { "http://#{bucket}.#{host}/#{object_key}" }

    it 'when 200 response' do
      stub_put_request(path, '')
      assert client.bucket_objects.create(object_key, 'Hello World!')
    end

    it 'when 400 response' do
      stub_put_request(path, 'error/400.xml', status: 400)
      assert_raises(Aliyun::Oss::RequestError) do
        client.bucket_objects.create(object_key, 'Hello World!')
      end
    end
  end

  describe '#delete' do
    let(:path) { "http://#{bucket}.#{host}/#{object_key}" }

    it 'when 200 response' do
      stub_delete_request(path, '')
      assert client.bucket_objects.delete(object_key)
    end

    it 'when bucket not exist' do
      stub_delete_request(path, 'error/404.xml', status: 404)
      assert_raises(Aliyun::Oss::RequestError) do
        client.bucket_objects.delete(object_key)
      end
    end
  end

  describe '#delete_multiple' do
    let(:path) { "http://#{bucket}.#{host}/?delete" }

    it 'when 200 response' do
      stub_post_request(path, '')
      assert client.bucket_objects.delete_multiple([object_key])
    end

    it 'when 400 Response' do
      stub_post_request(path, 'error/400.xml', status: 400)
      assert_raises(Aliyun::Oss::RequestError) do
        client.bucket_objects.delete_multiple([object_key])
      end
    end
  end

  describe '#copy' do
    let(:source_bucket) { 'source-bucket-name' }
    let(:source_key) { 'source-key' }
    let(:path) { "http://#{bucket}.#{host}/#{object_key}" }

    it 'when 200 response' do
      stub_put_request(path, '')
      assert client.bucket_objects.copy(object_key, source_bucket, source_key)
    end

    it 'when 400 Response' do
      stub_put_request(path, 'error/400.xml', status: 400)
      assert_raises(Aliyun::Oss::RequestError) do
        client.bucket_objects.copy(object_key, source_bucket, source_key)
      end
    end
  end

  it '#get should return string' do
    path = "http://#{bucket}.#{host}/#{object_key}"
    stub_request(:get, path).to_return(body: 'Hello' * 1000, status: 200)
    assert_equal 'Hello' * 1000, client.bucket_objects.get(object_key)
  end

  it '#append should return true' do
    path = "http://#{bucket}.#{host}/#{object_key}?append&position=100"
    stub_post_request(path, '')
    assert client.bucket_objects.append(object_key, 'Hello', 100)
  end
end
