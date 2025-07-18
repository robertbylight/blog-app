require 'rails_helper'

RSpec.describe Article, type: :model do
  shared_examples 'article validation error' do |field, message|
    it "validates #{field}" do
      expect(article.valid?).to be false
      expect(article.errors[field]).to include(message)
    end
  end

  shared_examples 'valid article' do
    it 'valid article' do
      expect(article.valid?).to be true
    end
  end

  describe 'validations' do
    context 'title validations' do
      context 'no title' do
        let(:article) { Article.new(status: 'draft') }
        include_examples 'article validation error', :title, "must be present"
      end

      context 'article has less than 3 characters' do
        let(:article) { Article.new(title: 'bo', status: 'draft') }
        include_examples 'article validation error', :title, "must be at least 3 characters"
      end

      context 'article has more than 100 characters' do
        let(:article) { Article.new(title: 'robert' * 50, status: 'draft') }
        include_examples 'article validation error', :title, "cannot be longer than 100 characters"
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
