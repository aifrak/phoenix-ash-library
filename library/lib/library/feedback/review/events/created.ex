defmodule Library.Feedback.Review.Events.Created do
  alias Library.Feedback.Review
  alias Library.PubSubHelper
  alias LibraryWeb.Endpoint

  @spec subscribe(Review.book_id()) :: PubSubHelper.dispatch_result()
  def subscribe(book_id), do: Endpoint.subscribe(topic(book_id))

  defp topic(book_id), do: "feedback_review:created:#{book_id}"
end
