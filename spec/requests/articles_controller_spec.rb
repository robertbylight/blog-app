require 'rails_helper'

RSpec.describe ArticlesController, type: :request do
  describe 'GET /articles' do
      let(:article_one) { Article.create(title: 'First', body: 'body 1', status: 'published') }
      let(:article_two) { Article.create(title: 'Second', body: 'body 2', status: 'draft') }

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

    it 'returns articles with correct content' do
      json_response = JSON.parse(response.body)

      articles = [
        {
          'id' => article_one.id,
          'title' => 'First',
          'body' => 'body 1',
          'status' => 'published',
          'created_at' => article_one.created_at.as_json,
          'updated_at' => article_one.updated_at.as_json
        },
        {
          'id' => article_two.id,
          'title' => 'Second',
          'body' => 'body 2',
          'status' => 'draft',
          'created_at' => article_two.created_at.as_json,
          'updated_at' => article_two.updated_at.as_json
        }
      ]

      expect(json_response['articles']).to eq(articles)
    end

    context 'pagination' do
      before do
        Article.destroy_all

        10.times do |i|
          Article.create(
            title: 'Article #{i}',
            body: 'Body #{i}',
            status: 'published'
          )
        end
        get articles_path, params: { page: 3, per_page: 4 }
      end

      it 'returns the correct page' do
        json_response = JSON.parse(response.body)
        expect(json_response['articles'].length).to eq(2)
      end

      it 'returns correct pagination metadata' do
        json_response = JSON.parse(response.body)
        expect(json_response['meta']).to eq(
          'current_page' => 3,
          'total_pages' => 3,
          'total_articles' => 10
        )
      end
    end

    context 'sorting' do
      context 'sorting by title' do
        before do
          Article.destroy_all
          Article.create(title: 'C', body: 'c body', status: 'published')
          Article.create(title: 'A', body: 'a body', status: 'published')
          Article.create(title: 'B', body: 'b body', status: 'draft')
        end

        it 'sorts articles by title' do
          get articles_path, params: { sort_by: 'title', sort_order: 'asc' }
          json_response = JSON.parse(response.body)
          titles = json_response['articles'].map { |article| article['title'] }

          puts titles

          expect(titles).to eq([ 'A', 'B', 'C' ])
        end

        it 'sorts articles by title' do
          get articles_path, params: { sort_by: 'title', sort_order: 'desc' }
          json_response = JSON.parse(response.body)
          titles = json_response['articles'].map { |article| article['title'] }

          expect(titles).to eq([ 'C', 'B', 'A' ])
        end
      end

      context 'sort by created_at' do
        before do
          Article.destroy_all
          Article.create(title: 'first', body: 'classic', status: 'archived', created_at: 2.days.ago)
          Article.create(title: 'second', body: 'middle aged', status: 'not relevant anymore', created_at: 1.day.ago)
          Article.create(title: 'third', body: 'new born', status: 'published')
        end

        it 'sorts by created_at desc' do
          get articles_path, params: { sort_by: 'created_at', sort_order: 'desc' }
          json_response = JSON.parse(response.body)
          titles = json_response['articles'].map { |article| article['title'] }
          expect(titles).to eq([ 'third', 'second', 'first' ])
        end

        it 'sorts by created_at asc' do
          get articles_path, params: { sort_by: 'created_at', sort_order: 'asc' }
          json_response = JSON.parse(response.body)
          titles = json_response['articles'].map { |article| article['title'] }
          expect(titles).to eq([ 'first', 'second', 'third' ])
        end
      end
    end

    context 'filtering' do
      before do
        Article.destroy_all
        Article.create(title: 'Bilbo', body: 'Why shouldnt I keep it?', status: 'published')
        Article.create(title: 'Gandolf', body: 'keep it safe', status: 'published')
        Article.create(title: 'Frodo', body: 'Gandolf!!', status: 'draft')
        Article.create(title: 'Aragorn', body: 'You have my sword', status: 'published')
      end

      it 'filters articles by status' do
        get articles_path, params: { filter_by: 'status', status: 'published' }

        json_response = JSON.parse(response.body)
        expect(json_response['articles'].length).to eq(3)
        expect(json_response['articles'].map { |article| article['status'] }).to all(eq('published'))
      end
    end
  end
end
