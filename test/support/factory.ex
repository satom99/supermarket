defmodule Supermarket.Factory do
  @moduledoc false

  alias Supermarket.Product

  def product_code() do
    Faker.Code.issn()
  end

  def product_name() do
    Faker.Commerce.product_name()
  end

  def product_price() do
    Money.parse!(Faker.Commerce.price() * 100)
  end

  def product() do
    Product.new(product_code(), product_name(), product_price())
  end
end
