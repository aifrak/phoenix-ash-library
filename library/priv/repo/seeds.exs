# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Library.Repo.insert!(%Library.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Library.Catalog.Book
alias Library.Catalog.Author
alias Library.CatalogFactory
alias Library.Repo

Repo.delete_all(Author)
Repo.delete_all(Book)

CatalogFactory.insert!(Author, count: 2)
CatalogFactory.insert!(Book, count: 2)
CatalogFactory.insert!(Book, count: 2, build: :authors)
CatalogFactory.insert!(Book, variant: :published, count: 2, build: :authors)
