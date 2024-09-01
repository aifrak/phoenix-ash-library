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

alias Library.Catalog
alias Library.CatalogFactory
alias Library.Collaboration
alias Library.CollaborationFactory
alias Library.Feedback
alias Library.FeedbackFactory
alias Library.Repo

Repo.delete_all(Feedback.Author)
Repo.delete_all(Feedback.Comment)
Repo.delete_all(Feedback.Review)
Repo.delete_all(Catalog.Author)
Repo.delete_all(Catalog.Book)
# Remove everything from the csv
Collaboration.StudyGroup |> AshCsv.DataLayer.Info.file() |> File.write!("")

### Catalog ###

# Books without authors
CatalogFactory.insert!(Catalog.Book, count: 2)

# 1 author per book
CatalogFactory.insert!(Catalog.Book, count: 2, build: :authors)

# Published books
catalog_published_books =
  CatalogFactory.insert!(Catalog.Book, variant: :published, count: 2, build: :authors)

catalog_published_book_1 = Enum.at(catalog_published_books, 0)
catalog_published_book_2 = Enum.at(catalog_published_books, 1)

# Book authors
catalog_authors = CatalogFactory.insert!(Catalog.Author, count: 2)

# Books with more than 1 author
CatalogFactory.insert!(Catalog.Book, count: 2, relate: [authors: catalog_authors])

# Published books with more than 1 author
CatalogFactory.insert!(Catalog.Book,
  variant: :published,
  count: 2,
  relate: [authors: catalog_authors]
)

### Feedback ###

# Authors
feedback_authors = FeedbackFactory.insert!(Feedback.Author, count: 2)
feedback_author_1 = Enum.at(feedback_authors, 0)
feedback_author_2 = Enum.at(feedback_authors, 1)

# # Published book with 2 reviews and 1 comment

feedback_review_1 =
  FeedbackFactory.insert!(Feedback.Review,
    relate: [book: catalog_published_book_1, author: feedback_author_1]
  )

feedback_review_2 =
  FeedbackFactory.insert!(Feedback.Review,
    relate: [book: catalog_published_book_1, author: feedback_author_2]
  )

FeedbackFactory.insert!(Feedback.Comment,
  count: 2,
  relate: [review: feedback_review_2, author: feedback_author_1]
)

# Published book with 1 review and 2 comment

FeedbackFactory.insert!(Feedback.Review,
  relate: [book: catalog_published_book_2, author: feedback_author_2]
)

FeedbackFactory.insert!(Feedback.Comment,
  count: 2,
  relate: [review: feedback_review_1, author: feedback_author_1]
)

FeedbackFactory.insert!(Feedback.Comment,
  count: 2,
  relate: [review: feedback_review_1, author: feedback_author_2]
)

### Collaboration ###

CollaborationFactory.insert!(Collaboration.StudyGroup, count: 3)
