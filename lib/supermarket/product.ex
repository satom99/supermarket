defmodule Supermarket.Product do
  @moduledoc """
  Defines a struct that represents products.
  """
  alias __MODULE__

  @typedoc "The unique code assigned to a product."
  @type code() :: String.t()

  @typedoc "The name of a product."
  @type name() :: String.t()

  @typedoc "The price of a product."
  @type price() :: Money.t()

  @typedoc "The Product struct."
  @type t() :: %Product{code: code(), name: name(), price: price()}

  defstruct [:code, :name, :price]

  @doc """
  Returns a `t:t/0` struct for the given parameters.
  """
  @spec new(code(), name(), price()) :: t()
  def new(code, name, price) do
    %Product{code: code, name: name, price: price}
  end
end
