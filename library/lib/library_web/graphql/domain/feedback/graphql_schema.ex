defmodule LibraryWeb.Graphql.Domain.Feedback.GraphqlSchema do
  use Absinthe.Schema
  use AshGraphql, domains: [Library.Feedback]

  import_types Absinthe.Plug.Types

  query do
    # Custom Absinthe queries can be placed here
  end

  mutation do
    # Custom Absinthe mutations can be placed here
  end
end
