require 'test_helper'

describe Aliyun::Oss::Struct::Object do
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

  let(:object_key) { 'object-key' }
  let(:struct_object) do
    Aliyun::Oss::Struct::Object.new(
      key: object_key,
      client: client
    )
  end

  it "#acl! should get via HTTP & return string" do
    path = endpoint + object_key + "?acl=true"
    stub_get_request(path, "object/acl.xml")
    assert_equal('public-read', struct_object.acl!)
  end

  it "#set_acl! should result true" do
    path = endpoint + object_key + "?acl=true"
    stub_put_request(path, "")
    assert struct_object.set_acl('private')
  end

  it "#meta should return hash contains headers" do
    path = endpoint + object_key
    response_headers = { 'x-oss-meta-location' => 'hangzhou' }
    stub_head_request(path, "", response_headers: response_headers)

    headers = struct_object.meta!
    assert_equal('hangzhou', headers['x-oss-meta-location'])
  end

end
