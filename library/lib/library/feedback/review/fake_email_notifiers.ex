defmodule Library.Feedback.Review.FakeEmailNotifiers do
  use Ash.Notifier

  alias Library.Feedback.Review

  require Logger

  @impl true
  def notify(%Ash.Notifier.Notification{
        resource: Review,
        action: %{name: :create = action},
        data: %Review{id: id}
      }) do
    Logger.info("Email sent for new review (id: #{id}, action: #{action})")
  end
end
