# Implementing the Primary Purpose

The main purpose of the XKPasswd application is to generate a number of words (with numbers and symbols) at random to serve as memorable passwords. So for the first module to test and build, let's make it the token generator. A token can be a word (from a dictionary of words) of a specified length range, a zero-padded number of given number of digits, or a symbol for padding between words and/or at the head and tail of the overall generated password.

## The Token Generator Tests

The description of the "problem to be solved" above does a good job of telling us what we need to test. The token generator needs to produce several things that add up to make the generated password.

1. test that a four letter word is generated
2. test that a word between 5 and 7 letters is generated
3. test that a single digit number is generated
4. test that a five digit number is generated
5. test that one of the passed symbols is returned
6. test that one of the passed symbols is returned _n_ number of times

Once all of those are working, we should be able to smash them together to create a memorable password.

Under `/test/exk_passwd`, let's create `token_generator_test.exs`:

```elixir
defmodule EXKPasswd.TokenGeneratorTest do
  use ExUnit.Case, async: true
  alias EXKPasswd.TokenGenerator

  doctest TokenGenerator

  test "generate a four letter word" do
    assert TokenGenerator.get_word(4) |> String.length() == 4
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
```

And running `mix test` will result in a compile error because we haven't yet created `EXKPasswd.TokenGenerator`. So we need to do that before going any further.

Under `/lib/exk_passwd`, create `TokenGenerator` like so:

```elixir
defmodule EXKPasswd.TokenGenerator do
  @moduledoc """
  Provides core functionality for generating random tokens (words, numbers,
  symbols) to be put together to make easy to remember, complex passwords.

  The list of English words is taken from the [Official Javascript Port of
  XKPasswd](https://github.com/bartificer/xkpasswd-js/blob/main/src/lib/dictionaryEN.mjs).

  I considered getting the words from a database. But that would be overkill
  for what is essentially a list of words. I may find that a map of word
  lengths to arrays of words works better in the future. But for now, this
  should work.
  """

  # This is a subset of the words to get the idea
  @words ~w( Africa Alabama Alaska America Amsterdam April Arizona Asia Athens
    August Australia Austria Barbados Belfast Belgium Berlin Botswana Brazil
    Britain British Bulgaria California Canada Chile China Colombia Congo
    said sail salt same sand save says scale scene school science scientists
    score season seat second section seed seeds seem seen self sell send
    sense sent sentence separate serve service settle settled seven several
  )

  @doc """
  Select a word at random based on the specified length of the word.

  ## Examples

    iex> TokenGenerator.get_word(4)

  """
  def get_word(length) do
    @words
    |> Enum.filter(fn w -> String.length(w) == length end)
    |> Enum.random()
  end
end
```

Okay, with `EXKPasswd.TokenGenerator.get_word(length)` now implemted, let's run the test.

```sh
mix test test/exk_passwd/token_generator_test.exs
Running ExUnit with seed: 172336, max_cases: 24

....
Finished in 0.01 seconds (0.01s async, 0.00s sync)
1 doctest, 6 tests, 0 failures
```

The test passes. Running it a few more times, to make sure that the first time wasn't a fluke, and we get the same result. Excellent.

Now, just because I can't see the word that was returned, let's open an `iex` session and verify it.

```sh
exk_passwd % iex -S mix
Erlang/OTP 27 [erts-15.0.1] [source] [64-bit] [smp:12:12] [ds:12:12:10] [async-threads:1] [jit]

Compiling 1 file (.ex)
Generated exk_passwd app
Interactive Elixir (1.17.2) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> EXKPasswd.TokenGenerator.get_word(4)
"save"
iex(2)> EXKPasswd.TokenGenerator.get_word(9)
"Australia"
```

Nice. It does work.

### Edge Cases

Before moving on to the range test, what other edge cases can we test for? What should be get when we ask for a `-1` length word? I think it should return `""`. Let's see what happens.

```elixir
test "a -1 length word request should return an empty string" do
  assert TokenGenerator.get_word(-1) == ""
end
```

And let's run the tests.

```sh
mix test test/exk_passwd/token_generator_test.exs
Running ExUnit with seed: 645639, max_cases: 24

...

  1) test a -1 length word request should return an empty string (EXKPasswd.TokenGeneratorTest)
     test/exk_passwd/token_generator_test.exs:11
     ** (Enum.EmptyError) empty error
     code: assert TokenGenerator.get_word(-1) == ""
     stacktrace:
       (elixir 1.17.2) lib/enum.ex:2398: Enum.random/1
       test/exk_passwd/token_generator_test.exs:12: (test)

....
Finished in 0.01 seconds (0.01s async, 0.00s sync)
```

Well, that didn't work. Looks like it blew up in `Enum.random` with an `Enum.EmptyError` exception. That would be because the previous `Enum.filter` would have returned an empty sequence to pass to `Enum.random`, which didn't like that.

Looks like we need a way to handle the case when the there are no words after the filter stage. So let's create a private `random` function that takes an array of words and simply passes them to the `Enum.random` function if there are elements in the array or returns an empty string when the array is empty.

```elixir
def get_word(length) do
  @words
  |> Enum.filter(fn w -> String.length(w) == length end)
  |> random()
end

defp random([]), do: ""

defp random(array) do
  Enum.random(array)
end
```

Run the tests once more:

```sh
mix test test/exk_passwd/token_generator_test.exs
Compiling 1 file (.ex)
Running ExUnit with seed: 733383, max_cases: 24

........
Finished in 0.00 seconds (0.00s async, 0.00s sync)
1 doctest, 7 tests, 0 failures
```

And we're all green.

Another edge case would be a 15 letter word. I'm pretty sure there weren't any in the list. Let's check.

```elixir
test "a request for a 15 character word request should return an empty string" do
  assert TokenGenerator.get_word(15) == ""
end
```

And run the tests:

```sh
mix test test/exk_passwd/token_generator_test.exs
Running ExUnit with seed: 46859, max_cases: 24

.........
Finished in 0.01 seconds (0.01s async, 0.00s sync)
1 doctest, 8 tests, 0 failures
```

All green. All good.

### Non Integer Values

There is another potential edge case that we should test for: non-integer values for the length of the string. In the end, we will be accepting user input. While it should be sanitized before reaching this layer, it would make me feel better knowing that it can't do harm if it does get through.

```elixir
test "non-integer length should return an empty string" do
  assert TokenGenerator.get_word("invalid") == ""
end
```

And if we run it:

```sh
mix test test/exk_passwd/token_generator_test.exs
Running ExUnit with seed: 118530, max_cases: 24

..........
Finished in 0.01 seconds (0.01s async, 0.00s sync)
1 doctest, 9 tests, 0 failures
```

It worked! Why did it work? I was expecting it to fail. Let's start up a new `iex -S mix` shell and see what we've got.

```sh
iex(1)> EXKPasswd.TokenGenerator.get_word("invalid")
""
iex(2)> ~w(this is a test) |> Enum.filter(fn w -> String.length(w) == "invalid" end)
[]
```

We are getting the empty string as I wanted. So a quick check of our filter comparing the result of `String.length(w)` with `"invalid"`, and that comparison is always `false`. Therefore, the filter results in an empty array. The empty array passed to our private `random` function always returns a blank string.

So that's why it worked! Excellent. Another passed edge case.x
