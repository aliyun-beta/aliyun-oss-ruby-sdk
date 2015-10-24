require 'test_helper'

describe Aliyun::Oss::XmlBuilder do

  it "should convert hash to xml" do
    assert_equal "<?xml version=\"1.0\" encoding=\"UTF-8\"?><a><e>2</e><d>1</d></a><c>3</c>", \
      Aliyun::Oss::XmlBuilder.to_xml({ 'a' => {'e' =>2, 'd' => 1 }, 'c' => 3})
  end

end
