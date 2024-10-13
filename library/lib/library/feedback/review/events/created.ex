defmodule Library.Feedback.Review.Events.Created do
  use Ash.Notifier

  require Logger

  alias Library.Feedback.Review
  alias Library.PubSubHelper
  alias LibraryWeb.Endpoint

  @spec subscribe(Review.book_id()) :: PubSubHelper.dispatch_result()
  def subscribe(book_id), do: Endpoint.subscribe(topic(book_id))

  @impl true
  def notify(%Ash.Notifier.Notification{
        resource: Review,
        action: %{type: :create},
        data: %Review{} = _data
      }) do
    Logger.info("Hello")
  end

  defp topic(book_id), do: "feedback_review:created:#{book_id}"
end
