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

## Output Generated Passwords

By checking the console log we were able to confirm that the passwords were
generated properly. Now it's time to output them.

In `home_live.html.heex`, after the section `<picture>...</picture>` block and
the `</section></div>` it resides in, we have:

```elixir
<div class="row">
  <!-- open row for password card -->

  <!-- this section (id = password-card) is handled by the PasswordController and the PasswordView -->
  <section id="password-card" class="order-3 px-0">
    ...
```

The `password-card` is where we output the passwords. After working with the
original `XKPasswd` tool and the Official port, I like the way that the
original did this better. It had a `<textarea>` where one could then modify
the generated passwords before copying them to the registration form one is
working on. I liked being able to modify them there because not all
registration forms make it clear up front what is and isn't allowed, so I
would use something close to the `default` preset then trim/change one of
the generated passwords to fix the presented "errors."

So, let's modify the `password-card` apporpriately:

```elixir
<!-- open row for password card -->
<div class="flex flex-wrap gap-6 mt-0 -mx-3">
  <!-- this section (id = password-card) is handled by the PasswordController and the PasswordView -->
  <section id="password-card" class="flex-1 order-3 px-0">
    <div class="card w-full md:w-2/3 lg:w-1/2 mt-4 lg:mt-6">
      <div class="card-body">
        <h2 class="card-title">Passwords</h2>
        <textarea
          type="text"
          rows="3"
          id="passwords"
          name="passwords"
        ><%= @passwords %></textarea>
      </div>
    </div>
    <!--
    <div class="card-footer">
      ...
    </div>
    <!-- close password card with stats -->
  </section>
</div>
```

Let's comment out the `card-footer` portion for now.

We now have a place for the generated `@passwords` to live. Hit the
`Generate` button and the `textarea` gets filled in with:

```text
49;street;OFTEN;angle;27;;;;;;;;83!fact!ALASKA!yard!85%%%%%%%%%%57-ever-NOTE-join-26^^^^^^^^^^^^
```

Ah, looks like we need to insert some `\n` in between each password.

Going back to `home_live.ex`, in the `generate` event handler, assign the
password as so:

```elixir
    |> assign(passwords: Enum.join(passwords, "\n"))}
```

With that, we now get:

```text
+++71@thought@PAIN@delaware@24+++
===24/wagon/COOL/many/22===
;;;03=bread=ROLL=friday=11;;;
```

in our `textbox`. Remove the `|> IO.inspect(label: "New passwords")` that
was added to view the generated passwords in the `generate` event handler
and we have a working password generator!

### Still To Do

There are still a lot of things that need to be done, namely:

* Implement filling the settings form when a preset is clicked
* Saving and loading personal presets, giving them a name
* Make a RESTful or GraphQL API
* Running this past a UI/UX expert (my daughter)
* Add back the stats for how strong the passwords generated are
* Update the "Powered by" phrase in the footer

I think that once the first one is done, I can call it version 1.0.
