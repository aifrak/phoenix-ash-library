defmodule Library.Feedback.Review do
  use Ash.Resource,
    otp_app: :library,
    primary_read_warning?: false,
    domain: Library.Feedback,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub],
    authorizers: [Ash.Policy.Authorizer],
    extensions: [
      AshAdmin.Resource,
      AshJsonApi.Resource,
      AshGraphql.Resource,
      AshArchival.Resource,
      AshOban
    ]

  alias Library.Catalog
  alias Library.Feedback.Author
  alias Library.Feedback.Comment
  alias Library.Feedback.Review.Events
  alias Library.Helpers.StringHelper
  alias Library.Helpers.DateHelper

  @hourly "0 * * * *"

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

  identities do
    identity :id, :id
    identity :unique, [:book_id, :author_id], message: "Author has already reviewed this book"
  end

  relationships do
    belongs_to :book, Catalog.Book, allow_nil?: false, primary_key?: true, public?: true

    belongs_to :author, Author,
      allow_nil?: false,
      primary_key?: true,
      public?: true

    has_many :comments, Comment, public?: true
  end

  validations do
    validate compare(:rating, greater_than_or_equal_to: 1, less_than_or_equal_to: 5),
      message: "must be between 1 and 5"

    validate string_length(:comment, max: 1000)
  end

  policies do
    policy_group action_type([:read, :update, :destroy]) do
      policy authorize_if: always()
    end

    policy action_type(:create), authorize_if: actor_present()
    policy action(:subscribe_created), authorize_if: always()
    # Use below if we want to check that the current author is ones of the associated book authors
    # policy action_type(:update), authorize_if: relates_to_actor_via(:authors)
    # policy action_type(:destroy), authorize_if: relates_to_actor_via(:authors)
  end

  actions do
    defaults [:update, :destroy]
    default_accept [:rating, :comment]

    read :read_all do
      # Default Ash behaviour for pagination
      pagination required?: false, offset?: true, keyset?: true
    end

    read :read do
      primary? true
      filter expr(is_nil(archived_at))
      # Default Ash behaviour for pagination
      pagination required?: false, offset?: true, keyset?: true
    end

    read :archived do
      filter expr(not is_nil(archived_at))
    end

    create :create do
      argument :book, :uuid_v7
      argument :author, :uuid_v7

      change manage_relationship(:book, type: :append)
      change manage_relationship(:author, type: :append)

      notifiers [Library.Feedback.Review.FakeEmailNotifiers]
    end

    update :unarchive do
      change set_attribute(:archived_at, nil)
      change cascade_update(:comments, action: :unarchive)
      atomic_upgrade_with :archived
    end

    update :anonymize do
      change set_attribute(:comment, "[DELETED]")
    end

    action :subscribe_created do
      argument :book_id, :uuid_v7

      run fn input, _ ->
        Events.Created.subscribe(input.arguments.book_id)
        :ok
      end
    end
  end

  pub_sub do
    module LibraryWeb.Endpoint
    prefix "feedback_review"

    # topic: feedback_review:created:#{book_id}
    publish_all :create, ["created", :book_id]
  end

  postgres do
    table "feedback_reviews"
    repo Library.Repo

    references do
      reference :book, on_delete: :delete
      reference :author, on_delete: :delete
    end

    base_filter_sql "(archived_at IS NULL)"
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

  admin do
    resource_group :domain

    form do
      field :comment, type: :long_text
    end

    format_fields comment: {StringHelper, :truncate, [50]},
                  inserted_at: {DateHelper, :format_datetime, []},
                  updated_at: {DateHelper, :format_datetime, []}
  end

  # Archive a review with destroy
  # id = "0198d635-7cab-77ed-b5c9-7ee8d5015e09"
  # review = Library.Feedback.Review |> Ash.get!(%{id: id}) |> Library.Feedback.destroy_review()

  # Unarchive
  # import Ash.Query
  # review =  Library.Feedback.Review |> Ash.Query.for_read(:archived) |> Ash.Query.filter(id == ^id) |> Library.Feedback.unarchive_review()
  archive do
    attribute :archived_at
    attribute_type :utc_datetime_usec

    archive_related [:comments]
    exclude_read_actions [:read_all, :archived]

    # Recommended: bypass authorization for related records
    archive_related_authorize? false
  end

  oban do
    triggers do
      trigger :anonymize do
        action :anonymize
        queue :review_anonymizer
        where expr(not is_nil(archived_at))
        read_action :read_all
        scheduler_cron @hourly
        worker_module_name __MODULE__.Process.Worker
        scheduler_module_name __MODULE__.Process.Scheduler
      end
    end
  end
end
