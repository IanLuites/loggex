defmodule Loggex.LoggerBackend do
  @moduledoc ~S"""
  Hook to pickup events from logger backend.
  """
  @meta ~w(pid file line module function application)a
  @behaviour :gen_event

  @impl :gen_event
  def init(__MODULE__) do
    {:ok, :no_state}
  end

  @impl :gen_event
  def handle_event(:flush, state), do: {:ok, state}

  def handle_event(error = {_, _, {Logger, _, _, _}}, state) do
    report_error_event(error)

    {:ok, state}
  end

  @impl :gen_event
  def handle_call(_msg, state), do: {:ok, :ok, state}
  @impl :gen_event
  def handle_info(_msg, state), do: {:ok, state}

  @doc false
  @spec report_error_event(tuple) :: :ok
  def report_error_event({level, group_leader, {Logger, message, timestamp, metadata}}) do
    meta =
      metadata
      |> Enum.reject(fn {k, _} -> k in @meta end)
      |> Enum.into(%{})

    Loggex.log!("logger", %{
      level: level,
      message: IO.iodata_to_binary(message),
      trace: trace(metadata, group_leader),
      timestamp: format_timestamp(timestamp),
      metadata: meta
    })
  rescue
    _ -> :ok
  end

  defp trace(metadata, group_leader) do
    %{
      group_leader: inspect(group_leader),
      pid: inspect(metadata[:pid]),
      file: metadata[:file],
      line: metadata[:line],
      module: metadata[:module],
      function: metadata[:function],
      application: metadata[:application]
    }
  end

  defp format_timestamp({{y, m, d}, {h, mi, s, _ms}}) do
    %DateTime{
      year: y,
      month: m,
      day: d,
      hour: h,
      minute: mi,
      second: s,
      std_offset: 0,
      time_zone: "Etc/UTC",
      utc_offset: 0,
      zone_abbr: "UTC"
    }
  end
end
