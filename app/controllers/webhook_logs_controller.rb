class WebhookLogsController < ApplicationController
  # http_basic_authenticate_with name: ENV["ADMIN_USER"], password: ENV["ADMIN_PASS"]

  def index
    @logs = WebhookLog.order(created_at: :desc).limit(100)
  end
end

