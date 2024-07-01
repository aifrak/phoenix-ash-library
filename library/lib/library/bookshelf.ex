defmodule Library.Bookshelf do
  use Ash.Domain

  resources do
    resource Library.Bookshelf.Book do
      define :create_book, action: :create
      define :list_books, action: :read
      define :update_book, action: :update
      define :destroy_book, action: :destroy
      define :get_book_by_id, args: [:id], action: :by_id
      define :get_book_by_title, args: [:title], action: :by_title
      define :get_book_by_isbn, args: [:isbn], action: :by_isbn
      define :search, args: [:query], action: :search
    end
  end
end
