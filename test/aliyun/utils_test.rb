require 'test_helper'

describe Aliyun::Oss::Utils do

  it "should get authorization string" do
    authorization_value = Aliyun::Oss::Utils.authorization("44CF9590006BF252F707", "OtxrzxIsfpFjA7SwPzILwy8Bw21TLhquhboDYROV", verb: 'PUT', headers: { 'Content-MD5' => 'ODBGOERFMDMzQTczRUY3NUE3NzA5QzdFNUYzMDQxNEM=', 'Content-Type' => 'text/html', 'x-oss-magic' => 'abracadabra', 'x-oss-meta-author' => 'foo@bar.com' }, date: "Thu, 17 Nov 2005 18:49:58 GMT", bucket: 'oss-example', key: 'nelson' )

    assert_equal("OSS 44CF9590006BF252F707:26NBxoKdsyly4EDv6inkoDft/yA=", authorization_value)
  end

  it "should get authorization string when missing headers" do
    authorization_value = Aliyun::Oss::Utils.authorization("44CF9590006BF252F707", "OtxrzxIsfpFjA7SwPzILwy8Bw21TLhquhboDYROV", verb: 'PUT', headers: {}, date: 'Thu, 17 Nov 2005 18:49:58 GMT')
    assert_equal("OSS 44CF9590006BF252F707:PPaaX3Rt4ntpD31O9aqkyCf2pd4=", authorization_value)
  end

  it "should get authorization string when missing headers" do
    authorization_value = Aliyun::Oss::Utils.authorization("44CF9590006BF252F707", "OtxrzxIsfpFjA7SwPzILwy8Bw21TLhquhboDYROV", verb: 'PUT', headers: { 'x-oss-acl' => 'public-read-write', 'Content-Type' => 'application/x-www-form-urlencoded' }, date: 'Thu, 17 Nov 2005 18:49:58 GMT')
    assert_equal("OSS 44CF9590006BF252F707:oAX+EQyS37LggQ2ncGOpoeTfNQI=", authorization_value)
  end

end
