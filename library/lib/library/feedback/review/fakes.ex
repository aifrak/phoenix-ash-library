if Enum.member?([:dev, :test], Mix.env()) do
  defmodule Library.Feedback.Review.Fakes do
    @spec rating() :: 1..5
    def rating, do: Faker.Random.Elixir.random_between(1, 5)

    @spec comment() :: String.t()
    def comment, do: Faker.Lorem.paragraph()
  end
end
