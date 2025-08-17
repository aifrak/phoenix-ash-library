defmodule LibraryWeb.BookLive.Show do
  use LibraryWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Book {@book.id}
      <:subtitle>This is a book record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/books/#{@book}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit book</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id">{@book.id}</:item>

      <:item title="Isbn">{@book.isbn}</:item>

      <:item title="Title">{@book.title}</:item>

      <:item title="Subject">{@book.subject}</:item>

      <:item title="Summary">{@book.summary}</:item>

      <:item title="Published at">{@book.published_at}</:item>
    </.list>

    <.back navigate={~p"/books"}>Back to books</.back>

    <.modal :if={@live_action == :edit} id="book-modal" show on_cancel={JS.patch(~p"/books/#{@book}")}>
      <.live_component
        module={LibraryWeb.BookLive.FormComponent}
        id={@book.id}
        title={@page_title}
        action={@live_action}
        book={@book}
        patch={~p"/books/#{@book}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:book, Ash.get!(Library.Catalog.Book, id))}
  end

  defp page_title(:show), do: "Show Book"
  defp page_title(:edit), do: "Edit Book"
end
