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
    digits_after: 3,
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
    case_transform: :random,
    separator_character: ~w(! @ $ % ^ & * - _ + = : | ~ ? / .),
    digits_before: 0,
    digits_after: 1,
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

  test "verify a default password generates 3 words, alternating all lower case and all capital letters, with the same symbol between them and a pair of 2-digit numbers on either side, wrapped by a symbol repeated twice" do
    regex =
      ~r/^([!@\$%\^&\*-_\+=:\|~\?\/\.;]){2}[[:digit:]]{2}([!@\$%\^&\*-_\+=:\|~\?\/\.;])[[:lower:]]{4,8}\2[[:upper:]]{4,8}\2[[:lower:]]{4,8}\2[[:digit:]]{2}\1{2}$/

    Enum.all?(1..5000, fn _ ->
      assert String.match?(
               PasswordCreator.create(),
               regex
             )
    end)
  end

  test "verify that the @web32_settings password generates a password in the format: <sym1>dd<sym2>word<sym2>WORD<sym2>word<sym2>WORD<sym2>dd<sym1>" do
    regex =
      ~r/^([!@\$%\^&\*\+=:\|~])[[:digit:]]{2}([\-+=.*_\|~])[[:lower:]]{4,5}\2[[:upper:]]{4,5}\2[[:lower:]]{4,5}\2[[:upper:]]{4,5}\2[[:digit:]]{3}\1$/

    assert String.match?(
             PasswordCreator.create(@web32_settings),
             regex
           )

    refute String.match?(
             PasswordCreator.create(),
             regex
           )

    Enum.all?(1..5000, fn _ ->
      password = PasswordCreator.create(@web32_settings)
      assert String.length(password) <= 32
      assert String.length(password) >= 28
      assert String.match?(password, regex)
    end)
  end

  test "verify that the @web16_settings password generates a password in the format: word<sym>WORD<sym>WORD<sym>d" do
    regex =
      ~r/^[a-zA-Z]{4}([!@\$%\^&\*-_\+=:\|~\?\/\.])[a-zA-Z]{4}\1[a-zA-Z]{4}\1\d$/

    assert String.match?(
             PasswordCreator.create(@web16_settings),
             regex
           )

    refute String.match?(
             PasswordCreator.create(),
             regex
           )

    Enum.all?(1..5000, fn _ ->
      password = PasswordCreator.create(@web16_settings)
      String.match?(password, regex)
      assert String.length(password) == 16
    end)
  end

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
      assert String.match?(password, regex)
    end)
  end

  test "verify that the @wifi_settings password generates a password in the format: dddd<sym1>word<sym1>WORD<sym1>word<sym1>WORD<sym1>word<sym1>WORD<sym1>dddd" do
    regex =
      ~r/[[:digit:]]{4}([-\+=\.\*_\|~,])[[:lower:]]{4,8}\1[[:upper:]]{4,8}\1[[:lower:]]{4,8}\1[[:upper:]]{4,8}\1[[:lower:]]{4,8}\1[[:upper:]]{4,8}\1[[:digit:]]{4}$/

    # Force a password to be created with all 8 character words based on the @wifi_settings
    password = PasswordCreator.create(%{@wifi_settings | word_length_min: 8})

    assert String.length(password) == 63
    assert String.match?(password, regex)
  end

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
end
