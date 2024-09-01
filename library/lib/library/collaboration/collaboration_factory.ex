if Enum.member?([:dev, :test], Mix.env()) do
  defmodule Library.CollaborationFactory do
    use Smokestack, otp_app: :library

    alias Library.Collaboration.StudyGroup

    factory StudyGroup do
      attribute :subject, &StudyGroup.Fakes.subject/0
      attribute :meet_at, &StudyGroup.Fakes.meet_at/0
      attribute :max_participants, &StudyGroup.Fakes.max_participants/0
      attribute :current_participants, &StudyGroup.Fakes.current_participants/0
    end
  end
end
