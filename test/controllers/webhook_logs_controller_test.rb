require "test_helper"

class WebhookLogsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get webhook_logs_index_url
    assert_response :success
  end
end
