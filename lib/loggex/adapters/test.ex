defmodule Loggex.Adapters.Test do
  @moduledoc ~S"""
  Test adapter for `Loggex`.

  Logs all events in memory to be requested.
  Ideal to test logging behavior in unit tests.
  """

  @behaviour Loggex.Adapter
  @table_name :loggex_adapters_test
  @table_options [:duplicate_bag, :public, :named_table]

  @impl Loggex.Adapter
  def log(tag, event, _opts) do
    ensure_table_created()
    :ets.insert(@table_name, {tag, event.()})

    :ok
  end

  @doc ~S"""
  Get all tags with logged events.

  ## Examples

  ```elixir
  iex> events()
  [...]
  ```
  """
  @spec events :: map
  def events do
    tags()
    |> Enum.map(&{&1, events(&1)})
    |> Enum.into(%{})
  end

  @doc ~S"""
  Get all logged events for a given tag.

  ## Examples

  ```elixir
  iex> events(:login)
  [...]
  ```
  """
  @spec events(Loggex.tag()) :: [map]
  def events(tag) do
    ensure_table_created()

    @table_name
    |> :ets.lookup(tag)
    |> Enum.map(&elem(&1, 1))
  end

  ### Helpers ###

  @spec ensure_table_created :: :ok
  defp ensure_table_created do
    case :ets.info(@table_name) do
      :undefined -> :ets.new(@table_name, @table_options)
      _ -> @table_name
    end

    :ok
  end

  @spec tags :: [Loggex.tag()]
  defp tags, do: tags(:ets.first(@table_name), [])
  defp tags(:"$end_of_table", acc), do: acc

  defp tags(tag, acc) do
    @table_name
    |> :ets.next(tag)
    |> tags([tag | acc])
  end
end
