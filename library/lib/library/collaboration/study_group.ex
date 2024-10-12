defmodule Library.Collaboration.StudyGroup do
  use Ash.Resource,
    otp_app: :library,
    domain: Library.Collaboration,
    data_layer: AshCsv.DataLayer,
    extensions: [AshJsonApi.Resource, AshGraphql.Resource]

  resource do
    description "Resource handling study groups."
    plural_name :study_groups
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :subject, :string, allow_nil?: false, public?: true
    attribute :meet_at, :datetime, allow_nil?: false, public?: true
    attribute :max_participants, :integer, allow_nil?: false, public?: true
    attribute :current_participants, :integer, allow_nil?: false, public?: true

    timestamps()
  end

  identities do
    identity :unique, [:subject, :meet_at],
      # ash_csv does not support transactions/unique constraints, or manual resources with
      # identities.
      # See https://hexdocs.pm/ash/identities.html#eager-checking
      # See https://hexdocs.pm/ash/identities.html#pre-checking
      eager_check?: true,
      message: "Study group with same subject at same time"
  end

  validations do
    validate compare(:max_participants, greater_than: 0)

    validate compare(:current_participants,
               greater_than_or_equal_to: 0,
               less_than_or_equal_to: :max_participants
             )
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:*]
  end

  csv do
    create? true
    header? true
    # usv instead of csv. See: https://github.com/sixarm/usv
    separator ?␟

    columns [
      :id,
      :subject,
      :meet_at,
      :max_participants,
      :current_participants,
      :inserted_at,
      :updated_at
    ]

    file "#{Library.csv_dir()}/collaboration_study_groups.usv"
  end

  json_api do
    type "collaboration_study_group"
  end

  graphql do
    type :collaboration_study_group
  end
end
