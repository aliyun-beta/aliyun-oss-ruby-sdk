require 'test_helper'

describe Aliyun::Oss::Client do
  let(:client) do
    Aliyun::Oss::Client.new("ilowzBTRmVJb5CUr",
                            "IlWd7Jcsls43DQjX5OXyemmRf1HyPN",
                            host: "oss-sdk-dev-beijing.oss-cn-beijing.aliyuncs.com",
                            bucket: 'oss-sdk-dev-beijing'
                           )
  end

  it "should list buckets" do
    assert_kind_of(Hash, client.list_buckets)
  end

  it "should list objects for bucket" do
    assert_kind_of(Hash, client.bucket_list_objects)
  end

  it "should set acl" do
    assert(client.bucket_set_acl('private').success?)
  end

  it "should enable logging" do
    assert(client.bucket_enable_logging('oss-sdk-dev-beijing').success?)
  end

  it "should disable logging" do
   assert(client.bucket_disable_logging.success?)
  end

  it "should enable website" do
    assert(client.bucket_enable_website('index.html').success?)
  end

  it "should disable website" do
    assert(client.bucket_disable_website.success?)
  end

  it "should set referer" do
    assert(client.bucket_set_referer([], true).success?)
  end

  describe "should enable lifecycle" do
    it "with days" do
      assert(client.bucket_enable_lifecycle([{'prefix' => 'oss-sdk', 'enable' => true, 'days' => 2}]).success?)
    end

    it "with date" do
      assert(client.bucket_enable_lifecycle([{'prefix' => 'oss-sdk', 'enable' => false, 'date' => Time.now}]).success?)
    end

    it "modify rule with id" do
      assert(client.bucket_enable_lifecycle([{'prefix' => 'oss-sdk-dev', 'enable' => false, 'date' => Time.now, 'id' => 1}]).success?) # modify rule 1
    end
  end

  it "should disable lifecycle" do
    assert(client.bucket_disable_lifecycle.success?)
  end

  it "should enable cors" do
    assert(client.bucket_enable_cors([{'allowed_methods' => ['get'], 'allowed_origins' => ['*']}]).success?)
  end

  it "should disable cors" do
    assert(client.bucket_disable_cors.success?)
  end

  it "should options preflight" do
    assert(client.bucket_preflight('*', 'GET', [], 'index.html'))
  end

  it "should get acl" do
    assert_kind_of(Hash, client.bucket_get_acl)
  end

  it "should get location" do
    assert_kind_of(Hash, client.bucket_get_location)
  end

  it "should get referel" do
    assert_kind_of(Hash, client.bucket_get_referer)
  end

  it "should get website" do
    assert_kind_of(Hash, client.bucket_get_website)
  end

  it "should get lifecycle" do
    assert_kind_of(Hash, client.bucket_get_lifecycle)
  end

  it "should get cors" do
    assert_kind_of(Hash, client.bucket_get_cors)
  end

  it "should create bucket" do
    # create bucket in real data
    # assert(client.bucket_create('oss-sdk-dev-beijingasdf1').success?)
  end

  it "should delete bucket" do
    # delete bucket in real data
    # assert(client.bucket_delete('oss-sdk-dev-beijingasdf1').success?)
  end

  it "should create object" do
    file = File.new("/Users/soffolk/code/freelancer/oschina/ruby-sdk/sample.png")
    assert(client.bucket_create_object('sample.png', file, 'Content-Type' => 'image/png', 'Expires' => Time.now.to_s, 'x-oss-object-acl' => 'private').success?)
  end

  it "should delete object" do
    assert(client.bucket_delete_object('sample.png').success?)
  end

  it "should delete objects" do
    assert(client.bucket_delete_objects(['sample.png', '1.png'], true).success?)
  end

  it "should get object" do
    assert_kind_of(String, client.bucket_get_object('sample.png', { 'response-content-type' => 'image/png' }, {'Range' => 'bytes=0-10'}))
  end

  it "should set object acl" do
    assert(client.bucket_set_object_acl('sample.png', 'public-write').success?)
  end

  it "should get object acl" do
    assert_kind_of(Hash, client.bucket_get_object_acl('sample.png'))
  end

end
