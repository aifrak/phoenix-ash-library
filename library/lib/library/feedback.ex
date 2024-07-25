defmodule Library.Feedback do
  use Ash.Domain

  resources do
    resource Library.Feedback.Review do
      define :create_review, action: :create
      define :update_review, action: :update
      define :get_review_by_id, get_by: [:id], action: :read
      define :list_reviews, action: :read
      define :destroy_review, action: :destroy
    end

    resource Library.Feedback.Author do
      define :create_author, action: :create
      define :update_author, action: :update
      define :get_author_by_id, get_by: [:id], action: :read
      define :list_authors, action: :read
      define :destroy_author, action: :destroy
    end
  end
end
