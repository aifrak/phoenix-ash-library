defmodule Library.Catalog.Author do
  use Ash.Resource,
    otp_app: :library,
    domain: Library.Catalog,
    data_layer: AshPostgres.DataLayer

  alias Library.Catalog.Author.Preparations

  resource do
    description "Resource handling author."
    plural_name :authors
  end

  attributes do
    uuid_primary_key :id

    attribute :first_name, :string, allow_nil?: false, public?: true
    attribute :last_name, :string, allow_nil?: false, public?: true

    timestamps()
  end

  relationships do
    many_to_many :books, Library.Catalog.Book do
      through Library.Catalog.BookAuthor
      source_attribute_on_join_resource :author_id
      destination_attribute_on_join_resource :book_id
    end
  end

  validations do
    validate string_length(:first_name, max: 100)
    validate string_length(:last_name, max: 100)
  end

  aggregates do
    count :published_books_count, :books do
      filter expr(state == :published)
    end
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:first_name, :last_name]

    read :list_with_top_5_books do
      prepare {Preparations.Top5Books, []}
    end
  end

  postgres do
    table "catalog_authors"
    repo Library.Repo
  end
end
