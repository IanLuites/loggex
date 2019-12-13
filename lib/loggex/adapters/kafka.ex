defmodule Loggex.Adapters.Kafka do
  @moduledoc ~S"""
  Log events to Kafka.
  """
  @behaviour Loggex.Adapter

  @impl Loggex.Adapter
  def log(_tag, _event, _opts) do
    raise "Not Implemented"
  end
end
