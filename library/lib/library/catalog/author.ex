defmodule Library.Catalog.Author do
  use Ash.Resource,
    otp_app: :library,
    domain: Library.Catalog,
    data_layer: AshPostgres.DataLayer

  resource do
    description "Resource handling author."
    plural_name :authors
  end

  attributes do
    uuid_primary_key :id

    attribute :first_name, :string, allow_nil?: false, public?: true
    attribute :last_name, :string, allow_nil?: false, public?: true

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    many_to_many :books, Library.Catalog.Book do
      through Library.Catalog.BookAuthor
      source_attribute_on_join_resource :author_id
      destination_attribute_on_join_resource :book_id
    end
  end

  aggregates do
    count :published_books_count, :books do
      filter expr(state == :published)
    end

    list :published_books, :books, :simple_book do
      filter expr(state == :published)
    end
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:first_name, :last_name]
  end

  postgres do
    table "authors"
    repo Library.Repo
  end
end
