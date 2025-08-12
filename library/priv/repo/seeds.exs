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
alias Library.Membership
alias Library.Repo

Repo.delete_all(Feedback.Author)
Repo.delete_all(Feedback.Comment)
Repo.delete_all(Feedback.Review)
Repo.delete_all(Catalog.Author)
Repo.delete_all(Catalog.Book)
Repo.delete_all(Membership.Balance)
Repo.delete_all(Membership.Transfer)
Repo.delete_all(Membership.Account)
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

### Membership ###

member =
  Library.Membership.Account
  |> Ash.Changeset.for_create(:open, %{
    number: "123-xyz",
    identifier: "abc-789",
    type: :member,
    currency: :EUR
  })
  |> Ash.create!()

vip =
  Membership.Account
  |> Ash.Changeset.for_create(:open, %{
    number: "111-www",
    identifier: "222-xxx",
    type: :vip,
    currency: :EUR
  })
  |> Ash.create!()

transfer =
  Membership.Transfer
  |> Ash.Changeset.for_create(:transfer, %{
    amount: Money.new!(50, :EUR),
    from_account_id: member.id,
    to_account_id: vip.id
  })
  |> Ash.create!()

# Get the current balance of an account for the current date
# balance_today =
#   Membership.Account
#   |> Ash.get!(member, load: :balance_as_of)
#   |> Map.get(:balance_as_of)
# => Money.new(:EUR, "-50")

# Get the current balance of an account for a given transfer
# balance_by_transfer_id =
#   Membership.Account
#   |> Ash.get!(member, load: [balance_as_of_ulid: %{ulid: transfer.id}])
#   |> Map.get(:balance_as_of_ulid)
# => Money.new(:EUR, "-50")

# balance_by_transfer_id =
#   Membership.Account
#   |> Ash.get!(member)
#   |> Ash.calculate(:balance_as_of_ulid, args: %{ulid: transfer.id})
# => Money.new(:EUR, "-50")
