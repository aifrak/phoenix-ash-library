defmodule LibraryWeb.BooksLive do
  use LibraryWeb, :live_view

  alias Library.Catalog
  alias Library.Catalog.Book

  def render(assigns) do
    ~H"""
    <h2 class="text-xl text-center">Your Books</h2>
    <div class="my-4">
      <div :if={Enum.empty?(@books)} class="font-bold text-center">
        No books created yet
      </div>
      <ol class="list-decimal">
        <li :for={book <- @books} class="mt-4">
          <div class="font-bold"><%= book.title %></div>
          <div>
            <div class="font-bold">ISBN:</div>
            <div><%= book.isbn %></div>
          </div>
          <div>
            <div class="font-bold">Subject:</div>
            <div><%= book.subject %></div>
          </div>
          <div>
            <div class="font-bold">Summary:</div>
            <div><%= book.summary %></div>
          </div>
          <div>
            <div class="font-bold">Published at:</div>
            <div><%= book.published_at %></div>
          </div>
          <button
            class="mt-2 p-2 bg-black text-white rounded-md"
            phx-click="delete_book"
            phx-value-book-id={book.id}
          >
            Delete book
          </button>
        </li>
      </ol>
    </div>
    <h2 class="mt-8 text-lg">Create Book</h2>
    <.form :let={f} for={@create_form} phx-submit="create_book">
      <.input type="text" field={f[:isbn]} placeholder="input isbn" />
      <.input type="text" field={f[:title]} placeholder="input title" />
      <.input type="text" field={f[:subject]} placeholder="input subject" />
      <.input type="text" field={f[:summary]} placeholder="input summary" />
      <.input type="date" field={f[:published_at]} placeholder="input published at" />
      <.button class="mt-2" type="submit">Create</.button>
    </.form>
    <h2 class="mt-8 text-lg">Update Book</h2>
    <.form :let={f} for={@update_form} phx-submit="update_book">
      <.label>Book Name</.label>
      <.input type="select" field={f[:book_id]} options={@book_options} />
      <.input type="text" field={f[:subject]} placeholder="input subject" />
      <.input type="text" field={f[:summary]} placeholder="input summary" />
      <.input type="date" field={f[:published_at]} placeholder="input published at" />
      <.button class="mt-2" type="submit">Update</.button>
    </.form>
    """
  end

  def mount(_params, _session, socket) do
    books = Catalog.list_books!()

    socket
    |> assign(
      books: books,
      book_options: book_options(books)
    )
    |> reset_create_form()
    |> reset_update_form(books)
    |> then(&{:ok, &1})
  end

  def handle_event("delete_book", %{"book-id" => book_id}, socket) do
    book_id |> Catalog.get_book_by_id!() |> Catalog.destroy_book!()
    books = Catalog.list_books!()

    {:noreply, assign(socket, books: books, book_options: book_options(books))}
  end

  def handle_event("create_book", %{"form" => form_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.create_form, params: form_params) do
      {:ok, _book} ->
        books = Catalog.list_books!()

        socket
        |> assign(books: books, book_options: book_options(books))
        |> reset_create_form()
        |> then(&{:noreply, &1})

      {:error, create_form} ->
        {:noreply, assign(socket, create_form: create_form)}
    end
  end

  def handle_event("update_book", %{"form" => form_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.update_form, params: form_params) do
      {:ok, _book} ->
        books = Catalog.list_books!()

        socket
        |> assign(books: books, book_options: book_options(books))
        |> reset_update_form(books)
        |> then(&{:noreply, &1})

      {:error, update_form} ->
        {:noreply, assign(socket, update_form: update_form)}
    end
  end

  defp book_options(books) do
    for book <- books do
      {book.title, book.id}
    end
  end

  defp reset_create_form(socket) do
    from = Book |> AshPhoenix.Form.for_create(:create) |> to_form()

    assign(socket, :create_form, from)
  end

  defp reset_update_form(socket, books) do
    form = books |> List.first(%Book{}) |> AshPhoenix.Form.for_update(:update) |> to_form()

    assign(socket, :update_form, form)
  end
end
