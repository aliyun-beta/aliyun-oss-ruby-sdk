require 'test_helper'

describe Aliyun::Oss::Client::BucketMultipartsService do
  let(:bucket) { 'bucket-name' }
  let(:bucket_location) { 'oss-cn-beijing' }
  let(:host) { "#{bucket_location}.aliyuncs.com" }
  let(:endpoint) { "http://#{bucket_name}.#{host}/" }
  let(:access_key) { 'AASSJJKKW94324JJJJ' }
  let(:secret_key) { 'OtSSSSxIsf111A7SwPzILwy8Bw21TLhquhboDYROV' }
  let(:client) { Aliyun::Oss::Client.new(access_key, secret_key, host: host, bucket: bucket) }

  let(:object_key) { 'multiparts.data' }

  it '#list should return multiparts' do
    path = "http://#{bucket}.#{host}/?uploads"
    stub_get_request(path, 'bucket_multiparts/list.xml')
    client.bucket_multiparts.list.each do |obj|
      assert_kind_of(Aliyun::Oss::Struct::Multipart, obj)
      assert_equal('multipart.data', obj.key)
      assert_equal('0004B999EF5A239BB9138C6227D69F95', obj.upload_id)
      assert_equal('2012-02-23 04:18:23 UTC', obj.initiated.to_s)
    end
  end

  it '#init should return multipart' do
    path = "http://#{bucket}.#{host}/#{object_key}?uploads"
    stub_post_request(path, 'bucket_multiparts/init.xml')
    obj = client.bucket_multiparts.init(object_key)

    assert_kind_of(Aliyun::Oss::Struct::Multipart, obj)
    assert_equal(client, obj.client)
  end
end
