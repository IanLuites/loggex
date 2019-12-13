defmodule Loggex do
  @moduledoc """
  Documentation for Loggex.
  """

  @typedoc ~S"A log tag."
  @type tag :: String.t() | atom

  @typedoc ~S"""
  The event to log.

  The event can be a function to be lazily resolved.
  """
  @type event :: map | (() -> map)

  @typedoc ~S"Adapter yto user for logging."
  @type adapter :: atom | {atom, Keyword.t()}

  @doc ~S"""
  Log event under tag.

  ## Example

  ```elixir
  iex> log!(:logins, %{ip: "83.12.209.46"}
  ```
  """
  @spec log!(tag, event, Keyword.t()) :: :ok
  def log!(tag, event, opts \\ []) do
    event_function = fn -> Map.merge(base_data(), resolve(event)) end

    opts
    |> adapters()
    |> do_log(tag, event_function, opts)
  end

  defp do_log(adapters, tag, event, opts) do
    Enum.each(adapters, fn {adapter, config} ->
      adapter.log(tag, event, Keyword.merge(config, opts))
    end)
  end

  defp base_data do
    :loggex
    |> Application.get_env(:base_data, %{})
    |> resolve()
  end

  @doc false
  @spec resolve(event) :: map
  def resolve(nil), do: %{}
  def resolve(event) when is_function(event), do: event.()
  def resolve(event) when is_map(event), do: event

  ### Adapters ###

  @spec adapters(Keyword.t()) :: [adapter]
  defp adapters(opts) do
    opts
    |> Keyword.get_lazy(:adapters, &configured_adapters/0)
    |> prepare_adapters
  end

  @spec configured_adapters :: [adapter]
  defp configured_adapters, do: Application.get_env(:loggex, :adapters, [])

  @doc false
  @spec prepare_adapters(adapter | [adapter] | nil) :: [adapter]
  def prepare_adapters(nil), do: nil

  def prepare_adapters(adapters) do
    adapters
    |> listify()
    |> Enum.map(&prepare_adapter/1)
  end

  defp prepare_adapter(adapter) when is_tuple(adapter), do: adapter
  defp prepare_adapter(adapter), do: {adapter, []}

  defp listify(items) when is_list(items), do: items
  defp listify(item), do: [item]
end
