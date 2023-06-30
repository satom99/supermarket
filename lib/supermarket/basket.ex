defmodule Supermarket.Basket do
  @moduledoc """
  Defines convenience methods for working with baskets.

  ## Examples

      iex> Supermarket.Basket.create_basket("my-cool-basket")
      {:ok, #PID<0.210.0>}

      iex> basket = Supermarket.Basket.get_basket("my-cool-basket")
      #PID<0.210.0>

      iex> Supermarket.Basket.get_basket_products(basket)
      []

      iex> Supermarket.Basket.get_basket_price(basket)
      %Money{amount: 0, currency: :GBP}

      iex> product = Supermarket.Product.new("PR1", "Protein powder", Money.new(1500))
      %Supermarket.Product{
        code: "PR1",
        name: "Protein powder",
        price: %Money{amount: 1500, currency: :GBP}
      }

      iex> Supermarket.Basket.add_product_to_basket(basket, product)
      :ok

      iex> Supermarket.Basket.get_basket_products(basket)
      [
        %Supermarket.Product{
          code: "PR1",
          name: "Protein powder",
          price: %Money{amount: 1500, currency: :GBP}
        }
      ]

      iex> Supermarket.Basket.get_basket_price(basket)
      %Money{amount: 1500, currency: :GBP}
  """
  alias Supermarket.{Product, Pricing}
  alias __MODULE__

  @typedoc "The unique identifier of a basket."
  @type basket_id() :: Registry.key()

  @typedoc "A reference to a basket."
  @type basket() :: pid()

  @doc """
  Creates a new basket with the given ID.
  """
  @spec create_basket(basket_id()) :: {:ok, basket()} | {:error, :already_exists}
  def create_basket(basket_id) do
    agent_name = {:via, Registry, {Basket.Registry, basket_id}}

    agent_child_spec = Basket.Agent.child_spec(name: agent_name)

    case DynamicSupervisor.start_child(Basket.Supervisor, agent_child_spec) do
      {:ok, _basket} = tuple ->
        tuple

      {:error, {:already_started, _basket}} ->
        {:error, :already_exists}
    end
  end

  @doc """
  Attempts to get a `t:basket/0` reference for the given ID.
  """
  @spec get_basket(basket_id()) :: basket() | nil
  def get_basket(basket_id) do
    case Registry.lookup(Basket.Registry, basket_id) do
      [{pid, _value}] ->
        pid

      _other ->
        nil
    end
  end

  @doc """
  Adds a given product to the basket.
  """
  @spec add_product_to_basket(basket(), Product.t()) :: :ok
  def add_product_to_basket(basket, %Product{} = product) do
    Basket.Agent.add_item(basket, product)
  end

  @doc """
  Returns the list of products currently in the basket.
  """
  @spec get_basket_products(basket()) :: [] | [Product.t(), ...]
  def get_basket_products(basket) do
    Basket.Agent.get_items(basket)
  end

  @doc """
  Computes the current total price of the basket based on a list of pricing rules.

  See `Supermarket.Pricing.calculate_price/2` for more information.
  """
  @spec get_basket_price(basket(), [] | [Pricing.Rule.t(), ...]) :: Product.price()
  def get_basket_price(basket, pricing_rules \\ []) do
    products = get_basket_products(basket)

    Pricing.calculate_price(products, pricing_rules)
  end
end
