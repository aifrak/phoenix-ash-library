defmodule Library.Feedback.Author do
  use Ash.Resource,
    otp_app: :library,
    domain: Library.Feedback,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key :id

    attribute :first_name, :string, allow_nil?: false, public?: true
    attribute :last_name, :string, allow_nil?: false, public?: true

    timestamps()
  end

  relationships do
    has_many :reviews, Library.Feedback.Review
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:first_name, :last_name]
  end

  postgres do
    table "feedback_authors"
    repo Library.Repo
  end
end
