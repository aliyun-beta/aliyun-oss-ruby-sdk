require 'test_helper'

describe Aliyun::Oss::Authorization do
  # Example from https://docs.aliyun.com/#/pub/oss/api-reference/access-control&signature-header#menu4
  it 'should get authorization string' do
    authorization_value = Aliyun::Oss::Authorization.get_authorization(
      '44CF9590006BF252F707',
      'OtxrzxIsfpFjA7SwPzILwy8Bw21TLhquhboDYROV',
      verb: 'PUT',
      headers: {
        'Content-MD5' => 'ODBGOERFMDMzQTczRUY3NUE3NzA5QzdFNUYzMDQxNEM=',
        'Content-Type' => 'text/html',
        'x-oss-magic' => 'abracadabra',
        'x-oss-meta-author' => 'foo@bar.com'
      },
      date: 'Thu, 17 Nov 2005 18:49:58 GMT',
      bucket: 'oss-example',
      key: 'nelson'
    )

    assert_equal('OSS 44CF9590006BF252F707:26NBxoKdsyly4EDv6inkoDft/yA=', authorization_value)
  end

  it 'should get authorization string when missing headers' do
    authorization_value = Aliyun::Oss::Authorization.get_authorization(
      '44CF9590006BF252F707',
      'OtxrzxIsfpFjA7SwPzILwy8Bw21TLhquhboDYROV',
      verb: 'PUT',
      headers: {},
      date: 'Thu, 17 Nov 2005 18:49:58 GMT'
    )
    assert_equal('OSS 44CF9590006BF252F707:PPaaX3Rt4ntpD31O9aqkyCf2pd4=', authorization_value)
  end

  it 'should get authorization string when missing x-oss headers' do
    authorization_value = Aliyun::Oss::Authorization.get_authorization(
      '44CF9590006BF252F707',
      'OtxrzxIsfpFjA7SwPzILwy8Bw21TLhquhboDYROV',
      verb: 'PUT',
      date: 'Thu, 17 Nov 2005 18:49:58 GMT',
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
    )
    assert_equal('OSS 44CF9590006BF252F707:HPW2mvmSOvwZ3J7wuyO751PIUkc=', authorization_value)
  end

  # Example from https://docs.aliyun.com/#/pub/oss/api-reference/access-control&signature-url
  it 'should get temporary signature' do
    temporary_signature = Aliyun::Oss::Authorization.get_temporary_signature(
      'OtxrzxIsfpFjA7SwPzILwy8Bw21TLhquhboDYROV',
      1_141_889_120,
      bucket: 'oss-example',
      key: 'oss-api.pdf',
      verb: 'GET'
    )
    assert_equal('EwaNTn1erJGkimiJ9WmXgwnANLc=', temporary_signature)
  end

  # Example from https://docs.aliyun.com/#/pub/oss/api-reference/object&PostObject#menu7
  it 'should get base64 policy' do
    policy = {
      'expiration' => '2013-12-01T12:00:00Z',
      'conditions' => [
        ['content-length-range', 0, 10_485_760],
        { 'bucket' => 'ahaha' },
        { 'A' => 'a' },
        { 'key' => 'ABC' }
      ]
    }
    base64_policy = Aliyun::Oss::Authorization.get_base64_policy(policy)
    assert_equal('eyJleHBpcmF0aW9uIjoiMjAxMy0xMi0wMVQxMjowMDowMFoiLCJjb25kaXRpb25zIjpbWyJjb250ZW50LWxlbmd0aC1yYW5nZSIsMCwxMDQ4NTc2MF0seyJidWNrZXQiOiJhaGFoYSJ9LHsiQSI6ImEifSx7ImtleSI6IkFCQyJ9XX0=', base64_policy)
  end

  it 'should get policy signature' do
    policy = {
      'expiration' => '2013-12-01T12:00:00Z',
      'conditions' => [
        ['content-length-range', 0, 10_485_760],
        { 'bucket' => 'ahaha' },
        { 'A' => 'a' },
        { 'key' => 'ABC' }
      ]
    }
    policy_signature = Aliyun::Oss::Authorization.get_policy_signature('OtxrzxIsfpFjA7SwPzILwy8Bw21TLhquhboDYROV', policy)
    assert_equal('4tWCtD1uLbM6Uxva3tyNxLoUs2k=', policy_signature)
  end
end
