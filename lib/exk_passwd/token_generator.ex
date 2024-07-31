defmodule EXKPasswd.TokenGenerator do
  @moduledoc """
  Provides core functionality for generating random tokens (words, numbers,
  symbols) to be put together to make easy to remember, complex passwords.

  The list of English words is taken from the [Official Javascript Port of
  XKPasswd](https://github.com/bartificer/xkpasswd-js/blob/main/src/lib/dictionaryEN.mjs).

  I considered getting the words from a database. But that would be overkill
  for what is essentially a list of words. I may find that a map of word
  lengths to arrays of words works better in the future. But for now, this
  should work.
  """

  @words ~w( Africa Alabama Alaska America Amsterdam April Arizona Asia Athens August
    Australia Austria Barbados Belfast Belgium Berlin Botswana Brazil Britain British
    Bulgaria California Canada Chile China Colombia Congo Copenhagen Cuba Damascus December
    Delaware Denmark Dublin Earth Egypt England English Europe February Fiji Finland
    Florida France French Friday Germany Gibraltar Greece Greek Havana Hawaii Holland
    Iceland India Indian Ireland Italy Jamaica Japan Japanese Jerusalem Jordan July June
    Jupiter Kentucky Kenya Korea Lisbon London Madrid Malta March Mark Mars Maryland Mercury
    Mexico Monday Montana Moon Moscow Nepal Neptune Netherlands Nevada Norway November
    October Ohio Oslo Panama Paris Peru Pluto Poland Portugal Rome Russia Saturday
    Saturn Scotland September Singapore Spain Sunday Sweden Texas Tokyo Tuesday Uranus
    Venus Vermont Virginia Wales Warsaw Washington Wednesday able about above across
    action actually addition adjective advance afraid after again against agree agreed
    ahead airplane allow almost alone along already also although always among amount anger
    angle angry animal another answer anything appear apple area arms army around arrive
    arrived article attempt aunt away baby back ball bank banker base basket battle
    bean bear beat beautiful beauty became because become been before began begin behind
    being believe bell belong below beside best better between beyond bicycle bill bird
    birds black block blood blow blue board boat body bone bones book born borrow both
    bottle bottom branch branches bread break bridge bright bring broad broke broken brother
    brought brown build building built burn burning business busy butter cake call came
    cannot capital captain care carefully carry case catch cattle caught cause cells cent
    center cents century certain chair chance change character charge chart check chief
    child childhood children choose church cigarette circle city class clean clear climbed
    clock close cloth clothes cloud coast coat cold college color colour column come
    common company compare complete compound condition conditions consider
    consonant contain continue continued control cook cool copy corn corner correct cost
    cotton could count country course cover covered cows create cried crops cross crowd
    current daily dance dare dark date daughter dead deal dear death decide decided decimal
    deep degree delight demand describe desert design desire destroy details determine
    developed device dictionary died difference different difficult dinner direct
    direction discover discovered dish distance distant divide divided division doctor
    does dollar dollars done door double doubt down draw drawing dream dress dried
    drink drive drop duck during dusk duty each early ears earth east easy edge effect
    effort eggs eight either electric electricity elements else enemy energy engine
    enjoy enough enter entered entire equal equation escape especially etching even
    evening ever every everyone everything exactly example except exciting exercise
    expect experience experiment explain express face fact factories factors fail
    fair fall family famous fancy farm farmers fast father favor fear feed feel feeling
    feet fell fellow felt fence field fifteen fifth fifty fight figure fill filled
    finally find fine finger fingers finish finished fire firm first fish five flat
    flier floor flow flower flowers follow food fool foot force foreign forest forever
    forget form fortieth forty forward found four fraction free fresh friend friends
    from front fruit full further future gain galaxy game garden gate gather gave
    general gentle gentleman gift girl give gives glad glass glossary goes gold gone
    good goodbye govern government grain grass grave gray great green grew ground
    group grow grown guard guess guide hair half hall halt hand hang happen happened
    happy hard have head health hear heard heart heat heaven heavy height held
    hello help here hers high hill himself history hold hole home honor hope horse
    hour hours house however huge human hundred hunger hunt hunting hurry hurt
    husband idea important inch inches include increase indeed indicate industry
    information insects inside instead instruments interest into iron island itself
    join joined journey judge jump jumped just keep kept kill killed kind king
    kiss kitchen knew know known labor ladder lady lake land language large last
    late later laugh laughed laughter lead leader learn least leave left legs
    lend length less letter level liar life lift lifted light like likely line
    list listen little live located lone long look lord lose loss lost loud
    love lower machine made mail main major make manner many march mark market
    marry master match material matter maybe mayor mean measure meat meet
    meeting melody member members metal method middle might mile milk million
    mind mine minute minutes miss mister modern molecules moment money month
    months moon more morning most mother mountain mouth move movement much
    music must nail name nation natural nature near nearly necessary neck need
    needle neighbor neither nerve never news next nice niece night nine noise
    none noon north northern nose note nothing notice noun number numeral object
    observe ocean offer office often once only open opinion opposite order orderly
    other ought outer outside over oxygen page paid pain paint pair paper paragraph
    park part partial particular party pass passed past pattern peace people
    perfect perhaps period person phrase pick picked picture piece place plain
    plains plan plane planet plant plants play pleasant please pleasure plural poem
    point pole poor position possible pounds power practice prepare prepared present
    president presidents press pretty price printed probable probably problem process
    produce products promise property proud prove provide public pull pulled pure
    push pushed quarter queen question questions quick quickly quiet quite race radio
    rain raise raised rather reach reached read ready real realize really reason
    receive received record region remain remember repeated reply report represent
    require resent rest result return rhythm rich ridden ride right ring rise
    river road rock roll rolled room root rope rose round rule rush safe safety
    said sail salt same sand save says scale scene school science scientists
    score season seat second section seed seeds seem seen self sell send
    sense sent sentence separate serve service settle settled seven several shade
    shake shall shape share sharp shine ship shirt shoe shoes shop shore short
    shot should shoulder shout shouted show shown sick side sight sign signal
    silent silver similar simple since sing single sister size skin sleep slept
    slow slowly small smell smiled smoke snow soft soil sold soldier soldiers
    solution some someone something sometimes song soon sorry sort sound
    south southern space speak special speed spell spend spent spoke spot
    spread spring square stand star stars start state statement station stay
    steel step stick still stock stone stood stop store storm story straight strange
    stranger stream street strength stretched strike string strong student students
    study subject substances succeed success such sudden suddenly suffer suffix sugar
    suggested suit summer supply suppose sure surface surprise sweet swim syllables
    symbols system table tail take taken talk tall taste teach teacher team tear
    tell temperature terms test than thank that their them themselves then there
    therefore these they thick thin thing think third thirteen this those though
    thought thousand thousands three threw through throw thrown thus tied till
    time tiny today together told tomorrow tone took tools tore total touch toward
    town track trade train training travel tree triangle tried tries trip trouble
    truck true trust tube turn twelve twenty type uncle under underline understand
    understood unit until upon usual usually valley value various verb very
    view village visit voice vowel wagon wait walk wall want wants warm wash
    watch water wave waves weak wear weather wedge week weight welcome well went
    were west western what wheat wheel wheels when where whether which while
    white whole whom whose wide wife wild will wind window wing wings winter
    wire wise wish with within without woman women wonder wood word wore work
    workers world worn worth would write written wrong wrote yard year yellow
    yesterday young your yourself
  )

  @doc """
  Select a word at random based on the specified length of the word.

  This function will reduce the @words list to only those that contain the
  specified number of characters and select one of the words at random from
  that list.

  If there are no words with the specified list, this will return an empty
  string (`""`).

  ## Examples

    iex> TokenGenerator.get_word(4)

  """
  def get_word(length) do
    @words
    |> Enum.filter(fn w -> String.length(w) == length end)
    |> random()
  end

  @doc """
  Select a word at random with the length >= to the first value and
  <= to the last value (inclusive).

  ## Examples

    iex> TokenGenerator.get_word_between(5, 7)

  """
  def get_word_between(last, first) when last > first, do: get_word_between(first, last)
  def get_word_between(length, length) when length == length, do: get_word(length)

  def get_word_between(first, last) when is_integer(first) and is_integer(last) do
    @words
    |> Enum.filter(fn w ->
      len = String.length(w)
      len >= first and len <= last
    end)
    |> random()
  end

  def get_word_between(_first, _last), do: ""

  @doc """
  Get a 0 padded integer with a given number of digits. This gets returned as an integer.

  ## Examples

    iex> TokenGenerator.get_number(2)

  """
  def get_number(digits) when is_integer(digits) and digits >= 1 do
    0..(10 ** digits - 1)
    |> random()
    |> Integer.to_string()
    |> String.pad_leading(digits, "0")
  end

  def get_number(_), do: ""

  @doc """
  Randomly select one of the elements in the range.

  ## Examples

  iex> TokenGenerator.get_token("-")
  "-"
  iex> TokenGenerator.get_token([])
  ""

  > TokenGenerator.get_token(~S[!"#$%&'()+*|])
  "&"
  > TokenGenerator.get_token(~w[! " # $ % & ' ( ) + * |])
  ")"

  """
  def get_token(string) when is_binary(string), do: get_token(String.graphemes(string))
  def get_token(range), do: random(range)

  @doc """
  Randomly select one of the elements in the range of values and repeat it `count` times.

  ## Examples

    iex> TokenGenerator.get_n_of(~w[! " # $ % & ' ( ) + * |], 3)

  """
  def get_n_of(range, count) when is_integer(count) and count > 0 do
    char = random(range)

    cond do
      String.length(char) > 0 -> String.pad_leading(char, count, char)
      true -> ""
    end
  end

  def get_n_of(_range, _count), do: ""

  defp random([]), do: ""
  defp random(value) when is_binary(value), do: value

  defp random(range) do
    Enum.random(range)
  end
end
