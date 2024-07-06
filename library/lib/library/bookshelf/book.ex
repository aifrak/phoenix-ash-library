defmodule Library.Bookshelf.Book do
  use Ash.Resource,
    domain: Library.Bookshelf,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "books"
    repo Library.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:isbn, :title, :subject, :summary]
    end

    update :update do
      accept [:title, :subject, :summary]
    end

    read :by_title do
      argument :title, :string, allow_nil?: false

      filter expr(contains(string_downcase(title), string_downcase(^arg(:title))))

      pagination offset?: true, default_limit: 10, countable: :by_default
    end

    read :search do
      description """
      ## Examples:

      Add limit (see: https://hexdocs.pm/ash/Ash.Query.html#page/2):
        iex> Library.Bookshelf.search_books("example", page: [limit: 1])

      Sort by title (see: https://hexdocs.pm/ash/Ash.Query.html#sort/3):
        iex> Library.Bookshelf.search_books("example", query: [sort: [title: :desc]])
        iex> Library.Bookshelf.search_books("example", query: [sort: [title: :desc]])
      """

      argument :query, :string, allow_nil?: true

      # Same:
      # prepare build(sort: [:title, :asc])
      prepare build(sort: [title: :asc, id: :asc])

      pagination offset?: true, default_limit: 10, countable: :by_default

      filter expr(
               if is_nil(^arg(:query)) do
                 true
               else
                 contains(string_downcase(title), string_downcase(^arg(:query))) or
                   contains(string_downcase(summary), string_downcase(^arg(:query))) or
                   contains(string_downcase(subject), string_downcase(^arg(:query)))
               end
             )
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :isbn, :string, allow_nil?: false, public?: true
    attribute :title, :string, allow_nil?: false, public?: true
    attribute :subject, :string, public?: true
    attribute :summary, :string, public?: true

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end
end
