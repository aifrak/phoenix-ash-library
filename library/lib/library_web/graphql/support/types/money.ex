defmodule LibraryWeb.Graphql.Support.Types.Money do
  use Absinthe.Schema.Notation

  object :money do
    field :amount, non_null(:decimal)
    field :currency, non_null(:string)
  end

  input_object :money_input do
    field :amount, non_null(:decimal)
    field :currency, non_null(:string)
  end
end
