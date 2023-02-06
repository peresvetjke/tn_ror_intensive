defmodule MyUtils do
  @type stats :: {lines_count :: non_neg_integer, char_count :: non_neg_integer, byte_count :: non_neg_integer}

  @spec wc_no_concurrent(String.t()) :: stats()
  def wc_no_concurrent(path) do
    path
    |> File.stream!()
    |> Enum.map(& {1, count_words(&1), byte_size(&1)})
    |> Enum.reduce({0, 0, 0}, fn line, acc -> sum_stats(line, acc) end)
  end

  @spec wc(String.t()) :: stats()
  def wc(path) do
    path
    |> File.stream!()
    |> Flow.from_enumerable()
    |> Flow.partition()
    |> Flow.flat_map(& [{1, count_words(&1), byte_size(&1)}])
    |> Enum.reduce({0, 0, 0}, fn line, acc -> sum_stats(line, acc) end)
  end

  @spec count_words(String.t()) :: non_neg_integer
  defp count_words(string) do
    string
    |> String.trim()
    |> String.split(" ")
    |> length
  end

  @spec sum_stats(stats, stats) :: stats
  defp sum_stats({x1, y1, z1}, {x2, y2, z2}) do
    {x1 + x2, y1 + y2, z1 + z2}
  end
end
