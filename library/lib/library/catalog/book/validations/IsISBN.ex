defmodule Library.Catalog.Book.Validations.IsISBN do
  use Ash.Resource.Validation

  @impl true
  def validate(changeset, opts, _context) do
    isbn = Ash.Changeset.get_attribute(changeset, :isbn)

    if is_nil(isbn) || Exisbn.valid?(isbn),
      do: :ok,
      else: {:error, field: :isbn, message: "must be a valid ISBN"}
  end
end
