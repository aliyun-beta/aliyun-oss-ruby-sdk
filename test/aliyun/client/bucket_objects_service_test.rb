# encoding: utf-8
require 'test_helper'

describe Aliyun::Oss::Client::BucketObjectsService do
  let(:bucket) { 'bucket-name' }
  let(:bucket_location) { 'oss-cn-beijing' }
  let(:host) { "#{bucket_location}.aliyuncs.com" }
  let(:endpoint) { "http://#{bucket}.#{host}/" }
  let(:access_key) { 'AASSJJKKW94324JJJJ' }
  let(:secret_key) { 'OtSSSSxIsf111A7SwPzILwy8Bw21TLhquhboDYROV' }
  let(:client) { Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket) }

  let(:object_key) { 'object-key' }

  describe '#list' do
    it 'should return objects' do
      stub_get_request("http://#{bucket}.#{host}/", 'bucket_objects/list.xml')
      client.bucket_objects.list.each do |obj|
        assert_kind_of(Aliyun::Oss::Struct::File, obj)
      end
    end

    it 'should return directory' do
      stub_get_request("http://#{bucket}.#{host}/", 'bucket_objects/list_dir.xml')
      objs = client.bucket_objects.list

      assert_kind_of(Aliyun::Oss::Struct::Directory, objs.last)
      assert_equal('fun/movie/', objs.last.key)
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

    it 'should create file with chinese characters key' do
      stub_put_request("http://#{bucket}.#{host}/中文文件名.log", '')
      assert client.bucket_objects.create('中文文件名.log', 'Hello World!')
    end

    it 'should create file with special charaters key' do
      stub_put_request("http://#{bucket}.#{host}/special中文文件名.log", '')
      assert client.bucket_objects.create('special#中文文件名.log', 'Hello World!')

      stub_put_request("http://#{bucket}.#{host}/special25中文文件名.log", '')
      assert client.bucket_objects.create('special%25中文文件名.log', 'Hello World!')
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
    let(:path) { "http://#{bucket}.#{host}/" }
    let(:query) { { delete: true } }

    it 'when 200 response' do
      stub_post_request(path, '', query: query)
      assert client.bucket_objects.delete_multiple([object_key])
    end

    it 'when 400 Response' do
      stub_post_request(path, 'error/400.xml', status: 400, query: query)
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

  it '#append should return headers' do
    path = "http://#{bucket}.#{host}/#{object_key}"
    query = { append: true, position: 100 }
    headers = { 'x-oss-next-append-position' => 100 }
    stub_post_request(path, '', query: query, response_headers: headers)

    result = client.bucket_objects.append(object_key, 'Hello', 100)
    assert_kind_of(HTTParty::Response::Headers, result)
    assert_equal('100', result['x-oss-next-append-position'])
  end
end
