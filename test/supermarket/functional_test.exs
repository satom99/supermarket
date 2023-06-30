defmodule Supermarket.FunctionalTest do
  use ExUnit.Case, async: true

  alias Supermarket.{Product, Pricing, Basket}

  describe "Kantox assignment compliance" do
    @green_tea Product.new("GR1", "Green tea", Money.new(311))

    @strawberries Product.new("SR1", "Strawberries", Money.new(500))

    @coffee Product.new("CF1", "Coffee", Money.new(1123))

    @ceo_pricing_rule Pricing.Rule.new(Pricing.Rule.BuyOneGetOne, @green_tea.code)

    @coo_pricing_rule Pricing.Rule.new(Pricing.Rule.BuySomeDiscountAll, @strawberries.code,
                        buy: 3,
                        percentage: 0.1
                      )

    @cto_pricing_rule Pricing.Rule.new(Pricing.Rule.BuySomeDiscountAll, @coffee.code,
                        buy: 3,
                        percentage: 1 / 3
                      )

    @pricing_rules [@ceo_pricing_rule, @coo_pricing_rule, @cto_pricing_rule]

    setup do
      basket_id = Faker.UUID.v4()

      {:ok, basket} = Supermarket.Basket.create_basket(basket_id)

      %{basket: basket}
    end

    test "Basket: {GR1, SR1, GR1, GR1, CF1}, Total price: £22.45", %{basket: basket} do
      :ok = Basket.add_product_to_basket(basket, @green_tea)

      :ok = Basket.add_product_to_basket(basket, @strawberries)

      :ok = Basket.add_product_to_basket(basket, @green_tea)

      :ok = Basket.add_product_to_basket(basket, @green_tea)

      :ok = Basket.add_product_to_basket(basket, @coffee)

      basket_price = Basket.get_basket_price(basket, @pricing_rules)

      expected_basket_price = Money.new(2245)

      assert Money.equals?(expected_basket_price, basket_price)
    end

    test "Basket: {GR1, GR1}, Total price: £3.11", %{basket: basket} do
      :ok = Basket.add_product_to_basket(basket, @green_tea)

      :ok = Basket.add_product_to_basket(basket, @green_tea)

      basket_price = Basket.get_basket_price(basket, @pricing_rules)

      expected_basket_price = Money.new(311)

      assert Money.equals?(expected_basket_price, basket_price)
    end

    test "Basket: {SR1, SR1, GR1, SR1}, Total price: £16.61", %{basket: basket} do
      :ok = Basket.add_product_to_basket(basket, @strawberries)

      :ok = Basket.add_product_to_basket(basket, @strawberries)

      :ok = Basket.add_product_to_basket(basket, @green_tea)

      :ok = Basket.add_product_to_basket(basket, @strawberries)

      basket_price = Basket.get_basket_price(basket, @pricing_rules)

      expected_basket_price = Money.new(1661)

      assert Money.equals?(expected_basket_price, basket_price)
    end

    test "Basket: {GR1, CF1, SR1, CF1, CF1}, Total price: £30.57", %{basket: basket} do
      :ok = Basket.add_product_to_basket(basket, @green_tea)

      :ok = Basket.add_product_to_basket(basket, @coffee)

      :ok = Basket.add_product_to_basket(basket, @strawberries)

      :ok = Basket.add_product_to_basket(basket, @coffee)

      :ok = Basket.add_product_to_basket(basket, @coffee)

      basket_price = Basket.get_basket_price(basket, @pricing_rules)

      expected_basket_price = Money.new(3057)

      assert Money.equals?(expected_basket_price, basket_price)
    end
  end
end
