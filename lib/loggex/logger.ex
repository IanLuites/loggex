defmodule Loggex.Logger do
  alias Loggex.Logger

  defmacro __using__(opts \\ []) do
    otp_app = opts[:otp_app] || raise "Need to set `otp_app`."
    adapters = Loggex.prepare_adapters(opts[:adapters])
    base_options = [base_data: opts[:base_data], adapters: adapters, src: __CALLER__.module]
    logger = create_logger(opts)

    quote do
      unquote(logger)

      ### Hidden Configs ###

      @doc false
      @spec __base_options__ :: Keyword.t()
      def __base_options__ do
        Keyword.merge(
          Application.get_env(unquote(otp_app), __MODULE__, []),
          unquote(base_options)
        )
      end
    end
  end

  @doc false
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
        def log!(event, opts \\ []), do: Logger.log!(__MODULE__, unquote(tag), event, opts)
      end
    else
      quote do
        def log!(tag, event, opts \\ []), do: Logger.log!(__MODULE__, tag, event, opts)
      end
    end
  end
end
