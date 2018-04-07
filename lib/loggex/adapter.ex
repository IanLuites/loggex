defmodule Loggex.Adapter do
  @callback log(tag :: Loggex.tag(), event :: (() -> map), opts :: Keyword.t()) ::
              :ok | {:error, atom}
end
