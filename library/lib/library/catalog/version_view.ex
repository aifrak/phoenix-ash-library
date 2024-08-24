defmodule Library.Catalog.VersionView do
  use Ash.Resource,
    otp_app: :library,
    domain: Library.Catalog,
    data_layer: AshPostgres.DataLayer,
    extensions: AshPaperTrail.Resource

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
    defaults [:read]
  end

  postgres do
    table "catalog_versions_view"
    repo Library.Repo
  end
end
