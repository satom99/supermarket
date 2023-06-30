defmodule Supermarket.Pricing.Rule.BuySomeDiscountAll do
  @moduledoc """
  Implements the `Supermarket.Pricing.Rule` behaviour.

  Defines a "Buy X and get a discount on all items" discount.

  Expects the following `options` to be passed:
  - `:buy` - speficies the minimum amount of product for the discount to apply.

  - `:percentage` - specifies the percentage to be applied over the product's price as discount.
  """
  @behaviour Supermarket.Pricing.Rule

  alias Supermarket.Product

  def calculate_discount(product, amount, options) do
    buy = Keyword.fetch!(options, :buy)

    percentage = Keyword.fetch!(options, :percentage)

    do_calculate_discount(product, amount, buy, percentage)
  end

  defp do_calculate_discount(_product, amount, buy, _percentage) when amount < buy do
    0
  end

  defp do_calculate_discount(%Product{price: price}, amount, _buy, percentage) do
    percentage = Decimal.from_float(percentage)

    price
    |> Money.to_decimal()
    |> Decimal.mult(percentage)
    |> Decimal.mult(amount)
  end
end
