defmodule Library.Catalog.VersionView do
  use Ash.Resource,
    otp_app: :library,
    domain: Library.Catalog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAdmin.Resource, AshPaperTrail.Resource]

  alias Library.Helpers.DateHelper
  alias Library.Helpers.StringHelper

  resource do
    description "Resource handling the SQL view of versions (ash_paper_trail) for a catalog."
    plural_name :version_views
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :entity_type, :string, allow_nil?: false
    attribute :version_action_type, :atom, allow_nil?: false
    attribute :version_action_name, :atom, allow_nil?: false
    attribute :version_source_id, :uuid_v7, allow_nil?: false
    attribute :changes, :map, allow_nil?: false
    attribute :version_inserted_at, :utc_datetime_usec, allow_nil?: false
    attribute :version_updated_at, :utc_datetime_usec, allow_nil?: false
  end

  actions do
    read :read do
      prepare build(sort: [{:version_inserted_at, :desc}])

      pagination keyset?: true, default_limit: 10, countable: :by_default
    end
  end

  postgres do
    table "catalog_versions_view"
    repo Library.Repo
  end

  admin do
    resource_group :audit_log

    format_fields changes: {StringHelper, :truncate, [100]},
                  version_inserted_at: {DateHelper, :format_datetime, []},
                  version_updated_at: {DateHelper, :format_datetime, []}
  end
end
