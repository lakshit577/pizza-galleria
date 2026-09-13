require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  test "GET /orders returns success" do
    get orders_path

    assert_response :success
  end
end