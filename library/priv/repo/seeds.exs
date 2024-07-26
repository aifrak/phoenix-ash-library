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
alias Library.Feedback
alias Library.FeedbackFactory
alias Library.Repo

Repo.delete_all(Feedback.Author)
Repo.delete_all(Feedback.Comment)
Repo.delete_all(Feedback.Review)
Repo.delete_all(Catalog.Author)
Repo.delete_all(Catalog.Book)

catalog_authors = CatalogFactory.insert!(Catalog.Author, count: 2)
CatalogFactory.insert!(Catalog.Book, count: 2)
CatalogFactory.insert!(Catalog.Book, count: 2, build: :authors)

published_books =
  CatalogFactory.insert!(Catalog.Book, variant: :published, count: 2, build: :authors)

published_book_1 = Enum.at(published_books, 0)
published_book_2 = Enum.at(published_books, 1)

CatalogFactory.insert!(Catalog.Book, count: 2, relate: [authors: catalog_authors])

CatalogFactory.insert!(Catalog.Book,
  variant: :published,
  count: 2,
  relate: [authors: catalog_authors]
)

feedback_authors = FeedbackFactory.insert!(Feedback.Author, count: 2)
feedback_author_1 = Enum.at(feedback_authors, 0)
feedback_author_2 = Enum.at(feedback_authors, 1)

feedback_review_1 =
  FeedbackFactory.insert!(Feedback.Review,
    relate: [book: published_book_1, author: feedback_author_1]
  )

feedback_review_2 =
  FeedbackFactory.insert!(Feedback.Review,
    relate: [book: published_book_1, author: feedback_author_2]
  )

FeedbackFactory.insert!(Feedback.Review,
  relate: [book: published_book_2, author: feedback_author_2]
)

FeedbackFactory.insert!(Feedback.Comment,
  count: 2,
  relate: [review: feedback_review_1, author: feedback_author_1]
)

FeedbackFactory.insert!(Feedback.Comment,
  count: 2,
  relate: [review: feedback_review_1, author: feedback_author_2]
)

FeedbackFactory.insert!(Feedback.Comment,
  count: 2,
  relate: [review: feedback_review_2, author: feedback_author_1]
)
