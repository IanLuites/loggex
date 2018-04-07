use Mix.Config

config :logger, backends: [:console, Loggex.LoggerBackend]

config :loggex, adapters: [Loggex.Adapters.Test, Loggex.Adapters.Console]
