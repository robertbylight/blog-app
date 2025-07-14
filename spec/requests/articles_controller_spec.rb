require 'rails_helper'

RSpec.describe ArticlesController, type: :request do
  describe 'GET /articles' do
      let(:article_one) { Article.create(title: "First", body: "body 1", status: "published") }
      let(:article_two) { Article.create(title: "Second", body: "body 2", status: "draft") }

    before do
      article_one
      article_two

      get articles_path
    end

    it 'returns a successful response' do
      expect(response).to have_http_status(:success)
    end

    it 'returns json' do
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end

    it 'returns articles and meta keys in response' do
      json_response = JSON.parse(response.body)

      expect(json_response).to include('articles', 'meta')
    end

    it 'returns all articles' do
      json_response = JSON.parse(response.body)
      expect(json_response['articles'].length).to eq(2)
    end

    it 'returns articles with correct content and status' do
      json_response = JSON.parse(response.body)

      articles = [
        {
          'id' => article_one.id,
          'title' => "First",
          'body' => "body 1",
          'status' => "published",
          'created_at' => article_one.created_at.as_json,
          'updated_at' => article_one.updated_at.as_json
        },
        {
          'id' => article_two.id,
          'title' => "Second",
          'body' => "body 2",
          'status' => "draft",
          'created_at' => article_two.created_at.as_json,
          'updated_at' => article_two.updated_at.as_json
        }
      ]

      expect(json_response['articles']).to eq(articles)
    end
  end
end
