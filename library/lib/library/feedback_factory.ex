if Enum.member?([:dev, :test], Mix.env()) do
  defmodule Library.FeedbackFactory do
    use Smokestack,
      otp_app: :library

    alias Library.Feedback.Author
    alias Library.Feedback.Review

    factory Review do
      attribute :rating, &Review.Fakes.rating/0
      attribute :comment, &Review.Fakes.comment/0
    end

    factory Author do
      attribute :first_name, &Author.Fakes.first_name/0
      attribute :last_name, &Author.Fakes.last_name/0
    end
  end
end
