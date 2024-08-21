# Settings Dialog

The settings dialog resides in the `Settings` accordian. By default, it holds
the settings of the `:default` preset. When a different preset is selected,
the settings needs to be updated with its values.

We've slimmed down the number of values from the Official Port, so let's now
bring over the settings we'll be using.

## The `<form>`

We now want to take what was commented out and move it to where the
`<p>Settings go here</p>` contents of the `Settings` accordian go. Rather than
cutting and pasting it over, let's move the following to below the commented
out section directly below it.

```elixir
      ...
        <p>Settings go here</p>
      </div>
    </div>
  </div>
</section>
```

Let's paste this at the end of the accordian `configOptions`, just after the
`close config col` comment was ended:

```elixir
        ...
        <!-- /accordion configOptions ->
              <!-- /div> <! - - /accordion body - - >
            </div> <!- - /collapseConfig - - >
          </div>
        </div> <!- - close config col -->
              <p>Settings go here</p>
            </div>
          </div>
        </div>
      </section>
```

The page should still load without error.

Going back to where the commented out section begins, the first 58 lines may
be safely deleted. That is, everything down to
`<form id="passwordSettings" ...>`. That gives us:

```elixir
<div class="collapse-content">
  <form id="passwordSettings" class="needs-validation container-fluid" novalidate>
    <!-- word settings ->
    ...
```

The comment at the end doesn't end until way down below. To be able to have a
valid page as we go along, let's find the `</form>` and uncomment it form its
surroundings and delete the `</div>s until we reach the `Settings go here`
paragraph.

```elxir
        <!-- /section_padding -->
        </form>
        <p>Settings go here</p>
      </div>
    </div>
  </div>
</section>
```

Once again, let's make sure that the page still loads without error.

Now let's Phoenixify the form.

```elixir
<form id="password-settings" phx-change="validate" phx-submit="apply">
  <!-- word settings ->
  ...
</form>
```

We'll need to handle both the `validate` and `apply` events. So let's add
those handlers to `home_live.ex`.

```elixir
def handle_event("apply", _params, socket) do
  {:noreply, socket}
end

def handle_event("validate", _params, socket) do
  {:noreply, socket}
end
```

And to get it all to work as we implement the pieces, let's pass the
`:default` preset over as well:

```elixir
@impl Phoenix.LiveView
def mount(_params, _sessoin, socket) do
  socket = socket
  |> assign(presets: Presets.all())
  |> assign(settings: Presets.get(:default))
  {:ok, socket}
end
```

### Words

The first settings we're going to need to set are words related:

* Number of words
* Minimum length
* Maximum length

So let's uncomment that section, drop the dictionary language option (I may
implement it in the future), and convert the CSS to Tailwind.

```elixir
<!-- word settings -->
<div id="section_words" class="grid grid-cols-6 w-full gap-1 mt-0 py-3 g-1">
  <h5 class="text-xl font-medium leading-5 shrink-0 mb-2 col-span-6">Words</h5>
  <div class="mt-2 col-span-6 md:col-span-3 lg:col-span-2">
    <div class="join w-full flex flex-row">
      <label for="num_words" class="font-normal items-center text-base text-center px-3 py-2 bg-gray-100 border rounded-l-lg border-gray-300 flex-none"># of Words</label>
      <input type="number" min="1" max="10" step="1" value={@settings.num_words} class="font-normal p-[.375rem .75rem] leading-normal border rounded-r-lg border-gray-300 flex-auto w-1/12" name="num_words" id="num_words" required />
      <!--div class="invalid-feedback">Enter a number between 1 and 10</div-->
    </div>
  </div>
  <div class="mt-2 col-span-6 md:col-span-3 lg:col-span-2">
    <div class="join w-full flex flex-row">
      <label for="word_length_min" class="font-normal items-center text-base text-center px-3 py-2 bg-gray-100 border rounded-l-lg border-gray-300 flex-none">
        Min Length
      </label>
      <input type="number" min="4" max="10" step="1" value={@settings.word_length_min} class="font-normal p-[.375rem .75rem] leading-normal border rounded-r-lg border-gray-300 flex-auto w-1/12" name="word_length_min" id="word_length_min" required aria-describedby="word_length_min_error" />
      <!--div id="word_length_min_error" class="invalid-feedback">Enter a number between 4 and 10</div-->
    </div>
  </div>
  <div class="mt-2 col-span-6 md:col-span-3 lg:col-span-2">
    <div class="join w-full flex flex-row">
      <label for="word_length_max" class="font-normal items-center text-base text-center px-3 py-2 bg-gray-100 border rounded-l-lg border-gray-300 flex-none">
        Max Length
      </label>
      <input type="number" min="4" max="10" step="1" value={@settings.word_length_max} class="font-normal p-[.375rem .75rem] leading-normal border rounded-r-lg border-gray-300 flex-auto w-1/12" name="word_length_max" id="word_length_max" required aria-describedby="word_length_max_error" />
      <!--div id="word_length_max_error" class="invalid-feedback">Enter a number between 4 and 10</div-->
    </div>
  </div>
</div>
<!-- section_words -->
```

### Word Transformations

Checking the `PasswordCreator` module, the `case_transform` may be any of:

* :none: No transformation - use word as listed
* :alternate: alternating WORD case
* :capitalise: Capitalise First Letter
* :invert: cAPITALISE eVERY lETTER eXCEPT tHe fIRST
* :lower: lower case
* :upper: UPPER CASE
* :random: EVERY word randomly CAPITALISED or NOT

In the Official Port, this is just a pull down selection. So let's implement it.

```elixir
<!-- Word Transformations -->
<div id="section_transformations" class="grid grid-cols-1 w-full gap-1 mt-0 py-3 g-1">
  <h5 class="text-xl font-medium leading-5 shrink-0 mb-2 col-span-1">Transformations</h5>
  <div class="join w-full w-max-full flex flex-row">
    <label for="case_transform" class="font-normal items-center text-base text-center px-3 py-2 bg-gray-100 border rounded-l-lg border-gray-300 flex-none">Case Transformation</label>
    <select name="case_transform" id="case_transform" class="font-normal p-[.375rem .75rem] leading-normal border rounded-r-lg border-gray-300 flex-auto w-1">
      <%= Phoenix.HTML.Form.options_for_select(
        [ "-none-": :none,
          "alternating WORD case": :alternate,
          "Capitalise First Letter": :capitalise,
          "cAPITALISE eVERY lETTER eXCEPT tHe fIRST": :invert,
          "lower case": :lower,
          "UPPER CASE": :upper,
          "EVERY word randomly CAPITALISED or NOT": :random
        ], @settings.case_transform) %>
    </select>
  </div>
</div>
<!-- /section_transformations -->
```

### Separator

The separator is selected randomly from a list of characters, usually special
symbol characters. If the list has no characters, it is not output. A single
character entered for the separator character will always be used to separate
the words (and numbers if set).

This is a place where I deviated from the Official Port. Instead of having
a selector between `none`, `character` and `random`, I leave it up to the
string of characters being 0, 1, or more to determin the separator "mode."

```elixir
<!-- Separator -->
<div id="section_separator" class="grid grid-cols-1 w-full gap-1 mt-0 py-3 g-1">
  <h5 class="text-xl font-medium leading-5 shrink-0 mb-2 col-span-1">Separator</h5>
  <div class="join w-full w-max-full flex flex-row">
    <!-- specific character -->
    <label for="separator_character" class="font-normal items-center text-base text-center px-3 py-2 bg-gray-100 border rounded-l-lg border-gray-300 flex-none">
      Character
    </label>
    <input name="separator_character" id="separator_character" class="font-normal p-[.375rem .75rem] leading-normal border rounded-r-lg border-gray-300 flex-auto w-1" type="text" size="1" value={@settings.separator_character}/>
  </div>
</div>
<!-- /section_separator -->
```
