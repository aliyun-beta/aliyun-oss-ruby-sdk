class AliyunService < SimpleDelegator
  def initialize
    aliyun_oss = Rails.application.secrets.aliyun_oss
    @client = Aliyun::Oss::Client.new(
      aliyun_oss['access_key'],
      aliyun_oss['secret_key'],
      host: aliyun_oss['host'],
      bucket: aliyun_oss['bucket']
    )
    super(@client)
  end
end
