require 'test_helper'

describe Aliyun::Oss::Struct::File do
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
    Aliyun::Oss::Struct::File.new(
      key: object_key,
      client: client
    )
  end

  it '#share_link should get share link' do
    Timecop.freeze(Time.parse('2015-11-04 21:59:00 +0000')) do
      expected = 'http://bucket-name.oss-cn-beijing.aliyuncs.com/object-key?' \
        "OSSAccessKeyId=#{access_key}&Expires=1446677940&Signature=4vOq8+Tnk2ZVBOWYtwu/iYEnUaM="
      assert_equal(expected, struct_object.share_link(3600))
    end
  end
end
