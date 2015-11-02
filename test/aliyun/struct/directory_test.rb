require 'test_helper'

describe Aliyun::Oss::Struct::Directory do
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

  it '#list should list objects under directory' do
    path = "http://#{bucket_name}.#{host}/?prefix=fun/movie/"
    stub_get_request(path, 'directory/list.xml')
    dir = Aliyun::Oss::Struct::Directory.new(key: 'fun/movie/', client: client)
    dir.list.each do |obj|
      assert_kind_of(Aliyun::Oss::Struct::File, obj)
    end
  end
end
