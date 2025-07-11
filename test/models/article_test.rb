require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  test "should save article without errors" do
    article = Article.new(title: "test title", body: "test body")
    assert article.save
  end
end
