defmodule Library.Feedback.Review do
  use Ash.Resource,
    otp_app: :library,
    domain: Library.Feedback,
    data_layer: AshPostgres.DataLayer

  alias Library.Feedback.Review.Notifiers

  attributes do
    uuid_v7_primary_key :id

    attribute :rating, :integer, allow_nil?: false, public?: true
    attribute :comment, :string, allow_nil?: false, public?: true

    timestamps()
  end

  relationships do
    belongs_to :book, Library.Catalog.Book, allow_nil?: false, primary_key?: true
    belongs_to :author, Library.Feedback.Author, allow_nil?: false, primary_key?: true
    has_many :comments, Library.Feedback.Comment
  end

  identities do
    identity :id, :id
    identity :unique, [:book_id, :author_id], message: "Author has already reviewed this book"
  end

  validations do
    validate compare(:rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5),
      message: "must be between 1 and 5"

    validate string_length(:comment, max: 1000)
  end

  actions do
    defaults [:read, :update, :destroy]
    default_accept [:rating, :comment]

    create :create do
      argument :book, :uuid_v7
      argument :author, :uuid_v7

      change manage_relationship(:book, type: :append)
      change manage_relationship(:author, type: :append)
    end
  end

  postgres do
    table "feedback_reviews"
    repo Library.Repo

    references do
      reference :book, on_delete: :delete
      reference :author, on_delete: :delete
    end
  end
end
