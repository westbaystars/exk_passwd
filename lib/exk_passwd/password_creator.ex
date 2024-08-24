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
  alias EXKPasswd.{Settings, TokenGenerator}

  @doc """
  Create a password based on the settings either passed in or the default settings.

  ## Examples

    > PasswordCreator.create()
    "28?heavy?SOUND?later?94"
    > PasswordCreator.create(%PasswordCreator{num_words: 2, separator_character: "-"})
    "29-large-WINTER-77"

  """
  def create(settings \\ %Settings{name: "default"}) do
    separator = TokenGenerator.get_token(settings.separator_character)

    Enum.map(1..settings.num_words, fn _ ->
      TokenGenerator.get_word_between(settings.word_length_min, settings.word_length_max)
    end)
    |> case_transform(settings.case_transform)
    |> Enum.join(separator)
    |> add_digits(settings, separator)
    |> add_padding(settings)
  end

  defp case_transform(words, :capitalize), do: Enum.map(words, &String.capitalize/1)
  defp case_transform(words, :lower), do: Enum.map(words, &String.downcase/1)
  defp case_transform(words, :upper), do: Enum.map(words, &String.upcase/1)

  defp case_transform(words, :random) do
    Enum.map(words, fn word -> case_transform([word], Enum.random([:lower, :upper])) end)
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

  defp add_digits(password, settings, separator) do
    join(TokenGenerator.get_number(settings.digits_before), password, separator)
    |> join(TokenGenerator.get_number(settings.digits_after), separator)
  end

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

  # Only join words with separator when prefix or suffix is not an empty string.
  defp join("", suffix, _separator), do: suffix
  defp join(prefix, "", _separator), do: prefix

  defp join(prefix, suffix, separator) do
    prefix <> separator <> suffix
  end

  # Only join two values when prefix or suffix is not an empty string.
  defp append("", suffix), do: suffix
  defp append(prefix, ""), do: prefix
  defp append(prefix, suffix), do: prefix <> suffix
end
