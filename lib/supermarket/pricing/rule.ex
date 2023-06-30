defmodule Supermarket.Pricing.Rule do
  @moduledoc """
  Defines a behaviour that allows implementing custom pricing rules.
  """
  alias Supermarket.Product
  alias __MODULE__

  @typedoc """
  A module implementing the `Supermarket.Pricing.Rule` behaviour.
  """
  @type rule() :: module()

  @typedoc """
  The code of the product to which the pricing rule applies.
  """
  @type product_code() :: Product.code()

  @typedoc """
  Custom options depending on the `t:rule/0` in use.
  """
  @type options() :: Keyword.t()

  @typedoc """
  The Rule struct. Used to hold information of a pricing rule.
  """
  @type t() :: %Rule{module: rule(), product_code: product_code(), options: options()}

  @doc """
  Returns the applicable discount for a given product, product amount and options.
  """
  @callback calculate_discount(Product.t(), pos_integer(), options()) :: Decimal.t()

  defstruct [:module, :product_code, :options]

  @doc """
  Returns a `t:t/0` struct for the given parameters.
  """
  @spec new(rule(), product_code(), options()) :: t()
  def new(module, product_code, options \\ []) do
    %Rule{module: module, product_code: product_code, options: options}
  end

  @doc """
  Returns the price discount that must be applied over a list of products based on the given list of pricing rules.
  """
  @spec calculate_discount(Rule.t() | [Rule.t(), ...], [Product.t(), ...]) :: Decimal.t()
  def calculate_discount([], _products) do
    0
  end

  def calculate_discount(rule_or_rules, products) do
    product_frequencies = Enum.frequencies(products)

    do_calculate_discount(rule_or_rules, product_frequencies)
  end

  defp do_calculate_discount(rules, product_frequencies) when is_list(rules) do
    rules
    |> Stream.map(&do_calculate_discount(&1, product_frequencies))
    |> Enum.reduce(&Decimal.add/2)
  end

  defp do_calculate_discount(
         %Rule{module: module, product_code: product_code, options: options},
         product_frequencies
       ) do
    case get_product_and_frequency(product_frequencies, product_code) do
      nil ->
        0

      {product, frequency} ->
        module.calculate_discount(product, frequency, options)
    end
  end

  defp get_product_and_frequency(product_frequencies, product_code) do
    Enum.find_value(
      product_frequencies,
      fn
        {%Product{code: ^product_code}, _frequency} = tuple ->
          tuple

        _other ->
          nil
      end
    )
  end
end
