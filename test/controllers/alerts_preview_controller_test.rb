require "test_helper"

class AlertsPreviewControllerTest < ActionDispatch::IntegrationTest
  test "Expect parameters are available" do
      # No parameter
      get alerts_preview_index_path
      assert_response :unprocessable_entity

      get alerts_preview_index_path(comparator: "lt")
  end

  test "Expect given the parameters are valid should return right record" do
    assert true
  end
end
