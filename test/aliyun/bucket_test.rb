require 'test_helper'

describe Aliyun::Oss::Bucket do
  before do
    @client = Aliyun::Oss::Client.new
    @bucket = Aliyun::Oss::Bucket.new(@client)
  end

  %w{
    list_objects set_acl enable_logging disable_logging enable_website disable_website set_referer set_lifecycle remove_lifecycle set_cors remove_cors preflight get_acl get_location get_logging get_website get_referer get_lifecycle get_cors create_object copy_object get_object delete_object delete_objects get_meta_object
  }.each do |method|
    it "should delegate #{method} to Client#bucket_#{method}_for" do
      @client.expects("bucket_#{method}_for").at_least_once
      @bucket.send(method)
    end
  end

end
