defmodule Library.Repo.Migrations.AddSlugToBook do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:catalog_books) do
      add :slug, :text
    end
  end

  def down do
    alter table(:catalog_books) do
      remove :slug
    end
  end
end