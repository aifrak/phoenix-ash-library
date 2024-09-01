if Enum.member?([:dev, :test], Mix.env()) do
  defmodule Library.Collaboration.StudyGroup.Fakes do
    @spec subject() :: String.t()
    def subject, do: Faker.Lorem.sentence()

    @spec meet_at() :: DateTime.t()
    def meet_at, do: Faker.DateTime.forward(365)

    @spec max_participants() :: pos_integer()
    def max_participants, do: Faker.random_between(1, 1000)

    @spec current_participants() :: pos_integer()
    def current_participants, do: Faker.random_between(0, 1000)
  end
end
