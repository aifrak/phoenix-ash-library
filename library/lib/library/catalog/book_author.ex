defmodule Library.Catalog.BookAuthor do
  @moduledoc """
  The join resource between Book and Author.
  """

  use Ash.Resource,
    otp_app: :library,
    data_layer: AshPostgres.DataLayer,
    domain: Library.Catalog,
    extensions: [AshAdmin.Resource, AshPaperTrail.Resource]

  alias Library.Catalog.Author
  alias Library.Catalog.Book
  alias Library.Helpers.DateHelper

  resource do
    description "The join resource between Book and Author."
    plural_name :book_authors
  end

  attributes do
    uuid_v7_primary_key :id

    create_timestamp :inserted_at
  end

  identities do
    identity :id, :id

    identity :unique, [:book_id, :author_id], message: "Author already associated to the book"
  end

  relationships do
    belongs_to :book, Book, allow_nil?: false
    belongs_to :author, Author, allow_nil?: false
  end

  actions do
    defaults [:create, :read, :update, :destroy]
    default_accept [:book_id, :author_id]
  end

  postgres do
    table "catalog_books_authors"
    repo Library.Repo

    references do
      reference :book, on_delete: :delete
      reference :author, on_delete: :delete
    end
  end

  admin do
    resource_group :domain

    format_fields inserted_at: {DateHelper, :format_datetime, []}
  end

  paper_trail do
    primary_key_type :uuid_v7
    change_tracking_mode :changes_only
    store_action_name? true
    reference_source? false
    ignore_attributes [:inserted_at, :updated_at]

    # Enhance ash_paper_trail's generated resource
    mixin {Library.Mixins.AshPaperTrailMixin, :mixin, ["BookAuthorVersion", :audit_log]}
    version_extensions extensions: [AshAdmin.Resource]
  end
end
