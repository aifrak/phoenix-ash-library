defmodule Library.Catalog do
  use Ash.Domain, otp_app: :library, extensions: [AshJsonApi.Domain, AshPaperTrail.Domain]

  alias Library.Catalog.Author
  alias Library.Catalog.Book
  alias Library.Catalog.BookAuthor
  alias Library.Catalog.VersionView

  resources do
    # Domain
    resource Book do
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

    resource Author do
      define :create_author, action: :create
      define :get_author_by_id, get_by: [:id], action: :read
      define :list_authors, action: :read
      define :list_authors_with_top_5_books, action: :list_with_top_5_books
      define :update_author, action: :update
      define :destroy_author, action: :destroy
    end

    resource BookAuthor

    # Versions (ash_paper_trail)
    resource Author.Version
    resource Book.Version
    resource BookAuthor.Version

    # SQL Views
    resource VersionView
  end

  json_api do
    prefix "/api/json/catalog"

    routes do
      # in the domain `base_route` acts like a scope
      base_route "/v1/books", Book do
        get :read, primary?: true
        index :search
        post :create, relationship_arguments: [:authors]
        patch :update, relationship_arguments: [:authors]
        delete :destroy
        relationship :authors, :read
        related :authors, :read
      end

      base_route "/v1/authors", Author do
        get :read, primary?: true
        index :read
        post :create
        patch :update
        delete :destroy
      end
    end
  end

  paper_trail do
    include_versions? false
  end
end