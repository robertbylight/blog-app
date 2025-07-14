require 'rails_helper'

RSpec.describe ArticlesController, type: :request do
  describe 'GET /articles' do
    it 'returns a successful response' do
      get articles_path
      expect(response).to have_http_status(:success)
    end
  end
end
