defmodule Loggex do
  @moduledoc """
  Documentation for Loggex.
  """

  @type tag :: String.t() | atom
  @type event :: map | (() -> map)
  @type adapter :: atom | {atom, Keyword.t()}

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

  defp adapters(opts) do
    opts
    |> Keyword.get_lazy(:adapters, &configured_adapters/0)
    |> prepare_adapters
  end

  defp configured_adapters, do: Application.get_env(:loggex, :adapters, [])

  @doc false
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
