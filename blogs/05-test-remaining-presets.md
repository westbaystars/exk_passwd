# Test Remaining Presets

Now that we have the password generation happening with the default settings, let's test the remaining presets. This is mostly a practice in composing regular expressions for what we expect and making sure that what is generated matches.

## Aside - Command Line Password Generation Script

As a quick aside, I've created a quick password creation script that I can execute from the command line any time:

```bash
#!/bin/bash
cd ~/projects/exk_passwd && mix run -e "EXKPasswd.PasswordCreator.create() |> IO.inspect"
```

With that in my `$PATH`, it's as easy as:

```sh
mk-passwd
"||46.bicycle.ENGINE.division.36||"
```

## WEB32 Preset Test

The next test is the `@web32_settings`, a common preset for websites that require up to 32 character passwords.

```elixir
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
```

The test is the same as the default password creation check but with a modified regular expression. There will be one padding character on either end of the created password, followed by two random digits, then the separator character between each of four words with alternating capitalization and the pair of 2-digit numbers on either side.

```elixir
test "verify that the @web32_settings password generates a password in the format: <sym1>dd<sym2>word<sym2>WORD<sym2>word<sym2>WORD<sym2>dd<sym1>" do
  regex =
    ~r/^([!@$%^&*+=:\|~])[[:digit:]]{2}([\-+=.*_\|~])[[:lower:]]{4,5}\2[[:upper:]]{4,5}\2[[:lower:]]{4,5}\2[[:upper:]]{4,5}\2[[:digit:]]{2}\1$/

    assert String.match?(
            PasswordCreator.create(@web32_settings),
            regex
          )
  end
```

And run the test:

```sh
mix test test/exk_passwd/password_creator_test.exs
Running ExUnit with seed: 543257, max_cases: 24

[warnings]



Finished in 0.02 seconds (0.02s async, 0.00s sync)
4 tests, 0 failures
```

That works. Now let's refute that this regular expression will match the default setting:

```elixir
    refute String.match?(
            PasswordCreator.create(),
            regex
          )
```

And we get the same passed test. Excellent.

We sould probably make sure that this always produced a password less than or equal to 32 characters in length.

```elixir
    Enum.all?(1..50, fn _ ->
      assert String.length(PasswordCreator.create(@web32_settings)) <= 32
    end)
```

50 times should be enough to make sure that the length is repeatably less than 32. Let's also make sure that we stay with lengths of 28 or more characters.

```elixir
    Enum.all?(1..50, fn _ ->
      assert String.length(PasswordCreator.create(@web32_settings)) >= 28
    end)
```

And running the test:

```sh
mix test test/exk_passwd/password_creator_test.exs
Running ExUnit with seed: 987186, max_cases: 24

[warnings]


  1) test verify that the @web32_settings password generates a password in the format: <sym1>dd<sym2>word<sym2>WORD<sym2>word<sym2>WORD<sym2>dd<sym1> (EXKPasswd.PasswordCreatorTest)
  test/exk_passwd/password_creator_test.exs:141
  Assertion with >= failed
  code:  assert String.length(PasswordCreator.create(@web32_settings)) >= 28
  left:  27
  right: 28
  stacktrace:
      (elixir 1.17.2) lib/enum.ex:4240: Enum.predicate_range/5
      test/exk_passwd/password_creator_test.exs:159: (test)

..
Finished in 0.05 seconds (0.05s async, 0.00s sync)
4 tests, 1 failure
```

That failed! Doesn't this produce passwords between 28 and 32 characters long?

Looking at the definition:

* 1 symbol on each side (2 characters)
* 2-digit numbers on each side (4 characters)
* 1 separator character between 6 entities (4 words and 2 numbers -- 5 characters)
* 4 words with minimum of 4 characters (16 characters)
* 4 words with maximum of 5 characters (20 characters)

That creates a range of password length to be between 27 and 31! I had a assumed that it generated 32 character passwords, but that was a false assumption. That's why we have these tests!

Going back to our definition for `@web32_settings`, let's set `digits_after: 3,` and see how the tests go.

Running the tests results in:

```sh
1) test verify that the @web32_settings password generates a password in the format: <sym1>dd<sym2>word<sym2>WORD<sym2>word<sym2>WORD<sym2>dd<sym1> (EXKPasswd.PasswordCreatorTest)
   test/exk_passwd/password_creator_test.exs:141
   Expected truthy, got false
   code: assert String.match?(
           PasswordCreator.create(@web32_settings),
           regex
         )
   arguments:

       # 1
       "+06~very~POOR~some~THERE~629+"

       # 2
       ~r/^([!@$%^&*+=:\|~])[[:digit:]]{2}([\-+=.*_\|~])[[:lower:]]{4,5}\2[[:upper:]]{4,5}\2[[:lower:]]{4,5}\2[[:upper:]]{4,5}\2[[:digit:]]{2}\1$/

   stacktrace:
     test/exk_passwd/password_creator_test.exs:145: (test)
```

Ah, we still have it testing for 2 digits at the end. Let's modify the regular express to have three digits at the end of the password (`...\2[[:upper:]]{4,5}\2[[:digit:]]{3}\1$/`).

And with that update, all tests pass.

## WEB16 Preset Test

As before, let's break down what the settings entail and modify our regular expression around it.

```elixir
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
    case_transform: :random,
    separator_character: ~w(! @ $ % ^ & * - _ + = : | ~ ? / .),
    digits_before: 0,
    digits_after: 1,
    padding_character: ""
  }
```

* No padding
* 2-digit number at the end (2 characters)
* 1 separator character between 4 entities (3 words and 1 number -- 3 characters)
* 3 words of 4 characters each alternating case (12 characters)

Hmmm. That adds up to 17 characters every time. It looks like someone else noticed that as [an issue](https://github.com/bartificer/xkpasswd-js/issues/96) has already been brought up in the official port.

Let's reduce the trailing number to just  one digit in our definition (`digits_after: 1,`).

Now let's copy the `@web32_settings` test and modify it for the above definition.

```elixir
  test "verify that the @web16_settings password generates a password in the format: word<sym>WORD<sym>WORD<sym>d" do
    regex =
      ~r/^[[[:lower:]]|[[:upper:]]]{4}([!@$%^&*\-_+=:\|~?\/.])[[[:lower:]]|[[:upper:]]]{4}\1[[[:lower:]]|[[:upper:]]]{4}\1[[:digit:]]{1}$/

    assert String.match?(
            PasswordCreator.create(@web16_settings),
            regex
          )

    refute String.match?(
            PasswordCreator.create(),
            regex
          )

    Enum.all?(1..50, fn _ ->
      assert String.length(PasswordCreator.create(@web16_settings)) == 16
    end)
  end
```

Running the test, we immediately get an error.

```sh
  1) test verify that the @web16_settings password generates a password in the format: word<sym>WORD<sym>WORD<sym>d (EXKPasswd.PasswordCreatorTest)
    test/exk_passwd/password_creator_test.exs:164
    ** (FunctionClauseError) no function clause matching in String.pad_leading/3

    The following arguments were given to String.pad_leading/3:

        # 1
        ""

        # 2
        2

        # 3
        []

    Attempted function clauses (showing 2 out of 2):

        def pad_leading(string, count, padding) when is_binary(padding)
        def pad_leading(string, count, [_ | _] = padding) when is_binary(string) and is_integer(count) and count >= 0

    code: PasswordCreator.create(@web16_settings),
    stacktrace:
      (elixir 1.17.2) lib/string.ex:1360: String.pad_leading/3
      (exk_passwd 0.1.0) lib/exk_passwd/password_creator.ex:127: EXKPasswd.PasswordCreator.add_padding/2
      test/exk_passwd/password_creator_test.exs:169: (test)
```

Hmmm. The problem appears to be in `TokenGenerator.get_n_of(...)`. When the padding character is an empty string, passing that to `String.pad_leading(string, count, padding)` fails. Apparently, if one is going to pad a string with something, then it needs to have one or more characters.

Let's update the function to make sure that we have a character.

```elixir
  def get_n_of(range, count) when is_integer(count) and count > 0 do
    char = random(range)

    cond do
      String.length(char) > 0 -> String.pad_leading(char, count, char)
      true -> ""
    end
  end

  def get_n_of(_range, _count), do: ""
```

Okay. Run the test. And we get a new error.

```sh
  1) test verify that the @web16_settings password generates a password in the format: word<sym>WORD<sym>WORD<sym>d (EXKPasswd.PasswordCreatorTest)
    test/exk_passwd/password_creator_test.exs:164
    ** (Protocol.UndefinedError) protocol Enumerable not implemented for "with" of type BitString. This protocol is implemented for the following type(s): Date.Range, File.Stream, Floki.HTMLTree, Function, GenEvent.Stream, HashDict, HashSet, IO.Stream, Jason.OrderedObject, List, Map, MapSet, Phoenix.LiveView.LiveStream, Range, Stream
    code: PasswordCreator.create(@web16_settings),
    stacktrace:
      (elixir 1.17.2) lib/enum.ex:1: Enumerable.impl_for!/1
      (elixir 1.17.2) lib/enum.ex:166: Enumerable.reduce/3
      (elixir 1.17.2) lib/enum.ex:4423: Enum.map/2
      (elixir 1.17.2) lib/enum.ex:1703: Enum."-map/2-lists^map/1-1-"/2
      (exk_passwd 0.1.0) lib/exk_passwd/password_creator.ex:71: EXKPasswd.PasswordCreator.create/1
      test/exk_passwd/password_creator_test.exs:169: (test)
```

It looks like the problem is within `case_transform(words, :random)`. Ah, I'm calling `case_transform` with the word -- not the array -- randomly with the second parameter of either `:lower` or `upper`. Let's pass the single work as an array of either and see what happens.

```elixir
  defp case_transform(words, :random) do
    Enum.map(words, fn word -> case_transform([word], Enum.random([:lower, :upper])) end)
  end
```

And run the test again.

```sh
mix test test/exk_passwd/password_creator_test.exs
Running ExUnit with seed: 588484, max_cases: 24

 [warnings]

.....
Finished in 0.09 seconds (0.09s async, 0.00s sync)
5 tests, 0 failures
```

That worked!

Each of these presets exercises different paths in the code and are finding issues not thought of originally. So let's continue.

# WIFI Preset Test

Let's continue with going through the `@wifi_settings`.

```elixir
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
```

* pad to 63 characters (always 63 characters total)
* 4-digit numbers on each side (8 characters)
* 1 separator character between 8 entities (6 words and 2 numbers -- 7 characters)
* 6 words with minimum of 4 characters (24 characters)
* 6 words with maximum of 8 characters (48 characters)

`8+7+24 => 39` characters minium before padding
`8+7+48 => 63` characters maximum without padding

That looks like it fits the description. Let's make a test for it, modifying the regular expression appropriately and testing that the length is always 63 characters long.

```elixir
  test "verify that the @wifi_settings password generates a password in the format: dddd<sym1>word<sym1>WORD<sym1>word<sym1>WORD<sym1>word<sym1>WORD<sym1>dddd[<sym2>]*" do
    regex =
      ~r/[[:digit:]]{4}([-\+=\.\*_\|~,])[[:lower:]]{4,8}\1[[:upper:]]{4,8}\1[[:lower:]]{4,8}\1[[:upper:]]{4,8}\1[[:lower:]]{4,8}\1[[:upper:]]{4,8}\1[[:digit:]]{4}[!@\$%\^&\*\+=:\|~\?]*$/

    assert String.match?(
            PasswordCreator.create(@wifi_settings),
            regex
          )

    refute String.match?(
            PasswordCreator.create(),
            regex
          )

    Enum.all?(1..5000, fn _ ->
      password = PasswordCreator.create(@wifi_settings)
      assert String.length(password) == 63
      String.match?(password, regex)
    end)
  end
```

Running that test -- is successful!

There is one more test I want to run on this. I want to make sure that a case comes up when there is no padding on the end. I tried iterating through 50,000 times and never got a positive, as the chances of getting all six words to be 8 characters long appears to be rather rare. So let's force the number of characters in all six words to be 8 and verify that there are no symbols at the end.

```elixir
  test "verify that the @wifi_settings password generates a password in the format: dddd<sym1>word<sym1>WORD<sym1>word<sym1>WORD<sym1>word<sym1>WORD<sym1>dddd" do
      regex =
        ~r/[[:digit:]]{4}([-\+=\.\*_\|~,])[[:lower:]]{4,8}\1[[:upper:]]{4,8}\1[[:lower:]]{4,8}\1[[:upper:]]{4,8}\1[[:lower:]]{4,8}\1[[:upper:]]{4,8}\1[[:digit:]]{4}$/

      # Force a password to be created with all 8 character words based on the @wifi_settings
      password = PasswordCreator.create(%{@wifi_settings | word_length_min: 8})

      assert String.length(password) == 63
      assert String.match?(password, regex)
    end
```

That tests positive! Just three more to go.

# Apple ID Preset Test

Next up is the `@apple_id_settings`.

```elixir
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
```

* 1 symbol on each side (2 characters)
* 2-digit numbers on each side (4 characters)
* 1 separator character between 5 entities (3 words and 2 numbers -- 4 characters)
* 3 words with minimum of 4 characters (12 characters)
* 3 words with maximum of 7 characters (21 characters)

`2+4+4+12 => 22` characters minium
`2+4+4+21 => 31` characters maximum

Let's create a regular expression and test for the created sizes.

```elixir
  test "verify that the @apple_id_settings password generates a password in the format: <sym1>dd<sym2>WORD<sym2>WORD<sym2>word<sym2>dd<sym1>" do
    regex =
      ~r/^([-:\.!\?@&])[[:digit:]]{2}([-:\.@&])[a-zA-Z]{4,7}\2[a-zA-Z]{4,7}\2[a-zA-Z]{4,7}\2[[:digit]]{2}\1$/

    Enum.all?(1..5000, fn _ ->
      password = PasswordCreator.create(@apple_id_settings)
      String.match?(password, regex)
      assert String.length(password) >= 22
      assert String.length(password) <= 31
    end)

    refute String.match?(
            PasswordCreator.create(),
            regex
          )
  end
```

We go straight into testing that the password matches the regular expression 5,000 times and that the generated passwords are within our character length bounds. We run the tests, and they succeed.

Now, let's add two more tests to make sure that they do generate 22 and 31 chracter passwords within 5,000 tries as well.

```elixir
  test "verify that the @apple_id_settings password generates a password 22 charaters in length at least once in 5,000 tries" do
    assert Enum.any?(1..5000, fn _ ->
            String.length(PasswordCreator.create(@apple_id_settings)) == 22
          end)
  end

  test "verify that the @apple_id_settings password generates a password 31 characters in length at least once in 5,000 tries" do
    assert Enum.any?(1..5000, fn _ ->
            String.length(PasswordCreator.create(@apple_id_settings)) == 31
          end)
  end
```

Running the tests, they all succeed!

Let's keep this momentum up.

### Security Questions Preset Test

Next up are generating fake security question answers.

```elixir
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
```

This one is easy to describe: 6 words between 4 and 8 chracters in length separated by a space with a `.`, `!`, or `?` at the end. It looks like a sentence.

```elixir
  test "verify that the @security_questions_settings password generates a sentence in the format: word word word word word word<punctuation>" do
    regex =
      ~r/^\w{4-8} \w{4-8} \w{4-8} \w{4-8} \w{4-8} \w{4-8}[\.!\?]$/

    Enum.all?(1..5000, fn _ ->
      password = PasswordCreator.create(@security_questions_settings)
      String.match?(password, regex)
    end)

    refute String.match?(
            PasswordCreator.create(),
            regex
          )
  end
```

A quick run of the tests all show success. On to the last preset.

### XKCD Preset Test

This is the one that started it all.

```elixir
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
```

Okay, as noted, a little more was added to increase entropy. But it's very simple:

* No padding
* No number
* A `-` between 5 words (4 characters)
* 5 words with minimum of 4 characters (20 characters)
* 5 words with maximum of 8 characters (40 characters)

`4+20 => 24` characters minium
`4+40 => 44` characters maximum

```elixir
  test "verify that the @xkcd_settings password generates a password in the format: WORD-word-word-WORD-word<punctuation>" do
    regex =
      ~r/^[[[a-zA-Z]]]{4,8}-[a-zA-Z]{4,8}-[a-zA-Z]{4,8}-[a-zA-Z]{4,8}-[a-zA-Z]{4,8}[\.!\?]$/

    Enum.all?(1..5000, fn _ ->
      password = PasswordCreator.create(@xkcd_settings)
      String.match?(password, regex)
      assert String.length(password) >= 24
      assert String.length(password) <= 44
    end)

    refute String.match?(
            PasswordCreator.create(),
            regex
          )
  end

  test "verify that the @xkcd_settings password generates a password 24 charaters in length at least once in 5,000 tries" do
    assert Enum.any?(1..5000, fn _ ->
            String.length(PasswordCreator.create(@xkcd_settings)) == 24
          end)
  end

  test "verify that the @xkcd_settings password generates a password 44 characters in length when forced to use 8 character long words" do
    assert String.length(PasswordCreator.create(%{@xkcd_settings | word_length_min: 8})) == 44
  end
```

And with that, we have all greens!

The presets all pass.
