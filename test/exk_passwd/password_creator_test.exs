defmodule EXKPasswd.PasswordCreatorTest do
  use ExUnit.Case, async: true
  alias EXKPasswd.{PasswordCreator, Presets}

  doctest PasswordCreator

  test "verify that the default %PasswordCreator is the same as @default_settings" do
    assert Presets.get(:default) === %PasswordCreator{}
  end

  test "verify that the default %PasswordCreator is not the same as @web32_settings" do
    refute Presets.get(:web32) === %PasswordCreator{}
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

    settings = Presets.get(:web32)

    assert String.match?(
             PasswordCreator.create(settings),
             regex
           )

    refute String.match?(
             PasswordCreator.create(),
             regex
           )

    Enum.all?(1..5000, fn _ ->
      password = PasswordCreator.create(settings)
      assert String.length(password) <= 32
      assert String.length(password) >= 28
      assert String.match?(password, regex)
    end)
  end

  test "verify that the @web16_settings password generates a password in the format: word<sym>WORD<sym>WORD<sym>d" do
    regex =
      ~r/^[a-zA-Z]{4}([!@\$%\^&\*-_\+=:\|~\?\/\.])[a-zA-Z]{4}\1[a-zA-Z]{4}\1\d$/

    settings = Presets.get(:web16)

    assert String.match?(
             PasswordCreator.create(settings),
             regex
           )

    refute String.match?(
             PasswordCreator.create(),
             regex
           )

    Enum.all?(1..5000, fn _ ->
      password = PasswordCreator.create(settings)
      String.match?(password, regex)
      assert String.length(password) == 16
    end)
  end

  test "verify that the @wifi_settings password generates a password in the format: dddd<sym1>word<sym1>WORD<sym1>word<sym1>WORD<sym1>word<sym1>WORD<sym1>dddd[<sym2>]*" do
    regex =
      ~r/[[:digit:]]{4}([-\+=\.\*_\|~,])[[:lower:]]{4,8}\1[[:upper:]]{4,8}\1[[:lower:]]{4,8}\1[[:upper:]]{4,8}\1[[:lower:]]{4,8}\1[[:upper:]]{4,8}\1[[:digit:]]{4}[!@\$%\^&\*\+=:\|~\?]*$/

    settings = Presets.get(:wifi)

    assert String.match?(
             PasswordCreator.create(settings),
             regex
           )

    refute String.match?(
             PasswordCreator.create(),
             regex
           )

    Enum.all?(1..5000, fn _ ->
      password = PasswordCreator.create(settings)
      assert String.length(password) == 63
      assert String.match?(password, regex)
    end)
  end

  test "verify that the @wifi_settings password generates a password in the format: dddd<sym1>word<sym1>WORD<sym1>word<sym1>WORD<sym1>word<sym1>WORD<sym1>dddd" do
    regex =
      ~r/[[:digit:]]{4}([-\+=\.\*_\|~,])[[:lower:]]{4,8}\1[[:upper:]]{4,8}\1[[:lower:]]{4,8}\1[[:upper:]]{4,8}\1[[:lower:]]{4,8}\1[[:upper:]]{4,8}\1[[:digit:]]{4}$/

    # Force a password to be created with all 8 character words based on the @wifi_settings
    settings = Presets.get(:wifi)
    password = PasswordCreator.create(%{settings | word_length_min: 8})

    assert String.length(password) == 63
    assert String.match?(password, regex)
  end

  test "verify that the @apple_id_settings password generates a password in the format: <sym1>dd<sym2>WORD<sym2>WORD<sym2>word<sym2>dd<sym1>" do
    regex =
      ~r/^([-:\.!\?@&])[[:digit:]]{2}([-:\.@&])[a-zA-Z]{4,7}\2[a-zA-Z]{4,7}\2[a-zA-Z]{4,7}\2[[:digit]]{2}\1$/

    settings = Presets.get(:apple_id)

    Enum.all?(1..5000, fn _ ->
      password = PasswordCreator.create(settings)
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
    settings = Presets.get(:apple_id)

    assert Enum.any?(1..5000, fn _ ->
             String.length(PasswordCreator.create(settings)) == 22
           end)
  end

  test "verify that the @apple_id_settings password generates a password 31 characters in length at least once in 5,000 tries" do
    settings = Presets.get(:apple_id)

    assert Enum.any?(1..5000, fn _ ->
             String.length(PasswordCreator.create(settings)) == 31
           end)
  end

  test "verify that the @security_questions_settings password generates a sentence in the format: word word word word word word<punctuation>" do
    regex =
      ~r/^\w{4-8} \w{4-8} \w{4-8} \w{4-8} \w{4-8} \w{4-8}[\.!\?]$/

    settings = Presets.get(:security)

    Enum.all?(1..5000, fn _ ->
      password = PasswordCreator.create(settings)
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

    settings = Presets.get(:xkcd)

    Enum.all?(1..5000, fn _ ->
      password = PasswordCreator.create(settings)
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
    settings = Presets.get(:xkcd)

    assert Enum.any?(1..5000, fn _ ->
             String.length(PasswordCreator.create(settings)) == 24
           end)
  end

  test "verify that the @xkcd_settings password generates a password 44 characters in length when forced to use 8 character long words" do
    settings = Presets.get(:xkcd)
    assert String.length(PasswordCreator.create(%{settings | word_length_min: 8})) == 44
  end
end
