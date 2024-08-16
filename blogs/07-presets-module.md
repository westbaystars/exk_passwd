# Presets Module

It now appears to me that we're going to need a module to handle the built in and user presets.

For starters, let's take the presets from our tests and put them into an array here.

```elixir
defmodule EXKPasswd.Presets do
  @moduledoc """
  Provides a set of presets.

  These are the settings presets from the official Javascript
  port of the [xkpasswd-js/src/lib/presets.mjs module]
  (https://github.com/bartificer/xkpasswd-js/blob/main/src/lib/presets.mjs).
  """
  alias EXKPasswd.PasswordCreator

  @presets %{
    default: %PasswordCreator{
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
    },

    web32: %PasswordCreator{
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
    },

    web16: %PasswordCreator{
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
    },

    wifi: %PasswordCreator{
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
    },

    apple_id: %PasswordCreator{
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
    },

    security: %PasswordCreator{
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
    },

    xkcd: %PasswordCreator{
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
  }

  @doc """
  Returns a map of all presets.
  """
  def all(), do: @presets
end
```

That is all of them that we had in the test document. Let's see what we have by going into the `iex` shell and typing `Presets.all() |> Map.keys()`:

```elixir
[:default, :web32, :web16, :wifi, :apple_id, :security, :xkcd]
```

That is the seven that we tested before. However, looking at the Official Port that is running, `NTLM` and `TEMPORARY` presets are missing. Did I miss them?

The description of the `NTLM` was:

    A preset for 14 character Windows NTLMv1 password.
    WARNING - only use this preset if you have to, it is
    too short to be acceptably secure and will always
    generate entropy warnings for the case where the config
    and dictionary are known.'

That's even worse than the `WEB16` preset. I think I left this one off on purpose. Let's continue to do so.

The description for the `TEMPORARY` preset on the web is:

    A preset for creating temporary phone friendly passwords.
    WARNING - They are not secure and should be changed
    immediately.

Hmmm. Another really weak password generator. At least this one has a reson other than for an obsolete operating system.

Looking at the settings, it appears to create a password with two 4-letter words, capitalizing each word, putting a hyphen between the words, and ending with a 2-digit number. That's always a password of 13 characters, easy to enter on a phone keyboard.

I think I'll pass on it as well, unless someone requests it.

Okay, so we have 7 defaults and a function to get them all. Now let's add a function to get one by name.

```elixir
  @doc """
  Returns the preset corresponding to the name giveen.
  If no name is passed, defaults to the `:default` preset.
  If the name given does not match the name of a preset, returns `nil`.
  """
  def get(name \\ :default), do: Map.get(@presets, name)
```

Rather than write a whole new test suite for this module, let's make sure that it works with the `test/exk_passwd/Password_creator_tests.exs` tests. To accomplish that, after removing all of the `@*preset*_setting`s from the file, change `@default_settings` to `Presets.get(:default)`, etc.

The simple tests will become:

```elixir
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

  ...
```

For the more involved tests, where a given setting is evaluated more than once, modify the test similar to:

```elixir
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
```

Once all of the tests have been updated to get the settings from the `Presets` module, run the tests:

```sh
mix test test/exk_passwd/password_creator_test.exs
Running ExUnit with seed: 933544, max_cases: 24

..............
Finished in 15.6 seconds (15.6s async, 0.00s sync)
14 tests, 0 failures
```

If you got any errors, fixing them would be a good exercise. For the most part, place the given preset into `settings` and use that value in its place. Also, remember, we renamed `@security_questions` to the key `:security`.

We'll do more with the `Presets` module later (like have custom presets). But this will work for now.

### Populate Presets on Web Page

The `Presets` module can now feed a list of presets to the web page for viewing. Let's start there and see where it takes us.

Oh, and the first place it takes us is the need to make the main page a `:live_view` page. To do that, create a `live` directory under `lib/exk_passwd_web`. Now copy our `/lib/exk_passwd_web/controllers/page_html_home.html.heex` page to the `../live` directory and rename it as `home_live.html.heex`.

Now, in the same `.../live` directory, let's create `home_live.ex` and fill it with:

```elixir
defmodule EXKPasswdWeb.HomeLive do
  use Phoenix.LiveView

  alias EXKPasswd.Presets

  @impl Phoenix.LiveView
  def mount(_params, _sessoin, socket) do
    socket = socket
    |> assign(presets: Presets.all())
    {:ok, socket}
  end
end
```

This will give us the `:presets` item in `socket.assigns` that we can then access in the `Presets` accordian as so:

```elixir
<div class="collapse-content">
  <%= for {preset, _} <- @presets do %>
    <button class="btn btn-outline"><%= preset %></button>
  <% end %>
</div>
```

Finally, change where `/` points in `lib/exk_passwd_web/router.ex` to:

```elixir
    live "/", HomeLive
```

If you don't already have it running, run `iex -S mix phx.server` in a terminal to get the web server running, then check `http://localhost:4000/` to see the results.
You should now have a list of buttons in the `Presets` accordian labeled: "default", "apple_id", "security", "web16", "web32", "wifi", "xkcd".

Looking at this, there are some things that will be easy to fix, such as spacing the buttons out similar to the Official Port.
And there will be things that are more difficult, such as that the `Map` of presets doesn't preserve order.

Let's start with the easy ones, capitalizing the text and spacing the buttons out.

```elixir
<div class="collapse-content grid grid-cols-6">
  <%= for {preset, _} <- @presets do %>
    <button class="btn btn-outline uppercase col-span-3 md:col-span-2 lg:col-span-1"><%= preset %></button>
  <% end %>
</div>
```

We first set the accordian content to be a `grid` layout divided into `6` columns.
The default span for the buttons is `3` column, decreasing to `2` columns for medium sized displayed, and covering only `1` column for large displays.
Finally, the button text is transformed to `uppercase`, aliviating the need to change the case progmatically.

Resizing the window on a desktop computer will show that all of the preset names are clearly displayed for the various sizes.

Now for the harder part, retaining the order. The simplest way to do this would be to make the map of presets into a list of tuples in the structure of `{:name, preset}`. This is how we're currently returning the list in the `all()` function, so it won't break that. We will need to change how we implement `get/1`, though.

```elixir
  @presets [
    {:default, %PasswordCreator{
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
    }},
    ...
    {:xkcd, %PasswordCreator{
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
    }}
  ]

  ...

  def get(name \\ :default), do: Enum.find_value(@presets, fn {n, s} -> if n === name, do: s end)
```

And let's make sure that that didn't break anything by running `mix test test/exk_passwd/password_creator_test.exs`.
All tests pass! That will work.

Now if we look at our presets on the web, we get: "DEFAULT", "WEB32", "WEB16", "WIFI", "APPLE_ID", "SECURITY", and "XKCD". That's the order we were expecting. And not much refactoring was necessary. Yay!

We now have a module for managing our presets, and we refactored it to always return the presets in the order that they are declared.

We also now have a LiveView page that displays buttons for the presets the same as the Official Port does.

This is a good spot to end for now. Next will be the `Settings` accordian.
