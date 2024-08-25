defmodule EXKPasswd.Presets do
  @moduledoc """
  Provides a set of presets.

  These are the settings presets from the official Javascript
  port of the [xkpasswd-js/src/lib/presets.mjs module]
  (https://github.com/bartificer/xkpasswd-js/blob/main/src/lib/presets.mjs).
  """

  alias EXKPasswd.Settings

  @presets [
    %Settings{
      name: "default",
      description:
        "The default preset resulting in a password consisting of " <>
          "3 random words of between 4 and 8 letters with alternating " <>
          "case separated by a random character, with two random digits " <>
          "before and after, and padded with two random characters front and back.",
      num_words: 3,
      word_length_min: 4,
      word_length_max: 8,
      case_transform: :alternate,
      separator_character: ~s(!@$%^&*-_+=:|~?/.;),
      digits_before: 2,
      digits_after: 2,
      padding_character: ~s(!@$%^&*-_+=:|~?/.;),
      padding_before: 2,
      padding_after: 2
    },
    %Settings{
      name: "web32",
      description: "A preset for websites that allow passwords up to 32 characters long.",
      num_words: 4,
      word_length_min: 4,
      word_length_max: 5,
      case_transform: :alternate,
      separator_character: ~s(-+=.*_|~),
      digits_before: 2,
      digits_after: 3,
      padding_character: ~s(!@$%^&*+=:|~),
      padding_before: 1,
      padding_after: 1
    },
    %Settings{
      name: "web16",
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
      separator_character: ~s(!@$%^&*-_+=:|~?/.),
      digits_before: 0,
      digits_after: 1,
      padding_character: ""
    },
    %Settings{
      name: "wifi",
      description:
        "A preset for generating 63 character long WPA2 keys " <>
          "(most routers allow 64 characters, but some only 63, " <>
          "hence the odd length).",
      num_words: 6,
      word_length_min: 4,
      word_length_max: 8,
      case_transform: :alternate,
      separator_character: ~s(-+=.*_|~,),
      digits_before: 4,
      digits_after: 4,
      pad_to_length: 63,
      padding_character: ~s(!@$%^&*+=:|~?)
    },
    %Settings{
      name: "apple_id",
      description:
        "A preset respecting the many prerequisites Apple places " <>
          "on Apple ID passwords. The preset also limits itself to " <>
          "symbols found on the iOS letter and number keyboards " <>
          "(i.e. not the awkward to reach symbol keyboard).",
      num_words: 3,
      word_length_min: 4,
      word_length_max: 7,
      case_transform: :random,
      separator_character: ~s(-:.@&),
      digits_before: 2,
      digits_after: 2,
      padding_character: ~s(-:.!?@&),
      padding_before: 1,
      padding_after: 1
    },
    %Settings{
      name: "security",
      description: "A preset for creating fake answers to security questions.",
      num_words: 6,
      word_length_min: 4,
      word_length_max: 8,
      case_transform: :none,
      separator_character: " ",
      digits_before: 0,
      digits_after: 0,
      padding_character: ~s(.!?),
      padding_before: 0,
      padding_after: 1
    },
    %Settings{
      name: "xkcd",
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
  ]

  @doc """
  Returns a map of all presets.
  """
  def all(), do: @presets

  @doc """
  Returns the preset corresponding to the name giveen.
  If no name is passed, defaults to the `"default"` preset.
  If the name given does not match the name of a preset, returns `nil`.
  """
  def get(name \\ "default") do
    Enum.find(@presets, fn %{name: n} -> n === name end)
  end
end
