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
      filter expr(contains(title, ^arg(:title)))
    end

    read :by_id do
      argument :id, :uuid, allow_nil?: false
      get? true
      filter expr(id == ^arg(:id))
    end

    read :by_isbn do
      argument :isbn, :string, allow_nil?: false
      get? true
      filter expr(isbn == ^arg(:isbn))
    end

    read :search do
      description """
      # Examples:
        iex> Library.Bookshelf.search("o", page: [limit: 1])
      """

      argument :query, :string

      prepare build(sort: [title: :asc, id: :asc])

      pagination offset?: true, default_limit: 10, countable: :by_default

      filter expr(
               contains(string_downcase(title), ^arg(:query)) or
                 contains(string_downcase(summary), ^arg(:query)) or
                 contains(string_downcase(subject), ^arg(:query))
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
