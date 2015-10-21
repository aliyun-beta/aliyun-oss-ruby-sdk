require 'test_helper'

describe Aliyun::Oss::Multipart do
  before do
    @client = Aliyun::Oss::Client.new
    @multipart = Aliyun::Oss::Multipart.new(@client)
  end

  %w{ upload copy_upload complete abort list }.each do |method|
    it "should delegate #{method} to Client#multipart_#{method}_for" do
      @client.expects("multipart_#{method}_for").at_least_once
      @multipart.send(method)
    end
  end

end
