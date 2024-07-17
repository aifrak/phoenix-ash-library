if Enum.member?([:dev, :test], Mix.env()) do
  defmodule Library.Catalog.Author.Fakes do
    @spec first_name() :: String.t()
    def first_name, do: Faker.Person.first_name()

    @spec last_name() :: String.t()
    def last_name, do: Faker.Person.last_name()
  end
end
