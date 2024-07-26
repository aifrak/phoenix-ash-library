defmodule Library.Feedback.Review.Notifiers.Created do
  use Ash.Notifier

  require Logger

  @impl true
  def notify(%Ash.Notifier.Notification{
        resource: Library.Feedback.Review,
        action: %{type: :create},
        data: %Library.Feedback.Review{} = _data
      }) do
    Logger.info("Hello")
  end
end
