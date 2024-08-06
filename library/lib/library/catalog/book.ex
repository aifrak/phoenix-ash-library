defmodule Library.Catalog.Book do
  use Ash.Resource,
    otp_app: :library,
    domain: Library.Catalog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshJsonApi.Resource, AshStateMachine],
    authorizers: [Ash.Policy.Authorizer]

  alias Library.Catalog.Book.Validations

  resource do
    description "Resource handling books."
    plural_name :books
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :state, :book_state, default: :draft, allow_nil?: false, public?: true
    attribute :isbn, :string, allow_nil?: false, public?: true
    attribute :title, :string, allow_nil?: false, public?: true
    attribute :subject, :string, public?: true
    attribute :summary, :string, public?: true
    attribute :published_at, :date, public?: true
    attribute :price, :money, public?: true

    timestamps()
  end

  relationships do
    many_to_many :authors, Library.Catalog.Author,
      public?: true,
      through: Library.Catalog.BookAuthor,
      source_attribute_on_join_resource: :book_id,
      destination_attribute_on_join_resource: :author_id
  end

  validations do
    validate compare(:published_at, less_than_or_equal_to: &Date.utc_today/0),
      message: "must be today or before"

    validate {Validations.IsISBN, []}, on: :create
    validate string_length(:title, max: 200)
    validate string_length(:subject, max: 200)
    validate string_length(:summary, max: 500)
    validate attribute_equals(:state, :draft), on: :destroy
    validate compare(:price, greater_than_or_equal_to: 0)
  end

  policies do
    policy action_type(:read), authorize_if: always()
    policy action_type(:create), authorize_if: actor_present()
    policy action_type(:update), authorize_if: always()
    policy action_type(:destroy), authorize_if: always()
    # Use below if we want to check that the current author is ones of the associated book authors
    # policy action_type(:update), authorize_if: relates_to_actor_via(:authors)
    # policy action_type(:destroy), authorize_if: relates_to_actor_via(:authors)
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
      accept [:isbn, :title, :subject, :summary, :published_at, :price]
    end

    update :update do
      accept [:title, :subject, :summary, :published_at, :price]
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
      change set_attribute(:published_at, &DateTime.utc_now/0)
    end

    update :retire do
      change transition_state(:retired)
    end

    read :by_title do
      argument :title, :string, allow_nil?: false

      filter expr(contains(string_downcase(title), string_downcase(^arg(:title))))

      pagination offset?: true, default_limit: 10, countable: :by_default
    end

    ## Examples:
    #
    # Add limit (see: https://hexdocs.pm/ash/Ash.Query.html#page/2):
    #   iex> Library.Catalog.search_books("example", page: [limit: 1])
    #
    # Sort by title (see: https://hexdocs.pm/ash/Ash.Query.html#sort/3):
    #   iex> Library.Catalog.search_books("example", query: [sort: [title: :desc]])
    #   iex> Library.Catalog.search_books("example", query: [sort: [title: :desc]])
    read :search do
      description """
      Search books containing the given query in title, summary or subject.
      """

      argument :query, :string, allow_nil?: true

      # Same as:
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

  postgres do
    table "catalog_books"
    repo Library.Repo
  end

  json_api do
    type "book"
    includes authors: []
  end
end
