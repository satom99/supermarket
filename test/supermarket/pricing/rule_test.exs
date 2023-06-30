defmodule Supermarket.Pricing.RuleTest do
  use ExUnit.Case, async: true

  import Mox

  alias Supermarket.Factory
  alias Supermarket.Pricing.Rule

  test "new/3 returns a Rule struct" do
    module = Rule.Test

    product_code = Factory.product_code()

    options = []

    assert %Rule{module: module, product_code: product_code, options: options} ==
             Rule.new(module, product_code, options)
  end

  describe "calculate_discount/2" do
    test "when given a Rule struct, but the rule does not apply to any of the products" do
      rule = Rule.new(Rule.Test, Factory.product_code())

      product = Factory.product()

      discount = Rule.calculate_discount(rule, [product])

      assert Decimal.equal?(0, discount)
    end

    test "when given a Rule struct, and the rule applies to one of the products" do
      product = Factory.product()

      rule = Rule.new(Rule.Test, product.code, test: :hello)

      expect(Rule.Test, :calculate_discount, fn ^product, 4, [test: :hello] ->
        50
      end)

      discount = Rule.calculate_discount(rule, [product, product, product, product])

      assert Decimal.equal?(50, discount)
    end

    test "when given an empty list of pricing rules" do
      product = Factory.product()

      discount = Rule.calculate_discount([], [product])

      assert Decimal.equal?(0, discount)
    end

    test "when given a non-empty list of pricing rules" do
      product = Factory.product()

      rule_one = Rule.new(Rule.Test, product.code, test: :hello)

      rule_two = Rule.new(Rule.Test, Factory.product_code())

      rule_three = Rule.new(Rule.Test, product.code)

      rules = [rule_one, rule_two, rule_three]

      products = List.duplicate(product, 6)

      expect(Rule.Test, :calculate_discount, fn ^product, 6, [test: :hello] ->
        1337
      end)

      expect(Rule.Test, :calculate_discount, fn ^product, 6, [] ->
        42
      end)

      discount_one = Rule.calculate_discount(rule_one, products)

      discount_two = Rule.calculate_discount(rule_two, products)

      expect(Rule.Test, :calculate_discount, fn ^product, 6, [test: :hello] ->
        1337
      end)

      expect(Rule.Test, :calculate_discount, fn ^product, 6, [] ->
        42
      end)

      discount_three = Rule.calculate_discount(rule_three, products)

      discount = Rule.calculate_discount(rules, products)

      expected_discount =
        discount_one
        |> Decimal.add(discount_two)
        |> Decimal.add(discount_three)

      assert Decimal.equal?(expected_discount, discount)

      assert Decimal.equal?(1379, discount)
    end
  end
end
