# Save Settings

Now that we have a form to change the settings, let's handle change
notifications and save the settings to the client side for future use.

## Handle `validate` Event

We setup a generic `handle_event("validate", _params, socket)` event handler
earlier that just returned `{:noreply, socket}` without doing anything else.
It's now time to update our `@settings` state with the changes made in the
form. These changes need to be saved to the client so that the next time
a user comes to the site, their personalize settings get reloaded.

### Number of Words

The number of words must be between 1 and 10 (inclusive). Verify that the
change is within that range and set `@settings.num_words` to the new value
if valid. Finally, save the new `@settings` to client storage for later
use.

## Time to Bring in Ecto

After numerous tries to wire up just handling the `num_words` item, I have
reached the conclusion that Ecto is necessary to handle errors efficiently.
I don't know why I keep trying to avoid Ecto. I've been working professionally
with databases since 1991. My guess is my dislike of ORMs ever since
JavaBeans. Ecto has been nice to work with when I have used it. But
some habits seem to die hard.

Anyway, it's time to add Ecto into the project and modify the settings
with an Ecto struct. We won't be using a database on the server side. Only
the `Changeset` functionality.

The first thing we need is to add `{:ecto, "~> 3.12"},` to the `deps` in
`mix.exs`, then run `mix deps.get` and `mix deps.compile`.

Now let's generate an embedded `Settings` structure with the same structure
as our `%PasswordCreator{}` struct.

```sh
mix phx.gen.embedded Settings name:string description:text num_words:integer word_length_min:integer word_length_max:integer case_transform:enum:alternate:capitalize:invert:lower:upper:random separater_character:string digits_before:integer digits_after:integer pad_to_length:integer padding_character:string padding_before:integer padding_after:integer
```

Of note, I added a `name` value to the front of it, so that we can refer to
the settings by name instead of relying on a map of the struct.

## EXKPasswd.Settings

We now have a `lib/exk_passwd/settings.ex` file with the data structure and
a function to create an `Ecto.Changeset`. We now need to refactor all of our
`EXKPasswd.PasswordCreator` instances to `Changset`s of `Settings`.

Let's first add our default values to the `Settings` fields:

```elixir
embedded_schema do
  field :name, :string
  field :description, :string, default: ""
  field :num_words, :integer, default: 3
  field :word_length_min, :integer, default: 4
  field :word_length_max, :integer, default: 8
  field :case_transform, Ecto.Enum, values: [:alternate, :capitalize, :invert, :lower, :upper, :random], default: :alternate
  field :separater_character, :string, default: "!@$%^&*-_+=:|~?/.;"
  field :digits_before, :integer, default: 2
  field :digits_after, :integer, default: 2
  field :pad_to_length, :integer, default: 0
  field :padding_character, :string, default: "!@$%^&*-_+=:|~?/.;"
  field :padding_before, :integer, default: 2
  field :padding_after, :integer, default: 2
end
```

Only the `:name` doesn't have a default, so it must be set at a minimum.

Let's add a helper to pass just the `attr`s to initiate a new `Settings`:

```elixir
def changeset(attrs), do: changeset(%Settings{}, attrs)
```

Now turn to the `lib/exk_passwd/presets.ex` module. Instead of each item
in the array being a tuple with a name and `PasswordCreator`, let's make it
an array of `Settings` with the name of the tuple within.

Here are the first couple:

```elixir
@presets [
  %{
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
  %{
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
  ...
]
```

And the `get/1` function needs to be modified as so:

```elixir
@doc """
Returns the preset corresponding to the name giveen.
If no name is passed, defaults to the `"default"` preset.
If the name given does not match the name of a preset, returns `nil`.
"""
def get(name \\ "default") do
  Enum.find(@presets, fn %{name: n} -> n === name end)
end
```

Now lets move over the `@doc` from `PasswordCreator` to `Settings` and remove
the `defstruct` on the `PasswordCreator` altogether. We then need to use
`%Settings{}` instead of `%PasswordCreator` in the `create/1` function:

```elixir
  ...
  alias EXKPasswd.{Settings, TokenGenerator}
  ...

  def create(settings \\ %Settings{name: "default"}) do
    ...
```

With these refactorings done, we can now run

```sh
mix test test/exk_passwd/token_generator_test.exs
```

and get 5 doctests and 14 tests to run successfully with no failures. So far,
so good. However,

```sh
mix test test/exk_passwd/password_creator_test.exs
```

fails due to using the `%PasswordCreator{}` struct which no longer exists.
Let's do a quick search/replace for `%PasswordCreator` with `%Settings`
in `test/exk_passwd/password_creator_test.ex`, add the `Settings` alias
like so:

```elixir
alias EXKPasswd.{PasswordCreator, Presets, Settings}
```

and see what happens.

Ah, we still get 13 errors. Looks like we'll need to fix these regressions
a little more manually.

### Fixing Tests

Let's take a look at the first error of the `password_creator_test.ex`.

```sh
1) test verify that the @web16_settings password generates a password in the format: word<sym>WORD<sym>WORD<sym>d (EXKPasswd.PasswordCreatorTest)
   test/exk_passwd/password_creator_test.exs:51
   ** (KeyError) key :separator_character not found in: nil

   If you are using the dot syntax, such as map.field, make sure the left-hand side of the dot is a map
   code: PasswordCreator.create(settings),
   stacktrace:
     (exk_passwd 0.1.0) lib/exk_passwd/password_creator.ex:27: EXKPasswd.PasswordCreator.create/1
     test/exk_passwd/password_creator_test.exs:58: (test)
```

It looks to me like the `web16` settings data was not retrieved before
calling `PasswordCreator.create/1`. Line 58 of the test file states:

```elixir
settings = Presets.get(:web16)
```

Ah, that should be:

```elixir
settings = Presets.get("web16"")
```

Let's now go through and fix all of the `Preset.get/1` calls to call with
a string instead of an atom.

With all of those fixed, running the test again gives us 8 failures. Getting there.

The new first error is:

```sh
1) test verify a default password generates 3 words, alternating all lower case and all capital letters, with the same symbol between them and a pair of 2-digit numbers on either side, wrapped by a symbol repeated twice
(EXKPasswd.PasswordCreatorTest)
   test/exk_passwd/password_creator_test.exs:15
   ** (KeyError) key :separator_character not found in: %EXKPasswd.Settings{
     id: nil,
     name: "default",
     description: "",
     num_words: 3,
     word_length_min: 4,
     word_length_max: 8,
     case_transform: :alternate,
     separater_character: "!@$%^&*-_+=:|~?/.;",
     digits_before: 2,
     digits_after: 2,
     pad_to_length: 0,
     padding_character: "!@$%^&*-_+=:|~?/.;",
     padding_before: 2,
     padding_after: 2
   }. Did you mean:

         * :separater_character

   code: Enum.all?(1..5000, fn _ ->
   stacktrace:
     (exk_passwd 0.1.0) lib/exk_passwd/password_creator.ex:27: EXKPasswd.PasswordCreator.create/1
     test/exk_passwd/password_creator_test.exs:21: anonymous fn/1 in EXKPasswd.PasswordCreatorTest."test verify a default password generates 3 words, alternating all lower case and all capital letters, with the same symb
ol between them and a pair of 2-digit numbers on either side, wrapped by a symbol repeated twice"/1
     (elixir 1.17.2) lib/enum.ex:4240: Enum.predicate_range/5
     test/exk_passwd/password_creator_test.exs:19: (test)
```

It looks like I have a spelling error in `settings.ex`. The three instances
of `separater_character` need to be `separator_character`.

They all look correct in `presets.ex`.

Running the test again after that fix, we're down to just 3 failures. Checking
the first:

```sh
1) test verify that the @wifi_settings password generates a password in the format: dddd<sym1>word<sym1>WORD<sym1>word<sym1>WORD<sym1>word<sym1>WORD<sym1>dddd[<sym2>]* (EXKPasswd.PasswordCreatorTest)
   test/exk_passwd/password_creator_test.exs:74
   Assertion with == failed
   code:  assert String.length(password) == 63
   left:  64                                                                                                                                                                                                                     right: 63
   stacktrace:
     test/exk_passwd/password_creator_test.exs:92: anonymous fn/2 in EXKPasswd.PasswordCreatorTest."test verify that the @wifi_settings password generates a password in the format: dddd<sym1>word<sym1>WORD<sym1>word<sym1
>WORD<sym1>word<sym1>WORD<sym1>dddd[<sym2>]*"/1
     (elixir 1.17.2) lib/enum.ex:4240: Enum.predicate_range/5
     test/exk_passwd/password_creator_test.exs:90: (test)
```

Hmmm. That's odd. It's creating a 64 character password when the maximum
should be 63. In a `iex` session with both `Presets` and `PasswordCreator`
aliases, let's generate a password with the `wifi` preset.

```elixir
settings = Presets.get("wifi")
password = PasswordCreator.create(settings)
"7170~stock~SWEET~king~CASE~dollar~CASE~2098!@$%^&*!@$%^&*+=:|~?"
```

Padding on the right side is definately not correct. That should be one of
those characters repeated to fill the password to a length of 63 characters.

Ah, `TokenGenerator.get_n_of/2` is the problem. I was setting the range of
possible characters to `~w(! @ $ % ^ & * + = : | ~ ?)` before. Now it is
the string `~s(!@$%^&*+=:|~?)`. `get_n_of/2` would then set the random
character with `char = random(range)`, which would get a random item from
the list. But since it's now a string, changing this to
`char = get_token(range)` handles this properly, turning the string into
a list of graphemes first. So let's correct this by changing it to:

```elixir
char = get_token(range)
```

Running the test again, we're down to just 2 failures, the first one being:

```sh
1) test verify that the default %Settings is the same as @default_settings (EXKPasswd.PasswordCreatorTest)
   test/exk_passwd/password_creator_test.exs:7
   Assertion with === failed
   code:  assert Presets.get("default") === %Settings{}
   left:  %{
            case_transform: :alternate,
            description: "The default preset resulting in a password consisting of 3 random words of between 4 and 8 letters with alternating case separated by a random character, with two random digits before and after,
and padded with two random characters front and back.",
            digits_after: 2,
            digits_before: 2,
            name: "default",
            num_words: 3,
            padding_after: 2,
            padding_before: 2,
            padding_character: "!@$%^&*-_+=:|~?/.;",
            separator_character: "!@$%^&*-_+=:|~?/.;",
            word_length_max: 8,
            word_length_min: 4
          }
   right: %EXKPasswd.Settings{
            case_transform: :alternate,
            description: "",
            digits_after: 2,
            digits_before: 2,
            name: nil,
            num_words: 3,
            padding_after: 2,
            padding_before: 2,
            padding_character: "!@$%^&*-_+=:|~?/.;",
            separator_character: "!@$%^&*-_+=:|~?/.;",
            word_length_max: 8,
            word_length_min: 4,
            id: nil,
            pad_to_length: 0
          }
   stacktrace:
     test/exk_passwd/password_creator_test.exs:8: (test)
```

Ah, I don't have a default `name` or `description` when the attributes are not
specified to the `Settings` struct. Let's go ahead and set those default
values:

```elixir
field(:name, :string, default: "default")
field(:description, :string, default: "The default preset resulting " <>
  "in a password consisting of 3 random words of between 4 and 8 " <>
  "letters with alternating case separated by a random character, " <>
  "with two random digits before and after, and padded with two " <>
  "random characters front and back.")
```
