defmodule Library.Repo.Migrations.RemovePrimaryKeyFromBookAuthorsRelationships do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    drop constraint("catalog_books_authors", "catalog_books_authors_pkey")

    alter table(:catalog_books_authors) do
      modify :author_id, :uuid, primary_key: false
      modify :book_id, :uuid, primary_key: false
    end
  end

  def down do
    alter table(:catalog_books_authors) do
      modify :book_id, :uuid, primary_key: true
      modify :author_id, :uuid, primary_key: true
    end
  end
end
