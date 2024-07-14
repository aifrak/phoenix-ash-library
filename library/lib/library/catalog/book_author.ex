defmodule Library.Catalog.BookAuthor do
  @moduledoc """
  The join resource between Book and Author.
  """

  use Ash.Resource,
    otp_app: :library,
    data_layer: AshPostgres.DataLayer,
    domain: Library.Catalog

  alias Library.Catalog.Author
  alias Library.Catalog.Book

  resource do
    description "The join resource between Book and Author."
    plural_name :book_authors
  end

  attributes do
    uuid_primary_key :id

    create_timestamp :inserted_at
  end

  relationships do
    belongs_to :book, Book, primary_key?: true, allow_nil?: false
    belongs_to :author, Author, primary_key?: true, allow_nil?: false
  end

  identities do
    identity :unique, [:book_id, :author_id], message: "Author already associated to the book"
  end

  actions do
    defaults [:create, :read, :destroy]
  end

  postgres do
    table "book_authors"
    repo Library.Repo

    references do
      reference :book, on_delete: :delete
      reference :author, on_delete: :delete
    end
  end
end
