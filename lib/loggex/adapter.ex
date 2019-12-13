defmodule Loggex.Adapter do
  @moduledoc ~S"""
  Adapter to implement for logging.
  """

  @doc ~S"Log an event under a given tag"
  @callback log(tag :: Loggex.tag(), event :: (() -> map), opts :: Keyword.t()) ::
              :ok | {:error, atom}
end
