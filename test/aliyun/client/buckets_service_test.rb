require 'test_helper'

describe Aliyun::Oss::Client::BucketsService do
  let(:bucket) { 'bucket-name' }
  let(:bucket_location) { 'oss-cn-beijing' }
  let(:host) { "#{bucket_location}.aliyuncs.com" }
  let(:endpoint) { "http://#{bucket}.#{host}/" }
  let(:access_key) { 'AASSJJKKW94324JJJJ' }
  let(:secret_key) { 'OtSSSSxIsf111A7SwPzILwy8Bw21TLhquhboDYROV' }
  let(:client) { Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket) }

  it '#list should return buckets' do
    stub_get_request("http://#{host}/", 'buckets/list.xml')
    client.buckets.list.each do |obj|
      assert_kind_of(Aliyun::Oss::Struct::Bucket, obj)
      assert_equal(obj.name, obj.client.bucket)
    end
  end

  describe '#create' do
    let(:bucket_name) { 'valid-bucket-name' }
    let(:path) { "http://#{bucket_name}.#{host}/?acl=true" }

    it 'when 200 response' do
      stub_put_request(path, '', status: 200)
      assert client.buckets.create(bucket_name, 'oss-cn-beijing')
    end

    it 'should 400 response' do
      stub_put_request(path, 'error/400.xml', status: 400)
      assert_raises(Aliyun::Oss::RequestError) do
        client.buckets.create(bucket_name, 'oss-cn-beijing')
      end
    end
  end

  describe '#delete' do
    let(:bucket_name) { 'valid-bucket-name' }
    let(:path) { "http://#{bucket_name}.#{host}/" }

    it 'when 200 response' do
      stub_delete_request(path, '')
      assert client.buckets.delete(bucket_name)
    end

    it 'should bucket not empty' do
      stub_delete_request(path, 'error/409.xml', status: 409)
      assert_raises(Aliyun::Oss::RequestError) do
        client.buckets.delete(bucket_name)
      end
    end
  end
end
