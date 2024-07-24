defmodule Library.Repo.Migrations.DropTablesWithoutCatalogPrefix do
  @moduledoc """
  WARNING: Drops all old and unused tables. No data migration because of laziness :)
  """

  use Ecto.Migration

  def up do
    alter table(:authors) do
      remove :updated_at
      remove :inserted_at
      remove :last_name
      remove :first_name
    end

    drop_if_exists unique_index(:book_authors, [:book_id, :author_id],
                     name: "book_authors_unique_index"
                   )

    drop constraint(:book_authors, "book_authors_author_id_fkey")

    alter table(:book_authors) do
      modify :author_id, :uuid
    end

    drop table(:authors)

    alter table(:books) do
      remove :updated_at
      remove :inserted_at
      remove :published_at
      remove :summary
      remove :subject
      remove :title
      remove :isbn
      remove :state
    end

    drop constraint(:book_authors, "book_authors_book_id_fkey")

    alter table(:book_authors) do
      modify :book_id, :uuid
    end

    drop table(:books)

    drop table(:book_authors)
  end

  def down do
    create table(:book_authors, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true

      add :inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :book_id, :uuid, null: false, primary_key: true
      add :author_id, :uuid, null: false, primary_key: true
    end

    create table(:books, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:book_authors) do
      modify :book_id,
             references(:books,
               column: :id,
               name: "book_authors_book_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             )
    end

    alter table(:books) do
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

    create table(:authors, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:book_authors) do
      modify :author_id,
             references(:authors,
               column: :id,
               name: "book_authors_author_id_fkey",
               type: :uuid,
               prefix: "public",
               on_delete: :delete_all
             )
    end

    create unique_index(:book_authors, [:book_id, :author_id], name: "book_authors_unique_index")

    alter table(:authors) do
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
end
