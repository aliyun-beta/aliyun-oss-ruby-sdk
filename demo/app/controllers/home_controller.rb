class HomeController < ApplicationController
  def index
    service = AliyunService.new
    @name = service.current_bucket.name
    @location = service.current_bucket.location!
    @objects = service.bucket_objects.list.select(&:file?)
  end

  def download
    service = AliyunService.new
    buffer = service.bucket_objects.get(params[:key])
    send_data buffer, filename: params[:key]
  end

  def new_put
  end

  def create_put
    service = AliyunService.new
    if params[:name].blank? || params[:file].blank?
      return render action: :new_put
    end

    service.bucket_objects.create(params[:name], params[:file].read)
    redirect_to root_path, notice: 'Upload Success'
  rescue Aliyun::Oss::RequestError => e
    Rails.logger.error(e.inspect)
    redirect_to root_path, alert: e.message
  end

  def new_post
    @access_key = Rails.application.secrets.aliyun_oss['access_key']
    secret_key = Rails.application.secrets.aliyun_oss['secret_key']
    bucket = Rails.application.secrets.aliyun_oss['bucket']
    host = Rails.application.secrets.aliyun_oss['host']
    @key = '${filename}'
    @acl = 'private'
    @return_url = 'http://localhost:3001/post_return'
    @username = 'newuser'
    policy_hash = {
      expiration: 15.minutes.since.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
      conditions: [
        { bucket: bucket }
      ]
    }

    @policy = Aliyun::Oss::Authorization.get_base64_policy(policy_hash)
    @signature = Aliyun::Oss::Authorization.get_policy_signature(secret_key, policy_hash)
    @bucket_endpoint = Aliyun::Oss::Utils.get_endpoint(bucket, host)
  end

  def post_return
    redirect_to root_path, notice: 'Post Success'
  end
end
