defmodule MyUtilsTest do
  use ExUnit.Case, async: true

  test "wc" do
    {file_1_ms, file_1_words_amount} = :timer.tc(fn -> MyUtils.wc('test/fixtures/file1.txt') end)
    IO.inspect(file_1_ms / 1000, label: "file1.txt / concurrently (ms)")
    assert file_1_words_amount == {4, 8, 16}

    {file_2_ms, file_2_words_amount} = :timer.tc(fn -> MyUtils.wc('test/fixtures/file2.txt') end)
    IO.inspect(file_2_ms / 1000, label: "file2.txt / concurrently (ms)")
    assert file_2_words_amount == {26, 26000, 52026}

    {file_3_ms, file_3_words_amount} = :timer.tc(fn -> MyUtils.wc('test/fixtures/file3.txt') end)
    IO.inspect(file_3_ms / 1000, label: "file3.txt / concurrently (ms)")
    assert file_3_words_amount == {26, 26000000, 52000026}
  end

  test "wc_no_concurrency" do
    {file_1_ms, file_1_words_amount} = :timer.tc(fn -> MyUtils.wc_no_concurrent('test/fixtures/file1.txt') end)
    IO.inspect(file_1_ms / 1000, label: "file1.txt / no_concurrency (ms)")
    assert file_1_words_amount == {4, 8, 16}

    {file_2_ms, file_2_words_amount} = :timer.tc(fn -> MyUtils.wc_no_concurrent('test/fixtures/file2.txt') end)
    IO.inspect(file_2_ms / 1000, label: "file2.txt / no_concurrency (ms)")
    assert file_2_words_amount == {26, 26000, 52026}

    {file_3_ms, file_3_words_amount} = :timer.tc(fn -> MyUtils.wc_no_concurrent('test/fixtures/file3.txt') end)
    IO.inspect(file_3_ms / 1000, label: "file3.txt / no_concurrency (ms)")
    assert file_3_words_amount == {26, 26000000, 52000026}
  end

end
