require 'test_helper'

describe Aliyun::Oss::Utils do
  it 'should convert hash to xml' do
    expected_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" \
      '<a><e>2</e><d>1</d></a><c>3</c>'
    original_hash = { 'a' => { 'e' => 2, 'd' => 1 }, 'c' => 3 }
    assert_equal expected_xml, Aliyun::Oss::Utils.to_xml(original_hash)
  end
end
