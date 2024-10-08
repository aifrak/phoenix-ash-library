defmodule Library.Repo.Migrations.RenameTablesWithCatalogPrefix do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:catalog_books_authors, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :book_id, :uuid, null: false, primary_key: true
      add :author_id, :uuid, null: false, primary_key: true
    end

    create table(:catalog_books, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:catalog_books_authors) do
      modify :book_id,
             references(:catalog_books,
               column: :id,
               name: "catalog_books_authors_book_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             )
    end

    alter table(:catalog_books) do
      add :state, :book_state, null: false, default: "draft"
      add :isbn, :text, null: false
      add :title, :text, null: false
      add :subject, :text
      add :summary, :text
      add :published_at, :date

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create table(:catalog_authors, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:catalog_books_authors) do
      modify :author_id,
             references(:catalog_authors,
               column: :id,
               name: "catalog_books_authors_author_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             )
    end

    create unique_index(:catalog_books_authors, [:book_id, :author_id],
             name: "catalog_books_authors_unique_index"
           )

    alter table(:catalog_authors) do
      add :first_name, :text, null: false
      add :last_name, :text, null: false

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end
  end

  def down do
    alter table(:catalog_authors) do
      remove :updated_at
      remove :inserted_at
      remove :last_name
      remove :first_name
    end

    drop_if_exists unique_index(:catalog_books_authors, [:book_id, :author_id],
                     name: "catalog_books_authors_unique_index"
                   )

    drop constraint(:catalog_books_authors, "catalog_books_authors_author_id_fkey")

    alter table(:catalog_books_authors) do
      modify :author_id, :uuid
    end

    drop table(:catalog_authors)

    alter table(:catalog_books) do
      remove :updated_at
      remove :inserted_at
      remove :published_at
      remove :summary
      remove :subject
      remove :title
      remove :isbn
      remove :state
    end

    drop constraint(:catalog_books_authors, "catalog_books_authors_book_id_fkey")

    alter table(:catalog_books_authors) do
      modify :book_id, :uuid
    end

    drop table(:catalog_books)

    drop table(:catalog_books_authors)
  end
end
