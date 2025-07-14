require 'rails_helper'

RSpec.describe ArticlesController, type: :request do
  describe 'GET /articles' do
    before do
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
  end
end
