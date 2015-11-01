require 'test_helper'

describe Aliyun::Oss::Struct::Multipart do
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

  let(:upload_id) { 'DFGHJRGHJTRHYJCVBNMCVBNGHJ' }
  let(:object_key) { 'multipart.data' }
  let(:multipart) do
    Aliyun::Oss::Struct::Multipart.new(
      upload_id: upload_id,
      key: object_key,
      client: client
    )
  end

  it '#upload should return headers' do
    path = endpoint + 'multipart.data'
    query = { 'partNumber' => 1, 'uploadId' => upload_id }
    headers = { 'ETag' => 'HFGHJRTYHJVBNMFGHJFGHJ' }
    stub_put_request(path, '', query: query, response_headers: headers)

    result = multipart.upload(1, 'hello')
    assert_kind_of(HTTParty::Response::Headers, result)
    assert_equal('HFGHJRTYHJVBNMFGHJFGHJ', result['ETag'])
  end

  it '#copy should return true' do
    path = endpoint + object_key
    query = { 'partNumber' => 1, 'uploadId' => upload_id }
    stub_put_request(path, '', query: query)

    options = {
      source_bucket: 'source-bucket-name',
      source_key: 'source-key',
      range: 'bytes=1-100'
    }

    assert multipart.copy(1, options)
  end

  it '#list_parts should return parts' do
    path = endpoint + object_key
    query = { 'uploadId' => upload_id }
    stub_get_request(path, 'multipart/list_parts.xml', query: query)

    multipart.list_parts.each do |part|
      assert_kind_of(Aliyun::Oss::Struct::Part, part)
      assert_equal('5', part.number)
      assert_equal('"7265F4D211B56873A381D321F586E4A9"', part.etag)
      assert_equal('2012-02-23 07:02:03 UTC', part.last_modified.to_s)
      assert_equal('1024', part.size)
    end
  end

  it '#complete should return the complete object' do
    part1 = Aliyun::Oss::Struct::Part.new(
      number: 1, etag: 'EDB4BC6E69180BC4759633E7B0EED0E0'
    )
    part2 = Aliyun::Oss::Struct::Part.new(
      number: 2, etag: 'EDB4BC6E69180BC4759633E7B0ESJKHW'
    )

    path = endpoint + object_key
    query = { 'uploadId' => upload_id }
    stub_post_request(path, 'multipart/complete.xml', query: query)

    obj = multipart.complete([part1, part2])

    assert_kind_of(Aliyun::Oss::Struct::Object, obj)
    assert_equal(path, obj.location)
    assert_equal(bucket_name, obj.bucket)
    assert_equal(object_key, obj.key)
  end

  it '#abort should return true' do
    path = endpoint + object_key
    query = { 'uploadId' => upload_id }
    stub_delete_request(path, '', query: query)

    assert multipart.abort
  end
end
