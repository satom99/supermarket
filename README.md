# Supermarket

[![Elixir CI](https://github.com/satom99/supermarket/actions/workflows/elixir.yml/badge.svg?branch=main)](https://github.com/satom99/supermarket/actions/workflows/elixir.yml)
[![Coverage Status](https://coveralls.io/repos/github/satom99/supermarket/badge.svg?branch=main)](https://coveralls.io/github/satom99/supermarket?branch=main)

This is *a* solution to a technical test for a senior position at [Kantox](https://kantox.com).

The original test description can be found in the file [`Technical evaluation Elixir.pdf`](Technical%20evaluation%20Elixir.pdf).

---

## Assignment

You are the lead programmer for a small chain of supermarkets. You are required to make a simple cashier function that adds products to a cart and displays the total price.

You have the following test products registered:

| **Product code** | **Name**     | **Price** |
|------------------|--------------|-----------|
| GR1              | Green tea    | £3.11     |
| SR1              | Strawberries | £5.00     |
| CF1              | Coffee       | £11.23    |

Special conditions:
- The CEO is a big fan of buy-one-get-one-free offers and of green tea. He wants us to add a rule to do this.

- The COO, though, likes low prices and wants people buying strawberries to get a price discount for bulk purchases. If you buy 3 or more strawberries, the price should drop to £4.50 per strawberry.

- The CTO is a coffee addict. If you buy 3 or more coffees, the price of all coffees should drop to two thirds of the original price.

Our check-out can scan items in any order, and because the CEO and COO change their minds often, it needs to be flexible regarding our pricing rules.

**Implement a checkout system that fulfills these requirements.**

Test data:

Basket: GR1, SR1, GR1, GR1, CF1 \
Total price expected: **£22.45**

Basket: GR1, GR1 \
Total price expected: **£3.11**

Basket: SR1, SR1, GR1, SR1 \
Total price expected: **£16.61**

Basket: GR1, CF1, SR1, CF1, CF1 \
Total price expected: **£30.57**

## A solution

This repository contains *a* solution to the assignment above. The code is split into the following contexts:
- The [`Supermarket.Product`](lib/supermarket/product.ex) module defines a struct that allows representing products.

- The [`Supermarket.Basket`](lib/supermarket/basket.ex) module defines convenience methods for working with shopping baskets. This is where a basket can be created and where products can be added to it.

- The [`Supermarket.Pricing`](lib/supermarket/pricing.ex) module defines convenience functions for calculating the price of a list of products, and allows for discounts based on customizable pricing rules.

It is with the combination of these three that we are able to fullfill the requirements of the assignment above.

### Assignment compliance

The test file [`test/supermarket/functional_test.exs`](test/supermarket/functional_test.exs) contains tests that validate the assignment's "Test data".

### Overview

The source code contains documentation and typespecs. The documentation is also [available online here](https://satom.me/supermarket).

We will now go through a brief introduction as to how the implemented functionality is intended to be used.

#### Product definition

Here is an example of a product definition.

```elixir
iex> green_tea = Supermarket.Product.new("GR1", "Green tea", Money.new(311))
%Supermarket.Product{
  code: "GR1",
  name: "Green tea",
  price: %Money{amount: 311, currency: :GBP}
}
```

#### Basket management

Here is an example of creating a basket and adding products to it.

```elixir
iex> Supermarket.Basket.create_basket("my-cool-basket")
{:ok, #PID<0.210.0>}

iex> basket = Supermarket.Basket.get_basket("my-cool-basket")
#PID<0.210.0>

iex> Supermarket.Basket.get_basket_products(basket)
[]

iex> Supermarket.Basket.add_product_to_basket(basket, green_tea)
:ok

iex> Supermarket.Basket.get_basket_products(basket)
[
  %Supermarket.Product{
    code: "GR1",
    name: "Green tea",
    price: %Money{amount: 311, currency: :GBP}
  }
]
```

#### Basket pricing

Here is an example of calculating the baseline price of a basket, i.e. the price with no discounts.

```elixir
iex> Supermarket.Basket.get_basket_price(basket)
%Money{amount: 311, currency: :GBP}
```

And here is an example of applying a "Buy one get one" discount offer.

```elixir
iex> pricing_rule = Supermarket.Pricing.Rule.new(Supermarket.Pricing.Rule.BuyOneGetOne, "GR1")
%Supermarket.Pricing.Rule{
  module: Supermarket.Pricing.Rule.BuyOneGetOne,
  product_code: "GR1",
  options: []
}

iex> Supermarket.Basket.get_basket_products(basket)
[
  %Supermarket.Product{
    code: "GR1",
    name: "Green tea",
    price: %Money{amount: 311, currency: :GBP}
  }
]

iex> Supermarket.Basket.get_basket_price(basket, [pricing_rule])
%Money{amount: 311, currency: :GBP}

iex> Supermarket.Basket.add_product_to_basket(basket, green_tea)
:ok

iex> Supermarket.Basket.add_product_to_basket(basket, green_tea)
:ok

iex> Supermarket.Basket.get_basket_products(basket)
[
  %Supermarket.Product{
    code: "GR1",
    name: "Green tea",
    price: %Money{amount: 311, currency: :GBP}
  },
  %Supermarket.Product{
    code: "GR1",
    name: "Green tea",
    price: %Money{amount: 311, currency: :GBP}
  },
  %Supermarket.Product{
    code: "GR1",
    name: "Green tea",
    price: %Money{amount: 311, currency: :GBP}
  }
]

iex> Supermarket.Basket.get_basket_price(basket, [pricing_rule])
%Money{amount: 622, currency: :GBP}
```

#### Pricing rules

There is a [`Supermarket.Pricing.Rule`](lib/supermarket/pricing/rule.ex) behaviour that can be used to implement new custom pricing rules.

At the moment of writing there are the following two built-in pricing rules:
- [`Supermarket.Pricing.Rule.BuyOneGetOne`](lib/supermarket/pricing/rules/buy_one_get_one.ex) that allows for "Buy one get one" or "2 x 1" discounts. The CEO discount is an example of this.

- [`Supermarket.Pricing.Rule.BuySomeDiscountAll`](lib/supermarket/pricing/rules/buy_some_discount_all.ex) that allows for "Buy X and get a discount on all items" discounts. Both the COO and CTO discounts are an example: the first one discounts a 10% over strawberries when buying a minimum of three units, and the second one too discounts a whopping 33.33% over coffee when buying a minimum of three units.