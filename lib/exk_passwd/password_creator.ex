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
