defmodule Supermarket.Application do
  @moduledoc false

  use Application

  alias Supermarket.Basket

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Basket.Registry},
      {DynamicSupervisor, name: Basket.Supervisor}
    ]

    options = [
      name: __MODULE__,
      strategy: :one_for_one
    ]

    Supervisor.start_link(children, options)
  end
end
