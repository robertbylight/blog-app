require 'rails_helper'

RSpec.describe ArticlesController, type: :request do
  shared_examples 'successful response' do
    it 'returns a successful response' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /articles' do
      let(:article_one) { Article.create(title: 'First', body: 'body 1', status: 'published') }
      let(:article_two) { Article.create(title: 'Second', body: 'body 2', status: 'draft') }

    before do
      article_one
      article_two

      get articles_path
    end
    context 'when a valid request is made' do
      include_examples 'successful response'

      it 'returns articles and meta keys in response' do
        json_response = JSON.parse(response.body)
        expect(json_response["articles"][0]["body"]).to eq("body 1")
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
            Article.create(title: 'CCC', body: 'c body', status: 'published')
            Article.create(title: 'AAA', body: 'a body', status: 'published')
            Article.create(title: 'BBB', body: 'b body', status: 'draft')
          end

          it 'sorts articles by title' do
            get articles_path, params: { sort_by: 'title', sort_order: 'asc' }
            json_response = JSON.parse(response.body)
            titles = json_response['articles'].map { |article| article['title'] }

            expect(titles).to eq([ 'AAA', 'BBB', 'CCC' ])
          end

          it 'sorts articles by title' do
            get articles_path, params: { sort_by: 'title', sort_order: 'desc' }
            json_response = JSON.parse(response.body)
            titles = json_response['articles'].map { |article| article['title'] }

            expect(titles).to eq([ 'CCC', 'BBB', 'AAA' ])
          end
        end

        context 'sort by created_at' do
          before do
            Article.destroy_all
            Article.create(title: 'first', body: 'classic', status: 'archived', created_at: 2.days.ago)
            Article.create(title: 'second', body: 'middle aged', status: 'draft', created_at: 1.day.ago)
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

    context 'when request fails' do
      it 'handles invalid sort parameters' do
        get articles_path, params: { sort_by: 'darth_hideous' }

        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['error']).to eq(
          "Invalid sort param 'darth_hideous': allowed fields are 'title', 'created_at'")
      end

      it 'handles invalid filter parameters' do
        get articles_path, params: { filter_by: 'bad_field' }

        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['error']).to include(
          "Invalid filter field 'bad_field': must use either 'status' or 'created_at'.")
      end
    end
  end

  describe 'POST /articles' do
    shared_examples 'returns validation error' do |params, error_message|
      it "returns error: #{error_message}" do
        post articles_path, params: { article: params }
        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)['error']).to contain_exactly(error_message)
      end
    end

    shared_examples 'successful article creation' do |params|
      it 'creates new article' do
        post articles_path, params: { article: params }
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['title']).to eq(params[:title])
      end
    end

    context 'when article is valid' do
      include_examples 'successful article creation', {
        title: 'title yes',
        body: 'yes body',
        status: 'published'
      }

      it 'creates article with minimum required fields' do
        post articles_path, params: {
          article: { title: 'yesirrr', status: 'draft' }
        }
        expect(response).to have_http_status(:created)
      end
    end

    context 'when article is not valid' do
      context 'title validations' do
        it 'fails with error messsage when title is missing' do
          post articles_path, params: {
            article: { body: 'oh nooooo', status: 'published' }
          }
          expect(JSON.parse(response.body)['error']).to contain_exactly('Title must be present',
            'Title must be at least 3 characters')
        end

        include_examples 'returns validation error',
          { title: 'bb', status: 'published' },
          'Title must be at least 3 characters'
      end

      context 'length validations' do
        include_examples 'returns validation error',
          { title: 'aflac' * 50, status: 'published' },
          'Title cannot be longer than 100 characters'

        include_examples 'returns validation error',
          { title: 'the best sushi', body: 'a' * 1001, status: 'published' },
          'Body cannot be longer than 1000 characters'
      end
    end
  end
end
