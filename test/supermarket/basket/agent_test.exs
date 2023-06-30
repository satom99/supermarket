defmodule Supermarket.Basket.AgentTest do
  use ExUnit.Case, async: true

  alias Supermarket.Basket

  setup do
    {:ok, agent} = Basket.Agent.start_link()

    %{agent: agent}
  end

  test "The initial state of the Agent is an empty list", %{agent: agent} do
    assert [] = Basket.Agent.get_items(agent)
  end

  test "get_items/1 and add_item/2", %{agent: agent} do
    # Add a first item
    first_item = Faker.Blockchain.Bitcoin.address()

    assert :ok = Basket.Agent.add_item(agent, first_item)

    # Add a second item
    second_item = Faker.Blockchain.Bitcoin.address()

    assert :ok = Basket.Agent.add_item(agent, second_item)

    # Add a third item
    third_item = Faker.Blockchain.Bitcoin.address()

    assert :ok = Basket.Agent.add_item(agent, third_item)

    # Check that the Agent has stored all three items
    items = Basket.Agent.get_items(agent)

    expected_items = [first_item, second_item, third_item]

    assert Enum.sort(expected_items) == Enum.sort(items)
  end
end
