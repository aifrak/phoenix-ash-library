defmodule Library.Feedback.Review do
  use Ash.Resource,
    otp_app: :library,
    domain: Library.Feedback,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub],
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshJsonApi.Resource, AshGraphql.Resource]

  alias Library.Catalog
  alias Library.Feedback.Author
  alias Library.Feedback.Comment
  alias Library.Feedback.Review.Events

  @type id :: Library.uuid()
  @type rating :: 1..5
  @type comment :: String.t()
  @type book :: Catalog.Book.t()
  @type book_id :: Catalog.Book.id()
  @type author :: Author.t()
  @type author_id :: Author.id()
  @type comments :: [Comment]
  @type inserted_at :: DateTime.t()
  @type updated_at :: DateTime.t()
  @type t :: %__MODULE__{
          id: id(),
          rating: rating(),
          comment: comment(),
          book: book(),
          book_id: book_id(),
          author: author(),
          author_id: author_id(),
          comments: comments(),
          inserted_at: inserted_at(),
          updated_at: updated_at()
        }

  resource do
    description "Resource handling reviews."
    plural_name :reviews
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :rating, :integer, allow_nil?: false, public?: true
    attribute :comment, :string, allow_nil?: false, public?: true

    timestamps()
  end

  relationships do
    belongs_to :book, Catalog.Book, allow_nil?: false, primary_key?: true, public?: true

    belongs_to :author, Author,
      allow_nil?: false,
      primary_key?: true,
      public?: true

    has_many :comments, Comment, public?: true
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

  policies do
    policy action_type(:read), authorize_if: always()
    policy action_type(:create), authorize_if: actor_present()
    policy action_type(:update), authorize_if: always()
    policy action_type(:destroy), authorize_if: always()
    # Use below if we want to check that the current author is ones of the associated book authors
    # policy action_type(:update), authorize_if: relates_to_actor_via(:authors)
    # policy action_type(:destroy), authorize_if: relates_to_actor_via(:authors)
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

    action :subscribe_created do
      argument :book_id, :uuid_v7

      run fn input, _ ->
        Events.Created.subscribe(input.arguments.book_id)
        :ok
      end
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

  pub_sub do
    module LibraryWeb.Endpoint
    prefix "feedback_review"

    # topic: feedback_review:created:#{book_id}
    publish_all :create, ["created", [:book_id, :id]]
  end

  json_api do
    type "review"

    primary_key do
      keys [:book_id, :author_id]
    end

    includes book: [], author: []
  end

  graphql do
    type :feedback_review
    hide_fields [:book]
  end
end
