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
  * case transform may be `NONE`, `INIT_CAP`, `ALL_CAP`, `ALTERNATE` or `RANDOM`

## The Password Settings Structure

With the above in mind, let's create the default test structure similar to the default setting preset in [xkpasswd-js/src/lib/presets.mjs](https://github.com/bartificer/xkpasswd-js/blob/main/src/lib/presets.mjs).

Under `/test/exk_passwd`, let's create `password_creator_test.exs`:

```elixir
defmodule EXKPasswd.PasswordCreatorTest do
  use ExUnit.Case, async: true
  alias EXKPasswd.{PasswordCreator, TokenGenerator}

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
    case_transform: "ALTERNATE",
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
    case_transform: "ALTERNATE",
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
    case_transform: "ALTERNATE",
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
    case_transform: "ALTERNATE",
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
    case_transform: "RANDOM",
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
    case_transform: "NONE",
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
    case_transform: "RANDOM",
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

  `separator_character` and `padding_character` may be an emty string
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
