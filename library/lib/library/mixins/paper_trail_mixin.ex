defmodule Library.Mixins.PaperTrailMixin do
  def mixin(name, group) do
    quote do
      alias Library.Helpers.DateHelper

      admin do
        name unquote(name)
        resource_group unquote(group)

        format_fields inserted_at: {DateHelper, :format_datetime, []},
                      updated_at: {DateHelper, :format_datetime, []}
      end
    end
  end
end
