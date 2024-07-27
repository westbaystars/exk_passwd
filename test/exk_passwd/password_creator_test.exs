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

  test "verify that the default %PasswordCreator is the same as @default_settings" do
    assert @default_settings === %PasswordCreator{}
  end

  test "verify that the default %PasswordCreator is not the same as @web32_settings" do
    refute @web32_settings === %PasswordCreator{}
  end

  test "verify a default password generates 3 words, alternating all lower case and all capital letters, with the same symbol between them" do
    regex =
      ~r/^([!@$%^&*-_+=:|~?\/.;]){2}[[:digit:]]{2}([!@$%^&*-_+=:|~?\/.;])[[:lower:]]{4,8}\2[[:upper:]]{4,8}\2[[:lower:]]{4,8}\2[[:digit:]]{2}\1{2}$/

    assert String.match?(
             PasswordCreator.create(),
             regex
           )
  end
end
