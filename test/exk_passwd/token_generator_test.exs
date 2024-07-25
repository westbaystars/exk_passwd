defmodule EXKPasswd.TokenGeneratorTest do
  use ExUnit.Case, async: true
  alias EXKPasswd.TokenGenerator

  doctest TokenGenerator

  test "generate a four letter word" do
    assert TokenGenerator.get_word(4) |> String.length() == 4
  end

  test "a -1 length word request should return an empty string" do
    assert TokenGenerator.get_word(-1) == ""
  end

  test "a request for a 15 character word request should return an empty string" do
    assert TokenGenerator.get_word(15) == ""
  end

  test "non-integer length should return an empty string" do
    assert TokenGenerator.get_word("invalid") == ""
  end

  test "generate a word between 5 and 7 letters" do
    length = TokenGenerator.get_word_between(5, 7) |> String.length()
    assert length >= 5 and length <= 7
  end

  test "generate 50 words between 5 and 7 letters and confirm we got at least one of each" do
    words = Enum.map(1..50, fn _ -> TokenGenerator.get_word_between(5, 7) end)
    assert Enum.count(words) == 50
    assert Enum.any?(words, fn word -> String.length(word) == 5 end)
    assert Enum.any?(words, fn word -> String.length(word) == 6 end)
    assert Enum.any?(words, fn word -> String.length(word) == 7 end)
  end

  test "generate 50 words between 4 and 8 letters, calling `get_word_between` in reverse order, and confirm we got at least one of each" do
    words = Enum.map(1..50, fn _ -> TokenGenerator.get_word_between(8, 4) end)
    assert Enum.count(words) == 50
    assert Enum.any?(words, fn word -> String.length(word) == 4 end)
    assert Enum.any?(words, fn word -> String.length(word) == 5 end)
    assert Enum.any?(words, fn word -> String.length(word) == 6 end)
    assert Enum.any?(words, fn word -> String.length(word) == 7 end)
    assert Enum.any?(words, fn word -> String.length(word) == 8 end)
  end

  test "generate 50 words between 8 and 8 letters (same value on both ends of the range) and verify that all words returned are 8 characters long" do
    words = Enum.map(1..50, fn _ -> TokenGenerator.get_word_between(8, 8) end)
    assert Enum.count(words) == 50
    assert Enum.all?(words, fn word -> String.length(word) == 8 end)
  end

  test "there should be no words between -10 and 3 characters or between 12 and 100 characters long" do
    assert TokenGenerator.get_word_between(-10, 3) == ""
    assert TokenGenerator.get_word_between(12, 100) == ""
  end

  test "should get empty string when one or both parameters are non-integers" do
    assert TokenGenerator.get_word_between("a", 8) == ""
    assert TokenGenerator.get_word_between(8, "b") == ""
    assert TokenGenerator.get_word_between("a", "b") == ""
    assert TokenGenerator.get_word_between("b", "a") == ""
    assert TokenGenerator.get_word_between(3.0, 5.9) == ""
  end

  test "generate a single digit number" do
    number = TokenGenerator.get_number(1)
    assert String.length(number) == 1
    assert String.to_integer(number) < 10

    assert TokenGenerator.get_number("1") == ""
    assert TokenGenerator.get_number(-1) == ""
  end

  test "generate 50 five digit numbers" do
    nums = Enum.map(1..50, fn _ -> TokenGenerator.get_number(5) end)
    assert Enum.count(nums) == 50
    assert Enum.any?(nums, fn num -> String.at(num, 0) == "0" end)
    assert Enum.all?(nums, fn num -> String.to_integer(num) <= 99999 end)
  end

  test "verify that one of the passed symbols is returned" do
    symbols = ~w(! @ $ % ^ & * - _ + = \: | ~ ? / . \;)
    symbol = TokenGenerator.get_one_of(symbols)
    assert Enum.any?(symbols, fn sym -> sym == symbol end)
  end

  test "verify that one of the passed symbols is returned 3 times" do
    symbols = ~w(! @ $ % ^ & * - _ + = \: | ~ ? / . \;)
    padding = TokenGenerator.get_n_of(symbols, 3)
    assert String.length(padding) == 3
    assert String.at(padding, 0) == String.at(padding, 1)
    assert String.at(padding, 1) == String.at(padding, 2)
  end
end
