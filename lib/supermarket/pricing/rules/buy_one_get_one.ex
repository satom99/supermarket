defmodule Supermarket.Pricing.Rule.BuyOneGetOne do
  @moduledoc """
  Implements the `Supermarket.Pricing.Rule` behaviour.

  Defines a "Buy one get one" or "2 x 1" discount.
  """
  @behaviour Supermarket.Pricing.Rule

  alias Supermarket.Product

  def calculate_discount(%Product{price: price}, amount, _options) do
    allocations = Integer.floor_div(amount, 2)

    price
    |> Money.to_decimal()
    |> Decimal.mult(allocations)
  end
end
