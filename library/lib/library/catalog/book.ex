defmodule Library.Catalog.Book do
  use Ash.Resource,
    otp_app: :library,
    domain: Library.Catalog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshStateMachine]

  resource do
    description "Resource handling books."
    plural_name :books
  end

  postgres do
    table "books"
    repo Library.Repo
  end

  state_machine do
    initial_states [:draft]
    default_initial_state :draft

    transitions do
      transition :release_alpha, from: :draft, to: :alpha
      transition :release_beta, from: [:draft, :alpha], to: :beta
      transition :publish, from: [:draft, :alpha, :beta], to: :published
      transition :retire, from: [:draft, :alpha, :beta, :published], to: :retired
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:isbn, :title, :subject, :summary, :published_at]
    end

    update :update do
      accept [:title, :subject, :summary, :published_at]
      argument :authors, {:array, :map}

      # Add/remove author is done in another transaction
      require_atomic? false

      change manage_relationship(:authors, type: :append_and_remove)
    end

    update :release_alpha do
      change transition_state(:alpha)
    end

    update :release_beta do
      change transition_state(:beta)
    end

    update :publish do
      change transition_state(:published)
    end

    update :retire do
      change transition_state(:retired)
    end

    read :by_title do
      argument :title, :string, allow_nil?: false

      filter expr(contains(string_downcase(title), string_downcase(^arg(:title))))

      pagination offset?: true, default_limit: 10, countable: :by_default
    end

    read :search do
      description """
      ## Examples:

      Add limit (see: https://hexdocs.pm/ash/Ash.Query.html#page/2):
        iex> Library.Catalog.search_books("example", page: [limit: 1])

      Sort by title (see: https://hexdocs.pm/ash/Ash.Query.html#sort/3):
        iex> Library.Catalog.search_books("example", query: [sort: [title: :desc]])
        iex> Library.Catalog.search_books("example", query: [sort: [title: :desc]])
      """

      argument :query, :string, allow_nil?: true

      # Same:
      # prepare build(sort: [:title, :asc])
      prepare build(sort: [title: :asc, id: :asc])

      pagination offset?: true, default_limit: 10, countable: :by_default

      filter expr(
               if is_nil(^arg(:query)) do
                 true
               else
                 contains(string_downcase(title), string_downcase(^arg(:query))) or
                   contains(string_downcase(summary), string_downcase(^arg(:query))) or
                   contains(string_downcase(subject), string_downcase(^arg(:query)))
               end
             )
    end
  end

  validations do
    validate compare(:published_at, less_than: &Date.utc_today/0),
      on: [:create, :update],
      message: "must be before today"
  end

  attributes do
    uuid_primary_key :id

    attribute :state, :book_state, default: :draft, allow_nil?: false, public?: true
    attribute :isbn, :string, allow_nil?: false, public?: true
    attribute :title, :string, allow_nil?: false, public?: true
    attribute :subject, :string, public?: true
    attribute :summary, :string, public?: true
    attribute :published_at, :date, public?: true

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    many_to_many :authors, Library.Catalog.Author do
      through Library.Catalog.BookAuthor
      source_attribute_on_join_resource :book_id
      destination_attribute_on_join_resource :author_id
    end
  end
end
