defmodule Supermarket.PricingTest do
  use ExUnit.Case, async: true

  import Mox

  alias Supermarket.{Pricing, Factory}

  describe "calculate_price/2" do
    test "when given an empty list of products" do
      price = Pricing.calculate_price([])

      expected_price = Money.new(0)

      assert Money.equals?(expected_price, price)
    end

    test "when given an empty list of pricing rules" do
      products = [Factory.product(), Factory.product(), Factory.product(), Factory.product()]

      price = Pricing.calculate_price(products)

      expected_price =
        products
        |> Stream.map(& &1.price)
        |> Enum.reduce(&Money.add/2)

      assert Money.equals?(expected_price, price)
    end

    test "when given a list of products, and a list of pricing rules" do
      products = [Factory.product(), Factory.product(), Factory.product(), Factory.product()]

      pricing_rule_product = hd(products)

      pricing_rule = Pricing.Rule.new(Pricing.Rule.Test, pricing_rule_product.code, magic: :loads)

      expect(Pricing.Rule.Test, :calculate_discount, 2, fn ^pricing_rule_product,
                                                           1,
                                                           [magic: :loads] ->
        8
      end)

      price = Pricing.calculate_price(products, [pricing_rule])

      baseline_price = Pricing.calculate_price(products, [])

      pricing_rule_discount = Pricing.Rule.calculate_discount(pricing_rule, products)

      expected_price =
        baseline_price
        |> Money.to_decimal()
        |> Decimal.sub(pricing_rule_discount)
        |> Money.parse!()

      assert Money.equals?(expected_price, price)
    end
  end
end
