defmodule Library.Catalog.Author.Preparations.Top5Books do
  use Ash.Resource.Preparation

  @impl true
  def prepare(query, _opts, _context) do
    book_query =
      Library.Catalog.Book
      |> Ash.Query.filter(state == :published)
      |> Ash.Query.limit(5)
      |> Ash.Query.sort(title: :asc, id: :asc)

    Ash.Query.load(query, books: book_query)
  end
end
