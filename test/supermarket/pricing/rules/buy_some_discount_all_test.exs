defmodule Supermarket.Pricing.Rule.BuySomeDiscountAllTest do
  use ExUnit.Case, async: true

  alias Supermarket.Factory
  alias Supermarket.Pricing.Rule.BuySomeDiscountAll

  setup do
    product = Factory.product()

    %{product: product}
  end

  describe "calculate_discount/3" do
    test "when the amount of product is less than the :buy option", %{product: product} do
      options = [buy: 3, percentage: 0.1]

      discount = BuySomeDiscountAll.calculate_discount(product, 2, options)

      assert Decimal.equal?(0, discount)
    end

    test "when the amount of product is greater than or equal to the :buy option", %{
      product: product
    } do
      options = [buy: 3, percentage: 0.1]

      discount = BuySomeDiscountAll.calculate_discount(product, 7, options)

      percentage = Decimal.from_float(0.1)

      expected_discount =
        product.price
        |> Money.to_decimal()
        |> Decimal.mult(percentage)
        |> Decimal.mult(7)

      assert Decimal.equal?(expected_discount, discount)
    end
  end
end
