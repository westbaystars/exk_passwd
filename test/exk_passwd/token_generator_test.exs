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

  test "generate a word between 5 and 7 letters" do
  end

  test "generate a single digit number" do
  end

  test "generate a five digit number" do
  end

  test "verify that one of the passed symbols is returned" do
  end

  test "verify that one of the passed symbols is returned 3 times" do
  end
end
