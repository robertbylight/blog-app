class Article < ApplicationRecord
  validates :title,
    presence: { message: "must be present" },
    length: {
      minimum: 3,
      maximum: 100,
      too_short: "must be at least 3 characters",
      too_long: "cannot be longer than 100 characters"
    }
  validates :body,
    length: {
      maximum: 1000,
      too_long: "cannot be longer than %{count} characters"
    },
    allow_blank: true
  validates :status, presence: true,
    inclusion: {
      in: %w[draft published archived],
      message: "%{value} is not a valid status, status must be one of: 'draft', 'published', 'archived'"
    }
end
