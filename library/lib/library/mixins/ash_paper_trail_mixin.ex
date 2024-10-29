defmodule Library.Mixins.AshPaperTrailMixin do
  def mixin(name, group) do
    quote do
      actions do
        read :read_by_latest do
          prepare build(sort: [{:version_inserted_at, :desc}])

          pagination keyset?: true, default_limit: 10, countable: :by_default
        end
      end

      admin do
        name unquote(name)
        resource_group unquote(group)

        generic_actions []
        create_actions []
        read_actions [:read_by_latest]
        update_actions []
        destroy_actions []

        format_fields changes: {Library.Helpers.StringHelper, :truncate, [100]},
                      version_inserted_at: {Library.Helpers.DateHelper, :format_datetime, []},
                      version_updated_at: {Library.Helpers.DateHelper, :format_datetime, []}
      end
    end
  end
end
