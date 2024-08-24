defmodule EXKPasswd.Settings do
  use Ecto.Schema
  import Ecto.Changeset
  alias EXKPasswd.Settings

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

  `separator_character` and `padding_character` may be an emty string
  (`""`) to disable use, a string of length 1 character for a fixed
  value, or a list of characters which will be randomly selected. If
  the value is a string of length greater than 1, each character will
  be separated into a list to be selected randomly.
  """
  embedded_schema do
    field(:name, :string)
    field(:description, :string, default: "")
    field(:num_words, :integer, default: 3)
    field(:word_length_min, :integer, default: 4)
    field(:word_length_max, :integer, default: 8)

    field(:case_transform, Ecto.Enum,
      values: [:alternate, :capitalize, :invert, :lower, :upper, :random],
      default: :alternate
    )

    field(:separater_character, :string, default: ~s(!@$%^&*-_+=:|~?/.;))
    field(:digits_before, :integer, default: 2)
    field(:digits_after, :integer, default: 2)
    field(:pad_to_length, :integer, default: 0)
    field(:padding_character, :string, default: ~s(!@$%^&*-_+=:|~?/.;))
    field(:padding_before, :integer, default: 2)
    field(:padding_after, :integer, default: 2)
  end

  @doc false
  def changeset(attrs), do: changeset(%Settings{}, attrs)
  def changeset(%Settings{} = settings, attrs) do
    settings
    |> cast(attrs, [
      :name,
      :description,
      :num_words,
      :word_length_min,
      :word_length_max,
      :case_transform,
      :separater_character,
      :digits_before,
      :digits_after,
      :pad_to_length,
      :padding_character,
      :padding_before,
      :padding_after
    ])
    |> validate_required([
      :name,
      :description,
      :num_words,
      :word_length_min,
      :word_length_max,
      :case_transform,
      :separater_character,
      :digits_before,
      :digits_after,
      :pad_to_length,
      :padding_character,
      :padding_before,
      :padding_after
    ])
  end
end
