defmodule Loggex.Adapters.Webhook do
  @behaviour Loggex.Adapter

  @impl Loggex.Adapter
  def log(tag, event, opts) do
    data = %{tag: tag, payload: event.()}

    with {:ok, %{status: 200}} <- HTTPX.post(opts[:url], {:json, data}) do
      :ok
    else
      error = {:error, _} -> error
      _ -> {:error, :fluentd_error}
    end
  end
end
