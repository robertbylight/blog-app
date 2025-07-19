require 'rails_helper'

RSpec.describe Article, type: :model do
  describe 'validations' do
    let(:article) { Article.create(title: 'First', body: 'body 1', status: 'published') }
    shared_examples 'article validation error' do |field, message|
      it "validates #{field}" do
        article.valid?
        expect(article.errors[field]).to include(message)
      end
    end

    shared_examples 'valid article' do
      it 'valid article' do
        expect(article.valid?).to be true
      end
    end
    context 'when validating title' do
      context 'and title is invalid' do
        it "validates presence of title" do
          article = Article.new(status: 'draft')

          article.valid?
          expect(article.errors[:title]).to include("must be present")
        end
        it 'has less than 3 characters' do
          article = Article.new(title: 'bo', status: 'draft')
          article.valid?
          expect(article.errors[:title]).to include("must be at least 3 characters")
        end
        it 'has more than 100 characters' do
          article = Article.new(title: 'robert' * 50, status: 'draft')
          article.valid?
          expect(article.errors[:title]).to include("cannot be longer than 100 characters")
        end
      end
      context 'when validating title and title is valid' do
        it_behaves_like 'valid article'
      end
    end

    context 'body validations' do
      context 'no body text is provided' do
        let(:article) { Article.new(title: 'nosir', status: 'draft', body: '') }
        include_examples 'valid article'
      end

      context 'body has over 1000 characters' do
        let(:article) { Article.new(title: 'nosir', status: 'draft', body: 'a' * 1001) }
        include_examples 'article validation error', :body, "cannot be longer than 1000 characters"
      end
    end

    context 'status validations' do
      context 'with invalid status' do
        let(:article) { Article.new(title: 'yesir', status: 'wohoo') }
        include_examples 'article validation error', :status, "wohoo is not a valid status, status must be one of: 'draft', 'published', 'archived'"
      end

      context 'with valid statuses' do
        it 'accepts a valid status like draft' do
          article = Article.new(title: 'yesir', status: 'draft')
          expect(article.valid?).to be true
        end
      end
    end
  end
end
