require 'test_helper'

describe Aliyun::Oss do
  before do
    @oss = Aliyun::Oss.new("ilowzBTRmVJb5CUr", "IlWd7Jcsls43DQjX5OXyemmRf1HyPN", endpoint: "http://oss-sdk-dev-beijing.oss-cn-beijing.aliyuncs.com", bucket: 'oss-sdk-dev-beijing')
  end

  it "should list buckets" do
    assert_kind_of(Hash, @oss.list_buckets)
  end

  it "should list objects for bucket" do
    assert_kind_of(Hash, @oss.client.bucket_list_objects)
  end

  it "should set acl" do
    assert(@oss.client.bucket_set_acl('private').success?)
  end

  it "should enable logging" do
    assert(@oss.client.bucket_enable_logging('oss-sdk-dev-beijing').success?)
  end

  it "should disable logging" do
   p 8888888, @oss.client.bucket_disable_logging
   assert(@oss.client.bucket_disable_logging.success?)
  end

  it "should enable website" do
    assert(@oss.client.bucket_enable_website('index.html').success?)
  end

  it "should disable website" do
    assert(@oss.client.bucket_disable_website.success?)
  end

  it "should set referer" do
    assert(@oss.client.bucket_set_referer([], true).success?)
  end

  describe "should enable lifecycle" do
    it "with days" do
      assert(@oss.client.bucket_enable_lifecycle([{'prefix' => 'oss-sdk', 'enable' => true, 'days' => 2}]).success?)
    end

    it "with date" do
      assert(@oss.client.bucket_enable_lifecycle([{'prefix' => 'oss-sdk', 'enable' => false, 'date' => Time.now}]).success?)
    end

    it "modify rule with id" do
      assert(@oss.client.bucket_enable_lifecycle([{'prefix' => 'oss-sdk-dev', 'enable' => false, 'date' => Time.now, 'id' => 1}]).success?) # modify rule 1
    end
  end

  it "should disable lifecycle" do
    assert(@oss.client.bucket_disable_lifecycle.success?)
  end

  it "should enable cors" do
    assert(@oss.client.bucket_enable_cors([{'allowed_methods' => ['get'], 'allowed_origins' => ['*']}]).success?)
  end

  it "should disable cors" do
    assert(@oss.client.bucket_disable_cors.success?)
  end

  it "should options preflight" do
    p 99999, @oss.client.bucket_preflight('*', 'GET', [], 'index.html')
    assert(@oss.client.bucket_preflight('*', 'GET', [], 'index.html').success?)
  end

  it "should get acl" do
    assert_kind_of(Hash, @oss.client.bucket_get_acl)
  end

  it "should get location" do
    assert_kind_of(Hash, @oss.client.bucket_get_location)
  end

  it "should get referel" do
    assert_kind_of(Hash, @oss.client.bucket_get_referer)
  end

  it "should get website" do
    assert_kind_of(Hash, @oss.client.bucket_get_website)
  end

  it "should get lifecycle" do
    assert_kind_of(Hash, @oss.client.bucket_get_lifecycle)
  end

  it "should get cors" do
    assert_kind_of(Hash, @oss.client.bucket_get_cors)
  end

end
