class AliyunService < SimpleDelegator
  def initialize
    @client = Aliyun::Oss::Client.new(
      Rails.application.secrets.aliyun_oss['access_key'],
      Rails.application.secrets.aliyun_oss['secret_key'],
      host: Rails.application.secrets.aliyun_oss['host'],
      bucket: Rails.application.secrets.aliyun_oss['bucket']
    )
    super(@client)
  end

end
