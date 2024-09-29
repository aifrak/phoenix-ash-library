defmodule LibraryWeb.Graphql.Domain.Catalog.GraphqlSchema do
  use Absinthe.Schema
  use AshGraphql, domains: [Library.Catalog]

  import_types Absinthe.Plug.Types
  import_types LibraryWeb.Graphql.Support.Types.Money

  query do
    # Custom Absinthe queries can be placed here
  end

  mutation do
    # Custom Absinthe mutations can be placed here
  end
end
