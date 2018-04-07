defmodule Loggex.Adapters.Logstash do
  @behaviour Loggex.Adapter

  @impl Loggex.Adapter
  def log(_tag, _event, _opts) do
    raise "Not Implemented"
  end
end
