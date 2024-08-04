if Enum.member?([:dev, :test], Mix.env()) do
  defmodule Library.CatalogFactory do
    use Smokestack,
      otp_app: :library

    alias Library.Catalog.Author
    alias Library.Catalog.Book

    factory Book do
      attribute :title, &Book.Fakes.title/0
      attribute :isbn, &Book.Fakes.isbn/0
      attribute :subject, &Book.Fakes.subjects/0
      attribute :summary, &Book.Fakes.summary/0
    end

    factory Book, :published do
      attribute :title, &Book.Fakes.title/0
      attribute :isbn, &Book.Fakes.isbn/0
      attribute :subject, &Book.Fakes.subjects/0
      attribute :summary, &Book.Fakes.summary/0
      attribute :state, fn -> :published end
      attribute :published_at, &Book.Fakes.published_at/0
    end

    factory Author do
      attribute :first_name, &Author.Fakes.first_name/0
      attribute :last_name, &Author.Fakes.last_name/0
    end
  end
end
