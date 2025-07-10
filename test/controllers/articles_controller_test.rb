require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "index route should be successful" do
    get articles_path
    assert_response :success
  end
end
