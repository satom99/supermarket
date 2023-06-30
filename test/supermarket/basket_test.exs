defmodule Supermarket.BasketTest do
  use ExUnit.Case, async: false
  use Patch

  alias Supermarket.{Product, Basket, Pricing, Factory}

  setup do
    basket_id = Faker.UUID.v4()

    %{basket_id: basket_id}
  end

  describe "create_basket/1" do
    test "creates a new empty basket", %{basket_id: basket_id} do
      assert {:ok, basket} = Basket.create_basket(basket_id)

      assert [] = Basket.get_basket_products(basket)
    end

    test "returns an error if a basket was already created under the given ID", %{
      basket_id: basket_id
    } do
      {:ok, _basket} = Basket.create_basket(basket_id)

      assert {:error, :already_exists} = Basket.create_basket(basket_id)
    end
  end

  describe "get_basket/1" do
    test "returns a basket reference when a basket exists under the given ID", %{
      basket_id: basket_id
    } do
      {:ok, basket} = Basket.create_basket(basket_id)

      assert basket == Basket.get_basket(basket_id)
    end

    test "returns nil when there is no basket created under the given ID", %{basket_id: basket_id} do
      basket = Basket.get_basket(basket_id)

      assert is_nil(basket)
    end
  end

  test "add_product_to_basket/1 and get_basket_products/1", %{basket_id: basket_id} do
    # Create a new basket
    {:ok, basket} = Basket.create_basket(basket_id)

    # Add a first product
    first_product = Factory.product()

    assert :ok = Basket.add_product_to_basket(basket, first_product)

    assert [first_product] == Basket.get_basket_products(basket)

    # Add a second product
    second_product = Factory.product()

    assert :ok = Basket.add_product_to_basket(basket, second_product)

    products = Basket.get_basket_products(basket)

    # Check that the basket contains both products
    expected_products = [first_product, second_product]

    sort_mapper = fn %Product{code: code} -> code end

    assert Enum.sort_by(products, sort_mapper) == Enum.sort_by(expected_products, sort_mapper)
  end

  test "get_basket_price/{1, 2} delegates to Pricing.calculate_price/2", %{basket_id: basket_id} do
    {:ok, basket} = Basket.create_basket(basket_id)

    product = Factory.product()

    :ok = Basket.add_product_to_basket(basket, product)

    products = Basket.get_basket_products(basket)

    patch(Pricing, :calculate_price, fn ^products, [] -> :one end)

    assert :one == Basket.get_basket_price(basket)

    pricing_rule = Pricing.Rule.new(Pricing.Rule.Test, product.code)

    pricing_rules = [pricing_rule]

    patch(Pricing, :calculate_price, fn ^products, ^pricing_rules -> :two end)

    assert :two == Basket.get_basket_price(basket, pricing_rules)
  end
end
