defmodule LibraryWeb.GraphqlSchema do
  use Absinthe.Schema
  use AshGraphql, domains: [Library.Catalog, Library.Feedback]

  import_types Absinthe.Plug.Types

  object :money do
    field :amount, non_null(:decimal)
    field :currency, non_null(:string)
  end

  input_object :money_input do
    field :amount, non_null(:decimal)
    field :currency, non_null(:string)
  end

  query do
    # Custom Absinthe queries can be placed here
  end

  mutation do
    # Custom Absinthe mutations can be placed here
  end
end
