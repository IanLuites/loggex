defmodule Loggex.Adapters.Fluentd do
  @behaviour Loggex.Adapter

  @impl Loggex.Adapter
  def log(tag, event, opts) do
    case URI.parse(opts[:url]) do
      uri = %{scheme: "http"} -> http_input(uri, tag, event.())
      uri = %{scheme: "https"} -> http_input(uri, tag, event.())
      uri = %{scheme: "tcp"} -> tcp_input(uri, tag, event.())
    end
  end

  defp http_input(uri, tag, data) do
    url = uri |> URI.merge(tag_to_string(tag)) |> to_string()

    with {:ok, %{status: 200}} <- HTTPX.post(url, {:json, data}) do
      :ok
    else
      error = {:error, _} -> error
      _ -> {:error, :fluentd_error}
    end
  end

  @tcp_options [:binary, {:packet, 0}, {:active, false}]
  defp tcp_input(uri, tag, data) do
    with {:ok, socket} <- :gen_tcp.connect(String.to_charlist(uri.host), uri.port, @tcp_options) do
      :inet.setopts(socket, [{:active, :once}])
      :gen_tcp.send(socket, encode_msg(tag, data))
    end
  end

  defp encode_msg(tag, data) do
    {msec, sec, _} = :os.timestamp()
    package = [tag_to_string(tag), msec * 1_000_000 + sec, data]
    :msgpack.pack(package, [])
  end

  defp tag_to_string(tags) when is_list(tags) do
    tags
    |> Enum.map(&to_string/1)
    |> Enum.join(".")
  end

  defp tag_to_string(tag), do: tag_to_string([tag])
end
