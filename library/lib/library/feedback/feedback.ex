defmodule Library.Feedback do
  use Ash.Domain,
    otp_app: :library,
    extensions: [AshJsonApi.Domain, AshGraphql.Domain, AshAdmin.Domain]

  alias Library.Feedback.Author
  alias Library.Feedback.Comment
  alias Library.Feedback.Review

  resources do
    resource Review do
      define :create_review, action: :create
      define :update_review, action: :update
      define :get_review_by_id, get_by: :id, action: :read
      define :list_reviews, action: :read
      define :destroy_review, action: :destroy
      define :subscribe_created_reviews, args: [:book_id], action: :subscribe_created
      define :unarchive_review, action: :unarchive
    end

    resource Author do
      define :create_author, action: :create
      define :update_author, action: :update
      define :get_author_by_id, get_by: :id, action: :read
      define :list_authors, action: :read
      define :destroy_author, action: :destroy
    end

    resource Comment do
      define :create_comment, action: :create
      define :update_comment, action: :update
      define :list_comments_by_review_id, args: [:review_id], action: :list_by_review_id
      define :list_comments_by_author_id, args: [:author_id], action: :list_by_author_id
      define :destroy_comment, action: :destroy
    end
  end

  json_api do
    prefix "/api/json/feedback"

    routes do
      # in the domain `base_route` acts like a scope
      base_route "/v1/reviews", Review do
        get :read
        index :read
        post :create, relationship_arguments: [{:id, :book}, {:id, :author}]
        patch :update
        delete :destroy
        relationship :author, :read
        relationship :comments, :read
        related :author, :read
        related :comments, :read
      end

      base_route "/v1/authors", Author do
        get :read
        index :read
        post :create
        patch :update
        delete :destroy
      end

      base_route "/v1/comments", Comment do
        get :read
        index :read
        post :create
        patch :update
        delete :destroy
      end
    end
  end

  graphql do
    queries do
      get Review, :feedback_review, :read
      list Review, :feedback_reviews, :read

      get Author, :feedback_author, :read
      list Author, :feedback_authors, :read

      get Comment, :feedback_comment, :read
      list Comment, :feedback_comments, :read
    end

    mutations do
      create Review, :create_feedback_review, :create
      update Review, :update_feedback_review, :update
      destroy Review, :destroy_feedback_review, :destroy

      create Author, :create_feedback_author, :create
      update Author, :update_feedback_author, :update
      destroy Author, :destroy_feedback_author, :destroy

      create Comment, :create_feedback_comment, :create
      update Comment, :update_feedback_comment, :update
      destroy Comment, :destroy_feedback_comment, :destroy
    end
  end

  admin do
    show? true
    resource_group_labels domain: "Domain"
    default_resource_page :primary_read
  end
end
