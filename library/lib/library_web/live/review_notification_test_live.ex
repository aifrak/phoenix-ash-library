defmodule LibraryWeb.ReviewNotificationTestLive do
  use LibraryWeb, :live_view

  require Logger

  @impl true
  def handle_params(%{"book_id" => book_id}, _url, socket) do
    if connected?(socket), do: Library.Feedback.subscribe_created_reviews(book_id)

    {:noreply, assign(socket, :book_id, book_id)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h2 class="text-xl text-center">Review notification test page</h2>
    <p>Book ID: <%= @book_id %></p>
    <p>
      Add book_id as URL parameter then try to create a review from the console.
    </p>
    """
  end

  @impl true
  def handle_info(
        %{
          topic: "feedback_review:created:" <> _book_id,
          event: "create",
          payload: %{data: %Library.Feedback.Review{} = review}
        },
        socket
      ) do
    socket
    |> put_flash(:info, "New review added. Rating: #{review.rating}/5")
    |> then(&{:noreply, &1})
  end
end
