defmodule Loggex.Adapters.Console do
  @behaviour Loggex.Adapter

  @color IO.ANSI.yellow()
  @delimiter "-"
  @syntax_colors [
    string: :green,
    map: :blue,
    boolean: :magenta,
    number: :yellow,
    atom: :cyan,
    reset: :cyan
  ]
  @inspect_opts pretty: true, syntax_colors: @syntax_colors

  @impl Loggex.Adapter
  def log(tag, event, _opts) do
    event_data = event.()

    delimiter = delimiter(tag, event_data)

    IO.ANSI.yellow()
    IO.puts(@color <> delimiter)
    IO.puts("Tag: #{IO.ANSI.white()}#{tag}#{@color}")
    IO.puts(delimiter)
    IO.puts(inspect(event_data, @inspect_opts))
    IO.puts(@color <> delimiter)
  end

  @spec delimiter(Loggex.tag(), map) :: String.t()
  defp delimiter(tag, event_data) do
    length =
      "Tag: #{tag}"
      |> Kernel.<>("\n" <> inspect(event_data, pretty: true))
      |> max_length()

    String.duplicate(@delimiter, length + 1)
  end

  @spec max_length(String.t()) :: non_neg_integer
  defp max_length(text) do
    text
    |> String.split("\n")
    |> Enum.map(&String.length/1)
    |> Enum.max()
  end
end
