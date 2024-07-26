defmodule Library.Feedback.Comment do
  use Ash.Resource,
    otp_app: :library,
    domain: Library.Feedback,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :text, :string, allow_nil?: false, public?: true
  end

  relationships do
    belongs_to :review, Library.Feedback.Review, allow_nil?: false, primary_key?: true
    belongs_to :author, Library.Feedback.Author, allow_nil?: false, primary_key?: true
  end

  validations do
    validate string_length(:text, max: 1000)
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:text]

    read :list_by_review_id do
      argument :review_id, :uuid_v7, allow_nil?: false

      filter expr(review_id == ^arg(:review_id))
    end

    read :list_by_author_id do
      argument :author_id, :uuid_v7, allow_nil?: false

      filter expr(author_id == ^arg(:author_id))
    end
  end

  postgres do
    table "feedback_comments"
    repo Library.Repo

    references do
      reference :review, on_delete: :delete
      reference :author, on_delete: :delete
    end
  end
end
