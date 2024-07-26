if Enum.member?([:dev, :test], Mix.env()) do
  defmodule Library.Feedback.Comment.Fakes do
    @spec text() :: String.t()
    def text, do: Faker.Lorem.paragraph()
  end
end
