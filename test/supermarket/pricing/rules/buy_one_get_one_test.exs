defmodule Supermarket.Pricing.Rule.BuyOneGetOneTest do
  use ExUnit.Case, async: true

  alias Supermarket.Factory
  alias Supermarket.Pricing.Rule.BuyOneGetOne

  setup do
    product = Factory.product()

    %{product: product}
  end

  describe "calculate_discount/3" do
    test "when the amount of product is less than 2", %{product: product} do
      discount = BuyOneGetOne.calculate_discount(product, 1, [])

      assert Decimal.equal?(0, discount)
    end

    test "when the amount of product is greater than or equal to 2", %{product: product} do
      discount = BuyOneGetOne.calculate_discount(product, 7, [])

      expected_discount =
        product.price
        |> Money.to_decimal()
        |> Decimal.mult(3)

      assert Decimal.equal?(expected_discount, discount)
    end
  end
end
