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
    redirect_to root_path, notice: "Upload Success"
  rescue Aliyun::Oss::RequestError => e
    Rails.logger.error(e.inspect)
    redirect_to root_path, alert: e.message
  end

  def new_post
    
  end
end
