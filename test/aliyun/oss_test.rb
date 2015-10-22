require 'test_helper'

describe Aliyun::Oss do
  before do
    @oss = Aliyun::Oss.new("http://oss-cn-hangzhou.aliyuncs.com/", "ilowzBTRmVJb5CUr", "IlWd7Jcsls43DQjX5OXyemmRf1HyPN")
  end

  it "should list buckets" do
    assert_kind_of(Hash, @oss.list_buckets)
  end

  it "should list objects for bucket" do
    bucket = Aliyun::Oss::Bucket.new(@oss.client, "oss-sdk-dev-beijing", "oss-cn-beijing", Time.parse("2015-10-21T12:54:47.000Z"))
    assert_kind_of(Hash, @oss.client.bucket_list_objects_for(bucket))
  end
end
