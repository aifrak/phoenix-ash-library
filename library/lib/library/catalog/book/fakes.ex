if Enum.member?([:dev, :test], Mix.env()) do
  defmodule Library.Catalog.Book.Fakes do
    import Faker, only: [sampler: 2]

    @spec title() :: String.t()
    def title, do: Faker.Lorem.paragraph()

    @spec isbn() :: String.t()
    def isbn, do: Faker.Code.isbn13()

    @spec summary() :: String.t()
    def summary, do: Faker.Lorem.paragraph()

    @spec published_at() :: Date.t()
    def published_at, do: Faker.Date.backward(365)

    @doc """
    Returns a list with a number of subjects.

    If an integer is provided, exactly that number of subjects will be returned.
    If a range is provided, the number will be in the range.
    If no range or integer is specified it defaults to 2..5

    ## Examples

        iex> Library.Catalog.CatalogFakes.subjects()
        ["action", "comedy", "adventure"]
        iex> Library.Catalog.CatalogFakes.subjects(4)
        ["comedy", "action", "politic", "adventure"]
        iex> Library.Catalog.CatalogFakes.subjects(2..3)
        ["politic", "drama", "comedy"]
        iex> Library.Catalog.CatalogFakes.subjects(2..3)
        ["comedy", "drama"]
    """
    @spec subjects(Range.t()) :: list(String.t())
    def subjects(range \\ 2..5)

    def subjects(first..last//_) do
      subjects(Faker.random_between(first, last))
    end

    @spec subjects(integer) :: list(String.t())
    def subjects(num) do
      Faker.Util.join(num, ", ", &subject/0)
    end

    @doc """
    Returns an subject string

    ## Examples

        iex> Library.Catalog.CatalogFakes.subject()
        "drama
        iex> Library.Catalog.CatalogFakes.subject()
        "action"
        iex> Library.Catalog.CatalogFakes.subject()
        "comedy"
        iex> Library.Catalog.CatalogFakes.subject()
        "sci-fi"
    """
    @spec subject() :: String.t()
    sampler(:subject, ["sci-fi", "drama", "action", "adventure", "politic", "comedy"])

    @spec price() :: Money.t()
    def price,
      do: %Money{
        currency: Faker.Currency.code(),
        amount: Decimal.new(1, Faker.Random.Elixir.random_between(0, 10_000), -2)
      }
  end
end
