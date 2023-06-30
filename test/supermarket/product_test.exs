defmodule Supermarket.ProductTest do
  use ExUnit.Case, async: true

  alias Supermarket.{Product, Factory}

  test "new/3 returns a Product struct" do
    code = Factory.product_code()

    name = Factory.product_name()

    price = Factory.product_price()

    assert %Product{code: code, name: name, price: price} == Product.new(code, name, price)
  end
end
