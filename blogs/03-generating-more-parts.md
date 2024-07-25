# Generating More Parts

We've got the primary word generator complete. Now let's continue with the other five segments that need to be generated.

## The Token Generator Tests

The description of the "problem to be solved" above does a good job of telling us what we need to test. The token generator needs to produce several things that add up to make the generated password.

1. ~~test that a four letter word is generated~~
2. test that a word between 5 and 7 letters is generated
3. test that a single digit number is generated
4. test that a five digit number is generated
5. test that one of the passed symbols is returned
6. test that one of the passed symbols is returned _n_ number of times

Continuing with  `token_generator_test.exs`, let's make a test to make sure that the words generated are between 5 and 7 letters long.

```elixir
  test "generate a word between 5 and 7 letters" do
    length = TokenGenerator.get_word_between(5, 7) |> String.length()
    assert length >= 5 and length <= 7
  end
```

And running `mix test test/exk_passwd/token_generator_test.exs` will result in a compile error because we haven't yet created `EXKPasswd.TokenGenerator`. So we need to do that before going any further.

```elixir
  @doc """
  Select a word at random with the length >= to the first value and
  <= to the last value (inclusive).

  ## Examples

    iex> TokenGenerator.get_word_between(5, 7)

  """
  def get_word_between(last, first) when last > first, do: get_word_between(first, last)
  def get_word_between(length, length) when length == length, do: get_word(length)

  def get_word_between(first, last) do
    @words
    |> Enum.filter(fn w ->
      len = String.length(w)
      len >= first and len <= last
    end)
    |> random()
  end
```

Okay, with `EXKPasswd.TokenGenerator.get_word_between(first, last)` now implemted, let's run the test again.

```sh
mix test test/exk_passwd/token_generator_test.exs
Compiling 1 file (.ex)
Running ExUnit with seed: 410245, max_cases: 24

...........
Finished in 0.01 seconds (0.01s async, 0.00s sync)
2 doctests, 9 tests, 0 failures
```

Great! In the green again. But how do we know that words of 5, 6, and 7 characters in length are being generated? Well, let's generate 50 words and verify that at least one word of each size is in that list.

```sh
  test "generate 50 words between 5 and 7 letters and confirm we got at least one of each" do
    words = Enum.map(1..50, fn _ -> TokenGenerator.get_word_between(5, 7) end)
    assert Enum.count(words) == 50
    assert Enum.any?(words, fn word -> String.length(word) == 5 end)
    assert Enum.any?(words, fn word -> String.length(word) == 6 end)
    assert Enum.any?(words, fn word -> String.length(word) == 7 end)
  end
```

Run the test:

```sh
mix test test/exk_passwd/token_generator_test.exs
Running ExUnit with seed: 174464, max_cases: 24

............
Finished in 0.02 seconds (0.02s async, 0.00s sync)
2 doctests, 10 tests, 0 failures
```

Nice. that seems to work.

### Edge Cases

I think that I took care of all of the possible normal edge cases with the pattern matching of `(last, first)` order of values and both values being the same, i.e. `(length, length)`. Let's test the first case, when we specify the range from 8 to 4.

```elixir
  test "generate 50 words between 4 and 8 letters, calling `get_word_between` in reverse order, and confirm we got at least one of each" do
    words = Enum.map(1..50, fn _ -> TokenGenerator.get_word_between(8, 4) end)
    assert Enum.count(words) == 50
    assert Enum.any?(words, fn word -> String.length(word) == 4 end)
    assert Enum.any?(words, fn word -> String.length(word) == 5 end)
    assert Enum.any?(words, fn word -> String.length(word) == 6 end)
    assert Enum.any?(words, fn word -> String.length(word) == 7 end)
    assert Enum.any?(words, fn word -> String.length(word) == 8 end)
  end
```

And let's run the tests.

```sh
mix test test/exk_passwd/token_generator_test.exs
Running ExUnit with seed: 900370, max_cases: 24

.............
Finished in 0.03 seconds (0.03s async, 0.00s sync)
2 doctests, 11 tests, 0 failures
```

That worked. But with so many possiblities, there is a chance that in 50 tries there might be a time when it doesn't pass. Running it 10 times, though, doesn't produce a failure. So we seem to have a good distribution.

Now lets test it when the first and last values are equal.

```elixir
  test "generate 50 words between 8 and 8 letters (same value on both ends of the range) and verify that all words returned are 8 characters long" do
    words = Enum.map(1..50, fn _ -> TokenGenerator.get_word_between(8, 8) end)
    assert Enum.count(words) == 50
    assert Enum.all?(words, fn word -> String.length(word) == 8 end)
  end
```

Run the tests once more:

```sh
mix test test/exk_passwd/token_generator_test.exs
Running ExUnit with seed: 81109, max_cases: 24

..............
Finished in 0.04 seconds (0.04s async, 0.00s sync)
2 doctests, 12 tests, 0 failures
```

And we're all green.

Another edge case would be checking for words 3 characters or less. There should be none. And that goes for words with 12 characters or more as well.

```elixir
  test "there should be no words between -10 and 3 characters or between 12 and 100 characters long" do
    assert TokenGenerator.get_word_between(-10, 3) == ""
    assert TokenGenerator.get_word_between(12, 100) == ""
  end
```

And run the tests:

```sh
mix test test/exk_passwd/token_generator_test.exs
Compiling 1 file (.ex)
Running ExUnit with seed: 105867, max_cases: 24

...............
Finished in 0.04 seconds (0.04s async, 0.00s sync)
2 doctests, 13 tests, 0 failures
```

And that worked!

### Non Integer Values

Do we still get an empty string if either or both of the parameters are non-integers?

```elixir
  test "should get empty string when one or both parameters are non-integers" do
    assert TokenGenerator.get_word_between("a", 8) == ""
    assert TokenGenerator.get_word_between(8, "b") == ""
    assert TokenGenerator.get_word_between("a", "b") == ""
    assert TokenGenerator.get_word_between("b", "a") == ""
    assert TokenGenerator.get_word_between(3.0, 5.9) == ""
  end
```

And if we run it:

```sh
westbay@velvet exk_passwd % mix test test/exk_passwd/token_generator_test.exs
Running ExUnit with seed: 606060, max_cases: 24

..

  1) test should get empty string when one or both parameters are non-integers (EXKPasswd.TokenGeneratorTest)
     test/exk_passwd/token_generator_test.exs:57
     Assertion with == failed
     code:  assert TokenGenerator.get_word_between("a", 8) == ""
     left:  "substances"
     right: ""
     stacktrace:
       test/exk_passwd/token_generator_test.exs:58: (test)

.............
Finished in 0.05 seconds (0.05s async, 0.00s sync)
2 doctests, 14 tests, 1 failure
```

Nope. We need to set up some guards.

```elixir
  def get_word_between(first, last) when is_integer(first) and is_integer(last) do
    @words
    |> Enum.filter(fn w ->
      len = String.length(w)
      len >= first and len <= last
    end)
    |> random()
  end

  def get_word_between(_first, _last), do: ""
```

And the test:

```sh
westbay@velvet exk_passwd % mix test test/exk_passwd/token_generator_test.exs
Running ExUnit with seed: 758153, max_cases: 24

................
Finished in 0.04 seconds (0.04s async, 0.00s sync)
2 doctests, 14 tests, 0 failures
```

That works! We've now got a reliable way to get random words from 4 to 11 characters in length from the word list.

## Get a Random Single Digit Number

Testing the generation of a single digit number should produce a string of a single digit whos integer value is less than 10.

```elixir
  test "generate a single digit number" do
    number = TokenGenerator.get_number(1)
    assert String.length(number) == 1
    assert String.to_integer(number) < 10
  end
```

And let's go ahead an implement the function rather than watch if fail to compile.

```elixir
  @doc """
  Get a 0 padded integer with a given number of digits. This gets returned as an integer.

  ## Examples

    iex> TokenGenerator.get_number(2)

  """
  def get_number(digits) do
    0..(10 ** digits - 1)
    |> random()
    |> Integer.to_string()
    |> String.pad_leading(digits, "0")
  end
```

Running the test:

```sh
westbay@velvet exk_passwd % mix test test/exk_passwd/token_generator_test.exs
Compiling 1 file (.ex)
Running ExUnit with seed: 948599, max_cases: 24

.................
Finished in 0.04 seconds (0.04s async, 0.00s sync)
3 doctests, 14 tests, 0 failures
```

It worked! So let's try to break it.

In the same test, add:

```elixir
  assert TokenGenerator.get_number("1") == ""
```

As expected, this fails:

```sh
mix test test/exk_passwd/token_generator_test.exs
Running ExUnit with seed: 523104, max_cases: 24

.............

  1) test generate a single digit number (EXKPasswd.TokenGeneratorTest)
     test/exk_passwd/token_generator_test.exs:65
     ** (FunctionClauseError) no function clause matching in Kernel.**/2

     The following arguments were given to Kernel.**/2:

         # 1
         10

         # 2
         "1"

     Attempted function clauses (showing 2 out of 2):

         def **(base, exponent) when is_integer(base) and is_integer(exponent) and exponent >= 0
         def **(base, exponent) when is_number(base) and is_number(exponent)

     code: assert TokenGenerator.get_number("1") == ""
     stacktrace:
       (elixir 1.17.2) lib/kernel.ex:4443: Kernel.**/2
       (exk_passwd 0.1.0) lib/exk_passwd/token_generator.ex:176: EXKPasswd.TokenGenerator.get_number/1
       test/exk_passwd/token_generator_test.exs:70: (test)

...
Finished in 0.05 seconds (0.05s async, 0.00s sync)
3 doctests, 14 tests, 1 failure
```

So let's add a guard to only accept integers.

```elixir
  def get_number(digits) when is_integer(digits) do
    0..(10 ** digits - 1)
    |> random()
    |> Integer.to_string()
    |> String.pad_leading(digits, "0")
  end

  def get_number(_), do: ""
```

We're green with that.

What about negative numbers?

```elixir
assert TokenGenerator.get_number(-1) == ""
```

Run the tests:

```sh
mix test test/exk_passwd/token_generator_test.exs
Running ExUnit with seed: 803468, max_cases: 24

.

  1) test generate a single digit number (EXKPasswd.TokenGeneratorTest)
     test/exk_passwd/token_generator_test.exs:65
     ** (ArgumentError) ranges (first..last) expect both sides to be integers, got: 0..-0.9
     code: assert TokenGenerator.get_number(-1) == ""
     stacktrace:
       (elixir 1.17.2) lib/range.ex:193: Range.new/2
       (exk_passwd 0.1.0) lib/exk_passwd/token_generator.ex:176: EXKPasswd.TokenGenerator.get_number/1
       test/exk_passwd/token_generator_test.exs:71: (test)

..............

  2) test generate 50 words between 4 and 8 letters, calling `get_word_between` in reverse order, and confirm we got at least one of each (EXKPasswd.TokenGeneratorTest)
     test/exk_passwd/token_generator_test.exs:36
     Expected truthy, got false
     code: assert Enum.any?(words, fn word -> String.length(word) == 8 end)
     arguments:

         # 1
         ["below", "join", "wind", "women", "here", "nice", "picture", "office", "plain", "swim", "told", "burning", "laughed", "back", "Dublin", "loss", "number", "could", "someone", "three", "Oslo", "welcome", "filled", "such", "size", "Poland", "arms", "minutes", "subject",
          "brother", "went", "edge", "heard", "person", "August", "Jupiter", "wild", "plan", "view", "score", "arrived", "metal", "carry", "chance", "park", "sail", "voice", "April", "blow", "company"]

         # 2
         #Function<5.4296232/1 in EXKPasswd.TokenGeneratorTest."test generate 50 words between 4 and 8 letters, calling `get_word_between` in reverse order, and confirm we got at least one of each"/1>

     stacktrace:
       test/exk_passwd/token_generator_test.exs:43: (test)


Finished in 0.05 seconds (0.05s async, 0.00s sync)
3 doctests, 14 tests, 2 failures
```
Oh, that's bad. The range from `0 to -0.9` doesn't work. So let's make make sure that the length is 1 or greater.

```elixir
  def get_number(digits) when is_integer(digits) and digits >= 1 do
    0..(10 ** digits - 1)
    |> random()
    |> Integer.to_string()
    |> String.pad_leading(digits, "0")
  end
```

And that fixes it:

```sh
mix test test/exk_passwd/token_generator_test.exs
Compiling 1 file (.ex)
Running ExUnit with seed: 562519, max_cases: 24

.................
Finished in 0.04 seconds (0.04s async, 0.00s sync)
3 doctests, 14 tests, 0 failures
```

Okay, let's move on to five digit numbers. And, surely, generating 50 of them should result in at least one of them having a "0" at the front of the string, right?

```elixir
  test "generate 50 five digit numbers" do
    nums = Enum.map(1..50, fn _ -> TokenGenerator.get_number(5) end)
    assert Enum.count(nums) == 50
    assert Enum.any?(nums, fn num -> String.at(num, 0) == "0" end)
    assert Enum.all?(nums, fn num -> String.to_integer(num) <= 99999 end)
  end
```

And it passes.

### Get random symbol

That just leaves getting a random symbol.

```elixir
  test "verify that one of the passed symbols is returned" do
    symbols = ~w(! @ $ % ^ & * - _ + = : | ~ ? / . ;)
    symbol = TokenGenerator.get_one_of(symbols)
    assert Enum.any?(symbols, fn sym -> sym == symbol end)
  end
```

And, again, let's implement before looking at a compile error.

```elixir
  @doc """
  Randomly select one of the elements in the range.

  ## Examples

    iex> TokenGenerator.get_one_of(~w(! " # $ % & ' ( ) + * : |))

  """
  def get_one_of(range), do: random(range)
```

We already have a private function that does this, `random(range)`. So this just passes on to it.

Let's test.

```sh
mix test test/exk_passwd/token_generator_test.exs
Running ExUnit with seed: 709497, max_cases: 24

.................
Finished in 0.05 seconds (0.05s async, 0.00s sync)
3 doctests, 14 tests, 0 failures
```

And it worked!

### Get a Random Symbol a Specified Number of Times

With that implemented, let's finally add a function that returns the random symbol a specified number of times for padding.

The test passes some symbols to the `get_n_of` function along with the number of times the symbol needs to be repeated. Let's do it 3 times. It then checks that the length of the returned string is 3 and that all three of the characters are the same.

```elixir
  test "verify that one of the passed symbols is returned 3 times" do
    symbols = ~w(! @ $ % ^ & * - _ + = \: | ~ ? / . \;)
    padding = TokenGenerator.get_n_of(symbols, 3)
    assert String.length(padding) == 3
    assert String.at(padding, 0) == String.at(padding, 1)
    assert String.at(padding, 1) == String.at(padding, 2)
  end
```

And let's implement that.

```elixir
  def get_n_of(range, count) when is_integer(count) and count > 0 do
    char = random(range)
    String.pad_leading(char, count, char)
  end

  def get_n_of(_range, _count), do: ""
```

I already know that I need to guard against non-integer input and that the count must be 1 or more.

A quick test:

```sh
mix test test/exk_passwd/token_generator_test.exs
Running ExUnit with seed: 795264, max_cases: 24

...................
Finished in 0.05 seconds (0.05s async, 0.00s sync)
5 doctests, 14 tests, 0 failures
```

And it works!

That finishes up with the token generator part of the project. We can now create the parts of a password, so we'll put them all together next.
