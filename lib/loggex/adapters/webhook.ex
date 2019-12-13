defmodule Loggex.Adapters.Webhook do
  @moduledoc ~S"""
  Log events to any given webhook.
  """
  @behaviour Loggex.Adapter

  @impl Loggex.Adapter
  def log(tag, event, opts) do
    data = %{tag: tag, payload: event.()}

    case HTTPX.post(opts[:url], {:json, data}) do
      {:ok, %{status: 200}} -> :ok
      error = {:error, _} -> error
      _ -> {:error, :fluentd_error}
    end
  end
end
