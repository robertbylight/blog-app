require 'rails_helper'

RSpec.describe Article, type: :model do
  describe 'creating article' do
    it 'should save article without errors' do
      article = Article.new(title: "test title", body: "test body", status: "draft")
      expect(article.save).to be true
    end
  end
end
