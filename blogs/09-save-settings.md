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
