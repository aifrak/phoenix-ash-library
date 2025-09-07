defmodule Library.Feedback.Comment do
  use Ash.Resource,
    otp_app: :library,
    primary_read_warning?: false,
    domain: Library.Feedback,
    data_layer: AshPostgres.DataLayer,
    extensions: [
      AshAdmin.Resource,
      AshJsonApi.Resource,
      AshGraphql.Resource,
      AshArchival.Resource,
      AshRateLimiter
    ]

  alias Library.Helpers.StringHelper
  alias Library.Helpers.DateHelper

  resource do
    description "Resource handling comments."
    plural_name :comments
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :text, :string, allow_nil?: false, public?: true

    timestamps()
  end

  identities do
    identity :id, :id
  end

  relationships do
    belongs_to :review, Library.Feedback.Review, allow_nil?: false, primary_key?: true
    belongs_to :author, Library.Feedback.Author, allow_nil?: false, primary_key?: true
  end

  validations do
    validate string_length(:text, max: 1000)
  end

  actions do
    defaults [:update, :destroy]
    default_accept [:text]

    read :read_all

    read :read do
      primary? true
      filter expr(is_nil(archived_at))
    end

    create :create do
      primary? true
      argument :review, :uuid_v7
      argument :author, :uuid_v7

      change manage_relationship(:review, type: :append)
      change manage_relationship(:author, type: :append)
    end

    read :archived do
      filter expr(not is_nil(archived_at))
    end

    read :list_by_review_id do
      argument :review_id, :uuid_v7, allow_nil?: false

      filter expr(review_id == ^arg(:review_id) and is_nil(archived_at))
    end

    read :list_by_author_id do
      argument :author_id, :uuid_v7, allow_nil?: false

      filter expr(author_id == ^arg(:author_id) and is_nil(archived_at))
    end

    update :unarchive do
      change set_attribute(:archived_at, nil)
      atomic_upgrade_with :archived
    end
  end

  postgres do
    table "feedback_comments"
    repo Library.Repo

    references do
      reference :review, on_delete: :delete
      reference :author, on_delete: :delete
    end

    base_filter_sql "(archived_at IS NULL)"
  end

  json_api do
    type "comment"

    primary_key do
      keys [:id]
    end
  end

  graphql do
    type :feedback_comment
  end

  admin do
    resource_group :domain

    form do
      field :text, type: :long_text
    end

    format_fields text: {StringHelper, :truncate, [50]},
                  inserted_at: {DateHelper, :format_datetime, []},
                  updated_at: {DateHelper, :format_datetime, []}
  end

  # Archive a review with destroy
  # id = "0198d635-7cae-7b98-9be0-3f001c4b7ba0"
  # comment = Library.Feedback.Comment |> Ash.get!(%{id: id}) |> Ash.destroy()

  # Unarchive
  # import Ash.Query
  # comment = Library.Feedback.Comment |> Ash.get!(%{id: id}, action: :archived) |> Ash.Changeset.for_update(:unarchive, %{}) |> Ash.update!()
  archive do
    attribute :archived_at
    attribute_type :utc_datetime_usec

    exclude_read_actions [:read_all, :archived]

    # Recommended: bypass authorization for related records
    archive_related_authorize? false
  end

  # Example to test ash_rate_limiter:
  #
  # review = Ash.get!(Library.Feedback.Review, "019923d2-729f-7810-82a7-9a71770a0efc")
  # author = Ash.get!(Library.Feedback.Author, "019923d2-7291-7ab9-ab0b-8e306bc51a1b")
  #
  # Library.Feedback.create_comment(%{text: "Not good", review: review, author: author.id}, actor: author)
  #
  # The below fails, because it is 1 creation per minute per user.
  # Library.Feedback.create_comment(%{text: "OK", review: review, author: author.id}, actor: author)

  rate_limit do
    hammer Library.RateLimit

    action :create,
      limit: 1,
      per: :timer.minutes(1),
      key: fn _changeset, context ->
        "feedback/comment/create;user:#{context.actor.id}"
      end
  end
end
