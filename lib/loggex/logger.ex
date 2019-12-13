defmodule Loggex.Logger do
  @moduledoc ~S"""
  A logger.
  """
  alias Loggex.Logger

  @doc ~S"Dynamically configure module."
  @callback configure(opts :: Keyword.t()) :: Keyword.t()

  @doc @moduledoc
  defmacro __using__(opts \\ []) do
    otp_app = opts[:otp_app]
    adapters = Loggex.prepare_adapters(opts[:adapters])
    base_options = [base_data: opts[:base_data], adapters: adapters, src: __CALLER__.module]
    logger = create_logger(opts)

    quote do
      @behaviour unquote(__MODULE__)
      unquote(logger)

      ### Hidden Configs ###

      @doc false
      @spec configure(Keyword.t()) :: Keyword.t()
      @impl unquote(__MODULE__)
      def configure(opts), do: opts

      @doc false
      @spec __base_options__ :: Keyword.t()
      def __base_options__ do
        unquote(base_options)
        |> Keyword.merge(Application.get_env(unquote(otp_app), __MODULE__, []))
        |> configure()
      end

      defoverridable configure: 1
    end
  end

  @doc false
  @spec log!(module, Loggex.tag(), Loggex.event(), Keyword.t()) :: :ok
  def log!(module, tag, event, opts) do
    Loggex.log!(
      tag,
      fn ->
        Map.merge(
          Loggex.resolve(opts[:base_data]),
          Loggex.resolve(event)
        )
      end,
      Keyword.merge(module.__base_options__, opts)
    )
  end

  @spec create_logger(Keyword.t()) :: term
  defp create_logger(opts) do
    if tag = opts[:tag] do
      quote do
        @doc ~S"""
        Log event.

        ## Examples

        ```elixir
        iex> log!(%{ip: "83.12.209.46"}
        ```
        """
        @spec log!(Loggex.event(), Keyword.t()) :: :ok
        def log!(event, opts \\ []), do: Logger.log!(__MODULE__, unquote(tag), event, opts)
      end
    else
      quote do
        @doc ~S"""
        Log event under tag.

        ## Examples

        ```elixir
        iex> log!(:logins, %{ip: "83.12.209.46"}
        ```
        """
        @spec log!(Loggex.tag(), Loggex.event(), Keyword.t()) :: :ok
        def log!(tag, event, opts \\ []), do: Logger.log!(__MODULE__, tag, event, opts)
      end
    end
  end
end
