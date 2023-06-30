defmodule Supermarket.Basket.Agent do
  @moduledoc """
  Defines a simple `Agent` that holds a list of items.
  """
  use Agent

  @doc "Starts a new agent."
  def start_link(options \\ []) do
    fun = fn -> [] end

    Agent.start_link(fun, options)
  end

  @doc "Returns the list of items currently held by the agent."
  def get_items(agent) do
    fun = fn items ->
      items
    end

    Agent.get(agent, fun)
  end

  @doc "Adds a new item to the agent."
  def add_item(agent, item) do
    fun = fn items ->
      [item | items]
    end

    Agent.update(agent, fun)
  end
end
