# Generate Passwords

In order to generate passwords with this tool, we're going to need to know settings for the various parts of the password. What are the parts?

* padding at the head and tail of the password
  * open symbol set to select from
  * use same symbol at head and tail
  * size at head and tail variable
* numerical digits at the start and end of the password
  * random values at start and end
  * size (digits) at start and end variable
* a symbol as a separator (may be different than padding symbols)
* the random words
  * size of words may be fixed or within a range
  * case transform may be `:none`, `:init_cap`, `:all_cap`, `:alternate` or `:random`

## The Password Settings Structure

With the above in mind, let's create the default test structure similar to the default setting preset in [xkpasswd-js/src/lib/presets.mjs](https://github.com/bartificer/xkpasswd-js/blob/main/src/lib/presets.mjs).

Under `/test/exk_passwd`, let's create `password_creator_test.exs`:

```elixir
defmodule EXKPasswd.PasswordCreatorTest do
  use ExUnit.Case, async: true
  alias EXKPasswd.PasswordCreator

  doctest PasswordCreator

  @default_settings %PasswordCreator{
    description:
      "The default preset resulting in a password consisting of " <>
        "3 random words of between 4 and 8 letters with alternating " <>
        "case separated by a random character, with two random digits " <>
        "before and after, and padded with two random characters front and back.",
    num_words: 3,
    word_length_min: 4,
    word_length_max: 8,
    case_transform: :alternate,
    separator_character: ~w(! @ $ % ^ & * - _ + = : | ~ ? / . ;),
    digits_before: 2,
    digits_after: 2,
    padding_character: ~w(! @ $ % ^ & * - _ + = : | ~ ? / . ;),
    padding_before: 2,
    padding_after: 2
  }

  @web32_settings %PasswordCreator{
    description: "A preset for websites that allow passwords up to 32 characters long.",
    num_words: 4,
    word_length_min: 4,
    word_length_max: 5,
    case_transform: :alternate,
    separator_character: ~w(- + = . * _ | ~),
    digits_before: 2,
    digits_after: 2,
    padding_character: ~w(! @ $ % ^ & * + = : | ~),
    padding_before: 1,
    padding_after: 1
  }

  @web16_settings %PasswordCreator{
    description:
      "A preset for websites that insist passwords not be longer " <>
        "than 16 characters. WARNING - only use this preset if you " <>
        "have to, it is too short to be acceptably secure and will " <>
        "always generate entropy warnings for the case where the " <>
        "config and dictionary are known.",
    num_words: 3,
    word_length_min: 4,
    word_length_max: 4,
    case_transform: :alternate,
    separator_character: ~w(! @ $ % ^ & * - _ + = : | ~ ? / .),
    digits_before: 0,
    digits_after: 2,
    padding_character: ""
  }

  @wifi_settings %PasswordCreator{
    description:
      "A preset for generating 63 character long WPA2 keys " <>
        "(most routers allow 64 characters, but some only 63, " <>
        "hence the odd length).",
    num_words: 6,
    word_length_min: 4,
    word_length_max: 8,
    case_transform: :alternate,
    separator_character: ~w(- + = . * _ | ~ ,),
    digits_before: 4,
    digits_after: 4,
    pad_to_length: 63,
    padding_character: ~w(! @ $ % ^ & * + = : | ~ ?)
  }

  @apple_id_settings %PasswordCreator{
    description:
      "A preset respecting the many prerequisites Apple places " <>
        "on Apple ID passwords. The preset also limits itself to " <>
        "symbols found on the iOS letter and number keyboards " <>
        "(i.e. not the awkward to reach symbol keyboard).",
    num_words: 3,
    word_length_min: 4,
    word_length_max: 7,
    case_transform: :random,
    separator_character: ~w(- : . @ &),
    digits_before: 2,
    digits_after: 2,
    padding_character: ~w(- : . ! ? @ &),
    padding_before: 1,
    padding_after: 1
  }

  @security_questions_settings %PasswordCreator{
    description: "A preset for creating fake answers to security questions.",
    num_words: 6,
    word_length_min: 4,
    word_length_max: 8,
    case_transform: :none,
    separator_character: " ",
    digits_before: 0,
    digits_after: 0,
    padding_character: ~w(. ! ?),
    padding_before: 0,
    padding_after: 1
  }

  @xkcd_settings %PasswordCreator{
    description:
      "A preset for generating passwords similar " <>
        "to the example in the original XKCD cartoon, " <>
        "but with an extra word, a dash to separate " <>
        "the random words, and the capitalisation randomised " <>
        "to add sufficient entropy to avoid warnings.",
    num_words: 5,
    word_length_min: 4,
    word_length_max: 8,
    case_transform: :random,
    separator_character: "-",
    digits_before: 0,
    digits_after: 0,
    padding_character: "",
    padding_before: 0,
    padding_after: 0
  }
end
```

And I'm not a fan of running the test that I know will fail to compile, so let's build the `EXPasswd.PasswordCreator` module with the above `@defstruct` to avoid the problem.

```elixir
defmodule EXKPasswd.PasswordCreator do
  @moduledoc """
  Provides a means to create passwords based on settings.

  The setting structure is based on the settings from the official Javascript
  port of the [xkpasswd-js/src/lib/presets.mjs module]
  (https://github.com/bartificer/xkpasswd-js/blob/main/src/lib/presets.mjs).

  I have renamed some of the settings and narrowed the number of settings to
  leverage pattern matching where multiple `if/else` phrases were necessary
  in the port.
  """

  @doc """
  The `case_transform` may be any of:

  * NONE: No transformation - use word as listed
  * ALTERNATE: alternating WORD case
  * CAPITALISE: Capitalise First Letter
  * INVERT: cAPITALISE eVERY lETTER eXCEPT tHe fIRST
  * LOWER: lower case
  * UPPER: UPPER CASE
  * RANDOM: EVERY word randomly CAPITALISED or NOT

  If `pad_to_length` is greater than zero and `padding_character` exists,
  `adding_before` and `padding_after` are ignored and the password is
  created with the specified length, padded on the end with the
  `padding_character`.

  `separator_character` and `padding_character` may be an empty string
  (`""`) to disable use, a string of length 1 character for a fixed
  value, or a list of characters which will be randomly selected. If
  the value is a string of length greater than 1, each character will
  be separated into a list to be selected randomly.
  """
  defstruct description:
              "The default preset resulting in a password consisting of " <>
                "3 random words of between 4 and 8 letters with alternating " <>
                "case separated by a random character, with two random digits " <>
                "before and after, and padded with two random characters front and back.",
            num_words: 3,
            word_length_min: 4,
            word_length_max: 8,
            case_transform: "ALTERNATE",
            separator_character: ~w(! @ $ % ^ & * - _ + = : | ~ ? / . ;),
            digits_before: 2,
            digits_after: 2,
            pad_to_length: 0,
            padding_character: ~w(! @ $ % ^ & * - _ + = : | ~ ? / . ;),
            padding_before: 2,
            padding_after: 2
end
```

Now running `mix test test/exk_passwd/password_creator_test.exs` gives us warnings that none of our settings are used, but no errors.

Now that we have some settings, let's create some tests to create passwords, and put together the password creator.

### Build a default password

While I did create a `@default_settings` definition, we should get the same thing by using the default `%PasswordCreator{}`.

Actually, that would make for a good first test. Let's make sure that the default structure does match `@default_settings`.

```elixir
  test "verify that the default %PasswordCreator is the same as @default_settings" do
    assert @default_settings === %PasswordCreator{}
  end
```

And while we're at it, let's also make sure that `@web32_settings` is not the same as the default `%PasswordCreator{}`.

```elixir
  test "verify that the default %PasswordCreator is not the same as @web32_settings" do
    refute @web32_settings === %PasswordCreator{}
  end
```

Let's run the tests.

```sh
mix test test/exk_passwd/password_creator_test.exs
Running ExUnit with seed: 614090, max_cases: 24

..    warning: module attribute @apple_id_settings was set but never used
    │
 72 │   @apple_id_settings %PasswordCreator{
    │   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    │
    └─ test/exk_passwd/password_creator_test.exs:72: EXKPasswd.PasswordCreatorTest (module)

    ...

    warning: module attribute @web16_settings was set but never used
    │
 39 │   @web16_settings %PasswordCreator{
    │   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    │
    └─ test/exk_passwd/password_creator_test.exs:39: EXKPasswd.PasswordCreatorTest (module)


Finished in 0.01 seconds (0.01s async, 0.00s sync)
2 tests, 0 failures
```

Ignoring the warnings that we aren't using most of the presets we plan to test, the two tests pass. So far, so good.

### Implement the `create` Function

The whole purpose of the `PasswordCreator` module is to create a password. So let's implement it.

The function should take an optional `%PasswordCreate{}` struct and create a password. That gives us the following signature:

```elixir
  @doc """
  Create a password based on the settings either passed in or the default settings.

  ## Examples

    iex> PasswordCreator.create()
    iex> PasswordCreator.create(%PasswordCreator{num_words: 2, separator_character: "-"})

  """
  def create(settings \\ %PasswordCreator{}) do
  end
```

With a function to call now, let's build the test up from the inside out. Here is what we know the default password structure should look like:

* num_words: 3
* word_length_min: 4
* word_length_max: 8
* case_transform: :alternate
* separator_character: ~w(! @ $ % ^ & * - _ + = : | ~ ? / . ;)

Translating that into a regular expression, we should get something like `~r/^[[:lower:]]{4,8}([!@$%^&*-_+=:|~?\/.;])[[:upper:]]{4,8}(%1)[[:lower:]]{4-8}$/`.

Three words, alternating from all lower case to all capital letters with the same separating symbol between them. Let's add such a test.

```elixir
  test "verify a default password generates 3 words, alternating all lower case and all capital letters, with the same symbol between them" do
    regex = ~r/^[[:lower:]]{4,8}([!@$%^&*-_+=:|~?\/.;])[[:upper:]]{4,8}\1[[:lower:]]{4,8}$/

    assert String.match?(
            PasswordCreator.create(),
            regex
          )
  end
```

A quick test shows:

```sh
mix test test/exk_passwd/password_creator_test.exs

[warnings]

1) test verify a default password generates 3 words, alternating all lower case and all capital letters, with the same symbol between them (EXKPasswd.PasswordCreatorTest)
   test/exk_passwd/password_creator_test.exs:131
   ** (FunctionClauseError) no function clause matching in String.match?/2

   The following arguments were given to String.match?/2:

       # 1
       nil

       # 2
       ~r/^[[:lower:]]{4,8}([!@$%^&*-_+=:|~?\/.;])[[:upper:]]{4,8}\1[[:lower:]]{4-8}$/

   Attempted function clauses (showing 1 out of 1):

       def match?(string, regex) when is_binary(string)

   code: assert String.match?(
   stacktrace:
     (elixir 1.17.2) lib/string.ex:2745: String.match?/2
     test/exk_passwd/password_creator_test.exs:134: (test)

..
Finished in 0.01 seconds (0.01s async, 0.00s sync)
1 doctest, 3 tests, 1 failure
```

Of course `nil` doesn't resemble the regex. Let's start implementing the password creation to pass this test.

```elixir
  def create(settings \\ %PasswordCreator{}) do
    separator = TokenGenerator.get_one_of(settings.separator_character)

    Enum.map(1..settings.num_words, fn _ ->
      TokenGenerator.get_word_between(settings.word_length_min, settings.word_length_max)
    end)
    |> Enum.join(separator)
  end
```

Now let's run the password creation tests.

```sh
mix test test/exk_passwd/password_creator_test.exs
Running ExUnit with seed: 791187, max_cases: 24

[warnings]

    1) test verify a default password generates 3 words, alternating all lower case and all capital letters, with the same symbol between them (EXKPasswd.PasswordCreatorTest)
    test/exk_passwd/password_creator_test.exs:131
    Expected truthy, got false
    code: assert String.match?(
            PasswordCreator.create(),
            regex
            )
    arguments:

        # 1
        "page*Colombia*jump"

        # 2
        ~r/^[[:lower:]]{4,8}([!@$%^&*-_+=:|~?\/.;])[[:upper:]]{4,8}\1[[:lower:]]{4-8}$/

    stacktrace:
        test/exk_passwd/password_creator_test.exs:134: (test)



    2) doctest EXKPasswd.PasswordCreator.create/1 (1) (EXKPasswd.PasswordCreatorTest)
    test/exk_passwd/password_creator_test.exs:5
    ** (Protocol.UndefinedError) protocol Enumerable not implemented for "-" of type BitString. This protocol is implemented for the following type(s): Date.Range, File.Stream, Floki.HTMLTree, Function, GenEvent.Stream, HashDict, HashSet, IO.Stream, Jason.OrderedObject, List,
    Map, MapSet, Phoenix.LiveView.LiveStream, Range, Stream
    stacktrace:
        (elixir 1.17.2) lib/enum.ex:1: Enumerable.impl_for!/1
        (elixir 1.17.2) lib/enum.ex:230: Enumerable.slice/1
        (elixir 1.17.2) lib/enum.ex:2412: Enum.random/1
        (exk_passwd 0.1.0) lib/exk_passwd/password_creator.ex:64: EXKPasswd.PasswordCreator.create/1


Finished in 0.01 seconds (0.01s async, 0.00s sync)
1 doctest, 3 tests, 2 failures
```

Okay. For error #1 the middle word was not all caps. I need to implement the `case_transform` functionality on all of the words.

### Diversion - `TokenGenerator.get_one_of(...)`

But error #2 is odd. I'm not passing "-" to any `Enum` functions.

Oh, yes I am. This is what the `doctest` is doing. I placed the following two examples into the documentation of `create`:

```elixir
    iex> PasswordCreator.create()
    iex> PasswordCreator.create(%PasswordCreator{num_words: 2,        separator_character: "-"})
```

I wasn't aware that Elixir's testing framework goes through the examples in the documentation and runs tests with those as well! This is cool! And it points out something I hadn't thought about in the `token_generator_test.exs` set of tests.

What is happening is that, as an example, I have a fixed `separator_character` of `"-"`. In my head, I was thinking that I'll use pattern matching when it comes time to get the separator character. But I hadn't thought it all the way through to where that is getting implemented -- the first statement of the `create function`: `separator = TokenGenerator.get_one_of(settings.separator_character)`. Because `separator_character` be a standalone string or a list of potential characters, this function should handle both cases. (It already handles the case of an empty list.)

This is a good time for a refactoring. The function name `get_one_of` suggests that it receives a list of things to choose from. I want it to work for choosing a single word or symbol. But for symbols, as stated, I want to be able to set it as a fixed string as well. Maybe it's best to say what it is for rather than overloading its usage.

Let's rename the function to `get_token`. If a string is passed, break the string up into multiple (or one) character(s) and return one at random. Otherwise, return one of the passed list. And be sure to update all references in the tests and other modules.

```elixir
  @doc """
  Randomly select one of the elements in the range.

  ## Examples

  ## Examples

  iex> TokenGenerator.get_token("-")
  "-"
  iex> TokenGenerator.get_token([])
  ""

  > TokenGenerator.get_token(~S[!"#$%&'()+*|])
  "&"
  > TokenGenerator.get_token(~w[! " # $ % & ' ( ) + * |])
  ")"

  """
  def get_token(string) when is_binary(string), do: get_token(String.graphemes(string))
  def get_token(range), do: random(range)
```

Now that I know about the doctests, I've added a few more to the documentation. The ones that are not predicable (because they return a random character) have `>` at the start of them rather than `iex>`. This disables doctests for those examples.

Running `mix test test/exk_passwd/token_generator_test.exs` still comes up clean.

### Back to `create`

Let's go back to `mix test test/exk_passwd/password_creator_test.exs` and see where we left off. Oh, yes, `case_transform: :alternate` is supposed to alternate between lower and upper case for the words in the password. Let's work on that.

Updating documentation with expected ressults

```elixir
  @doc """
  Create a password based on the settings either passed in or the default settings.

  ## Examples

    > PasswordCreator.create()
    "method^FRUIT^broad"
    > PasswordCreator.create(%PasswordCreator{num_words: 2, separator_character: "-"})
    "someone-DELIGHT"

  """
  def create(settings \\ %PasswordCreator{}) do
    separator = TokenGenerator.get_token(settings.separator_character)

    Enum.map(1..settings.num_words, fn _ ->
      TokenGenerator.get_word_between(settings.word_length_min, settings.word_length_max)
    end)
    |> case_transform(settings.case_transform)
    |> Enum.join(separator)
  end

  defp case_transform(words, :capitalize), do: Enum.map(words, &String.capitalize/1)
  defp case_transform(words, :lower), do: Enum.map(words, &String.downcase/1)
  defp case_transform(words, :upper), do: Enum.map(words, &String.upcase/1)

  defp case_transform(words, :random) do
    Enum.map(words, fn word -> case_transform(word, Enum.random([:lower, :upper])) end)
  end

  defp case_transform(words, :alternate) do
    Enum.with_index(words, fn word, idx ->
      if rem(idx, 2) == 0, do: String.downcase(word), else: String.upcase(word)
    end)
  end

  defp case_transform(words, :invert) do
    Enum.map(words, fn word ->
      {head, rest} = String.next_codepoint(word)
      String.downcase(head) <> String.upcase(rest)
    end)
  end

  defp case_transform(words, _none), do: words
```

That should take care of all of the transformations. Let's run the password creation tests now and see how it goes.

```shmix test test/exk_passwd/password_creator_test.exs
Running ExUnit with seed: 969630, max_cases: 24

[warnings]



Finished in 0.02 seconds (0.02s async, 0.00s sync)
3 tests, 0 failures
```

That did it! Three words, alternating lower case and upper case words, with a random symbol in between are generated.

### Add Digits

Next, we have the number digits optionally prepended and postpended to the created password so far with the same separator between the numbers and password. Let's implement that and update our regular expression to match the expectation.

In the `create` function, let's continue the pipeline, which now has the core three words with a random separator in between, to add a couple of digits before and after the password, with the same separator in between.

```elixir
  def create(settings \\ %PasswordCreator{}) do
    separator = TokenGenerator.get_token(settings.separator_character)

    ...
    |> add_digits(settings, separator)
  end

  defp add_digits(password, settings, separator) do
    join(TokenGenerator.get_number(settings.digits_before), password, separator)
    |> join(TokenGenerator.get_number(settings.digits_after), separator)
  end

  # Only join words with separator when prefix or suffix is not an empty string.
  defp join("", suffix, _separator), do: suffix
  defp join(prefix, "", _separator), do: prefix

  defp join(prefix, suffix, separator) do
    prefix <> separator <> suffix
  end
```

We made the `TokenGenerator.get_number` return an empty string when there were any problems creating it. So a `0` padded number will be created so long as the specified digits is 1 or more. the `join` function uses pattern matching to only add the separator when the digits are not empty.

Our regular expression for testing needs to have a pair of digits tacked on to either end, have the separator capture moved to between the first digits and the password part, and where it was being catptured changed to using the capture with `\1`.

```elixir
  ~r/^[[:digit:]]{2}([!@$%^&*-_+=:|~?\/.;])[[:lower:]]{4,8}\1[[:upper:]]{4,8}\1[[:lower:]]{4,8}\1[[:digit:]]{2}$/
```

With that, let's run our test.

```sh
mix test test/exk_passwd/password_creator_test.exs
Running ExUnit with seed: 43419, max_cases: 24

[warnings]



Finished in 0.02 seconds (0.02s async, 0.00s sync)
3 tests, 0 failures
```

### Add Padding

The pieces are all coming together nicely. The last piece is a repeated character at the front and end for padding.

Once again, let's implement the addition and update our regular expression.

```elixir
  def create(settings \\ %PasswordCreator{}) do
    ...
    |> add_padding(settings)
  end

  ...

  # Handle the case when `pad_to_length` is > 0
  defp add_padding(password, settings)
        when is_integer(settings.pad_to_length) and settings.pad_to_length > 0 do
    cond do
      settings.pad_to_length < String.length(password) ->
        String.slice(password, 0, settings.pad_to_length)

      settings.pad_to_length > String.length(password) ->
        password <>
          TokenGenerator.get_n_of(
            settings.padding_character,
            settings.pad_to_length - String.length(password)
          )

      true ->
        password
    end
  end

  defp add_padding(password, settings) do
    padding_character = TokenGenerator.get_token(settings.padding_character)

    append(TokenGenerator.get_n_of(padding_character, settings.padding_before), password)
    |> append(TokenGenerator.get_n_of(padding_character, settings.padding_after))
  end

  ...

  # Only join two values when prefix or suffix is not an empty string.
  defp append("", suffix), do: suffix
  defp append(prefix, ""), do: prefix
  defp append(prefix, suffix), do: prefix <> suffix
```

The first `add_padding` pattern matches for when there is a `pad_length > 0` in the settings. This will need to be tested later. For now, it hypothetically forces the password to be a given length by either cutting some of it off or filling it with padding at the end.

It's the second version of `add_padding` that we're normally using.

Our new regular expression is now `~r/^([!@$%^&*-_+=:|~?\/.;]){2}[[:digit:]]{2}([!@$%^&*-_+=:|~?\/.;])[[:lower:]]{4,8}\2[[:upper:]]{4,8}\2[[:lower:]]{4,8}\2[[:digit:]]{2}\1{2}$/`. Padding was added to the beginning and end with the same random symbol. The other change was that the internal capture number was incremented.

Let's run the tests and see how it went.

```sh
mix test test/exk_passwd/password_creator_test.exs
Running ExUnit with seed: 826682, max_cases: 24

[warnings]



Finished in 0.02 seconds (0.02s async, 0.00s sync)
3 tests, 0 failures
```

All good. It's now time to test the other presets and some of the other functionality.
