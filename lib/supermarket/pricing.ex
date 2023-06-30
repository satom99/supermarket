defmodule Supermarket.Pricing do
  @moduledoc """
  Defines convenience functions for calculating the price of a list of products.
  """
  alias Supermarket.Product
  alias Supermarket.Pricing.Rule

  @doc """
  Calculates the total price of a list of products according to the given pricing rules.
  """
  @spec calculate_price([Product.t(), ...], [] | [Rule.t(), ...]) :: Money.t()
  def calculate_price(products, pricing_rules \\ [])

  def calculate_price([], _pricing_rules) do
    Money.new(0)
  end

  def calculate_price(products, []) do
    products
    |> Stream.map(& &1.price)
    |> Enum.reduce(&Money.add/2)
  end

  def calculate_price(products, pricing_rules) do
    baseline_price = calculate_price(products, [])

    pricing_rules_discount = Rule.calculate_discount(pricing_rules, products)

    baseline_price
    |> Money.to_decimal()
    |> Decimal.sub(pricing_rules_discount)
    |> Money.parse!()
  end
end
