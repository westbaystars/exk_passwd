defmodule EXKPasswd.Settings do
  use Ecto.Schema
  import Ecto.Changeset
  alias EXKPasswd.Settings

  @derive Jason.Encoder
  @primary_key {:name, :string, default: "default"}
  @allowed_symbols ~w(- _ ~ + * = @ ! & $ % ? . , : ; ^ | / ' " ) ++ [" "]
  @empty_values []

  @doc """
  The `case_transform` may be any of:

  * :none: No transformation - use word as listed
  * :alternate: alternating WORD case
  * :capitalise: Capitalise First Letter
  * :invert: cAPITALISE eVERY lETTER eXCEPT tHe fIRST
  * :lower: lower case
  * :upper: UPPER CASE
  * :random: EVERY word randomly CAPITALISED or NOT

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
  embedded_schema do
    field(:description, :string,
      default:
        "The default preset resulting " <>
          "in a password consisting of 3 random words of between 4 and 8 " <>
          "letters with alternating case separated by a random character, " <>
          "with two random digits before and after, and padded with two " <>
          "random characters front and back."
    )

    field(:num_words, :integer, default: 3)
    field(:word_length_min, :integer, default: 4)
    field(:word_length_max, :integer, default: 8)

    field(:case_transform, Ecto.Enum,
      values: [:alternate, :capitalize, :invert, :lower, :upper, :random],
      default: :alternate
    )

    field(:separator_character, :string, default: ~s(!@$%^&*-_+=:|~?/.;))
    field(:digits_before, :integer, default: 2)
    field(:digits_after, :integer, default: 2)
    field(:pad_to_length, :integer, default: 0)
    field(:padding_character, :string, default: ~s(!@$%^&*-_+=:|~?/.;))
    field(:padding_before, :integer, default: 2)
    field(:padding_after, :integer, default: 2)
  end

  @doc false
  # def changeset(attrs), do: changeset(%Settings{}, attrs)
  def changeset(%Settings{} = settings, attrs) do
    settings
    |> cast(
      attrs,
      [
        :name,
        :description,
        :num_words,
        :word_length_min,
        :word_length_max,
        :case_transform,
        :separator_character,
        :digits_before,
        :digits_after,
        :pad_to_length,
        :padding_character,
        :padding_before,
        :padding_after
      ],
      empty_values: @empty_values
    )
    |> validate()
  end

  def validate(changeset) do
    changeset
    |> validate_required([
      :name,
      :description,
      :num_words,
      :word_length_min,
      :word_length_max,
      :case_transform,
      :digits_before,
      :digits_after,
      :pad_to_length,
      :padding_before,
      :padding_after
    ])
    |> validate_inclusion(:num_words, 1..10, message: "must be between 1 and 10")
    |> validate_inclusion(:word_length_min, 4..10, message: "must be between 4 and 10")
    |> validate_inclusion(:word_length_max, 4..10, message: "must be between 4 and 10")
    |> validate_less_than_or_equal(:word_length_min, :word_length_max, "Max Length")
    |> validate_length(:separator_character, min: 0, max: length(@allowed_symbols))
    |> validate_allowed_symbols(:separator_character)
    |> validate_inclusion(:digits_before, 0..5, message: "must be between 0 and 5")
    |> validate_inclusion(:digits_after, 0..5, message: "must be between 0 and 5")
    |> validate_length(:padding_character, max: 20)
    |> validate_inclusion(:pad_to_length, Enum.concat([0..0, 8..999]),
      message: "must be 0 or between 8 and 999"
    )
    |> validate_inclusion(:padding_before, 0..5, message: "must be between 0 and 5")
    |> validate_inclusion(:padding_after, 0..5, message: "must be between 0 and 5")
  end

  def allowed_symbols(), do: @allowed_symbols

  defp validate_less_than_or_equal(changeset, min, max, upper_label) do
    {_, min_value} = fetch_field(changeset, min)
    {_, max_value} = fetch_field(changeset, max)

    if min_value <= max_value do
      changeset
    else
      message = "must be <= to #{upper_label}"
      add_error(changeset, min, message, max_field: max)
    end
  end

  defp validate_allowed_symbols(changeset, symbols_key) do
    user_symbols = get_field(changeset, symbols_key)
    rejects =
      String.graphemes(user_symbols)
      |> Enum.reject(fn x -> Enum.member?(@allowed_symbols, x) end)

    if Enum.empty?(rejects) do
      changeset
    else
      message = "characters #{inspect(rejects)} are not allowed to be symbols"
      add_error(changeset, symbols_key, message)
    end
  end
end
