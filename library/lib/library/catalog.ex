defmodule Library.Catalog do
  use Ash.Domain, otp_app: :library

  resources do
    resource Library.Catalog.Book do
      define :create_book, action: :create
      define :list_books, action: :read
      define :update_book, action: :update
      define :release_book_as_alpha, action: :release_alpha
      define :release_book_as_beta, action: :release_beta
      define :publish_book, action: :publish
      define :retire_book, action: :retire
      define :destroy_book, action: :destroy
      define :get_book_by_id, get_by: [:id], action: :read
      define :get_book_by_isbn, get_by: [:isbn], action: :read
      define :list_books_by_title, args: [:title], action: :by_title
      define :search_books, args: [:query], action: :search
    end
  end
end
