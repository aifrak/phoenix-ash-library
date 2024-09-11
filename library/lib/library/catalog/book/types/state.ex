defmodule Library.Catalog.Book.Types.State do
  use Ash.Type.Enum,
    values: [
      draft: "A book in draft",
      alpha: "A book in Alpha for internal proofreading",
      beta: "A book in Beta. Reader can buy the book at a discounted price",
      published: "A book published and available all",
      retired: "A book retired from the library and not available anymore"
    ]

  use AshGraphql.Type

  @impl Ash.Type
  def storage_type(), do: :book_state

  @impl AshGraphql.Type
  def graphql_type(_), do: :book_state

  @impl AshGraphql.Type
  def graphql_input_type(_), do: :book_state
end
