# Generate Passwords

The whole goal of the site is to genreate passwords, so let's now connect our
settings to generating a few passwords for the user of the page to choose
from.

We had commented out the `id="generatePasswords"` block of code, and placed

```elixir
    ...
    </div>
  </section>
```

in front of it. Let's uncomment the `generatePasswords` block and bring it
back inside the `</div></section>` segment.

```elixir
```
    <!-- this section (id = generatePassword) is handled by the PasswordController and the PasswordView -->
    <div id="generatePassword" class="shrink-0 w-full max-w-full mx-3">
      <!-- open generate pw - need to split pw box out -->
      <h3 class="text2l font-medium leading-snug">Generate Password(s)</h3>
      <form id="generatePasswords">
        <!-- open input area for gen pw -->
        <div class="row">
          <div class="col-8 col-md-6 mb-3">
            <!-- Technically the label should be there, but it's an audible repeat of span class -->
            <!-- <label class="visually-hidden" for="selectAmount">Number of passwords</label> -->
            <div class="input-group mt-2">
              <label class="input-group-text" for="selectAmount"># of passwords</label>
              <input
                type="number"
                min="1"
                max="10"
                step="1"
                value="3"
                class="form-control"
                name="selectAmount"
                id="selectAmount"
                aria-describedby="enterNumberOfPasswords"
              />
              <!-- doesn't show as stepper on iOS or Chromium -->
            </div>
            <div id="enterNumberOfPasswords" class="form-text">
              Enter the number of passwords to be generated
            </div>
          </div>
          <div class="col-3 ">
            <!-- open col for Generate -->
            <div class="input-group mt-2">
              <button
                id="generate"
                type="submit"
                class="btn btn-primary"
                aria-label="generate passwords"
                tabindex="0"
              >
                Generate
              </button>
            </div>
          </div>
        </div>
      </form>
      <!-- close input area for gen pw -->
    </div>
    <!-- close generate pw -->
  </div>
</section>
<!-- close section for content below nav -->

Okay, that gives us the form to generate the passwords, but the CSS is all
off. Let's update the classes for TailwinCSS and use our `.input` and
`.button` components.

```elixir
<div id="generatePassword" class="shrink-0 w-full max-w-full mx-3">
  <!-- open generate pw - need to split pw box out -->
  <h3 class="text-2xl font-medium leading-snug mt-4">Generate Password(s)</h3>
  <form id="generatePasswords">
    <!-- open input area for gen pw -->
    <div class="grid grid-cols-12 w-full flex-wrap gap-6 mt-0">
      <div class="mt-2 col-span-8 md:col-span-6 mb-4">
        <.input
          type="number"
          min="1"
          max="10"
          step="1"
          value="3"
          label="# of passwords"
          id="selectAmount"
          name="selectAmount"
        />
      </div>
      <div class="col-span-3">
        <!-- open col for Generate -->
        <div class="mt-2">
          <.button
            id="generate"
            type="submit"
            aria-label="generate passwords"
            tabindex="0"
          >
            Generate
          </.button>
        </div>
      </div>
    </div>
  </form>
  <!-- close input area for gen pw -->
</div>
```

That looks much better.

Now let's get this form working. In `home_live.html.heex`, update the `form`
tags like so:

```elixir
<.form id="generatePasswords" for={%{}} phx-submit="generate">
  ...
</.form>
```

And we need the event handler in `home_live.ex`:

```elixir
def handle_event(
      "generate",
      %{"selectAmount" => count},
      %{assigns: %{form: form}} = socket
    ) do
  with (
    {:ok, settings} = Ecto.Changeset.apply_action(form.source, :update)
    {count, _} = Integer.parse(count)
    passwords = Enum.map(1..max(1, count), fn _n -> PasswordCreator.create(settings) end)
    |> IO.inspect(label: "New passwords")
  ) do
    {:noreply, socket
      |> assign(passwords: passwords)
    }
  else
    {:error, _} -> {:noreply, socket}
  end
end
```

For now we'll send the generated passwords to the console, since we don't
yet have a place for them to go. In preparation, it would also be good to
`|> assign(passwords: [])` in the `mount/3` `socket` pipeline.

I quick run with a couple of tweaks results in:

```elixir
New passwords: ["67$person$MERCURY$farm$56+++++++", "01?under?MOSCOW?free?28?????????",
 "92@period@LESS@proud@86:::::::::"]
```

All three are 32 characters long, which is what I set the `pad_to_length` at.
Let's changed to `3` before and after with `:fixed` padding and see what we
get.

```elixir
New passwords: ["!!!17?received?LOSE?panama?22!!!", "&&&02?actually?FINGER?held?97&&&",
 "&&&44%spain%BLUE%visit%72&&&"]
```

Three symbols before and after. Looks good.

Requesting `6` passwords produces six of them. Invalid values, such a `-1`,
`0`, or `20` fail with a browser error.

Next, we'll need to display the generated passwords.
