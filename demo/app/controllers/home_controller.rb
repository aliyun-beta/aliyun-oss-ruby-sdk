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
end
