require 'test_helper'

describe Aliyun::Oss::Object do
  before do
    @client = Aliyun::Oss::Client.new
    @bucket = Aliyun::Oss::Bucket.new(@client)
    @object = Aliyun::Oss::Object.new(@bucket)
  end

  %w{ get delete get_meta }.each do |method|
    it "should delegate #{method} to Bucket##{method}_object" do
      @bucket.expects("#{method}_object").at_least_once
      @object.send(method)
    end
  end

end
