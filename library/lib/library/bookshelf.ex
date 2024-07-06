defmodule Library.Bookshelf do
  use Ash.Domain

  resources do
    resource Library.Bookshelf.Book do
      define :create_book, action: :create
      define :list_books, action: :read
      define :update_book, action: :update
      define :destroy_book, action: :destroy
      define :get_book_by_id, get_by: [:id], action: :read
      define :get_book_by_isbn, get_by: [:isbn], action: :read
      define :list_books_by_title, args: [:title], action: :by_title
      define :search_books, args: [:query], action: :search
    end
  end
end
