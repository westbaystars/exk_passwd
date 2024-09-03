# Finishing Touches

There are a few things I want to complete before calling this version 1.0.

1. Remove the accordians so that `Presets` and `Settings` are both always
visible.
1. Make the preset buttons into pills
1. Enable the presets to populate the settings when clicked
1. Remove the menu bar at the top
1. Update the "Powered by" notice on the footer

No necessarily in that order.

## Remove the Accordians

LiveView doesn't play nice with the accordians. When anything on the level
above the accordians gets updated, they revert back to their original
selected state. So if one has `Presets` currently active and one hits the
`Generate` button, the first thing one sees is NOT the generated passwords,
but rather the `Settings` form suddenly takes over the screen. I don't see
a need for hiding one or the other from view, so let's remove it.

```diff
# lib/exk_passwd_web/live/home_live.ex
       |> assign_form(Settings.changeset(preset, %{}))
-      |> assign(acccordian: "settings")
       |> assign_padding(preset)
```

Remove the `:acccordian` assign from `home_live.ex`.

```diff
# lib/exk_passwd_web/live/home_live.html.heex
       <section id="content" class="flex flex-wrap gap-6 mt-0 -mx-3">
         <!-- open row for content below nav -->
         <div class="join join-vertical shrink-0 w-11/12 mt-6">
-          <div class="collapse collapse-arrow bg-base-200 border-base-300 border rounded-b-none">
-            <input
-              type="radio"
-              name="acccordian-content"
-              class="w-full checked:bg-active"
-              value="presets"
-              checked={@acccordian == "presets"}
-            />
-            <div class="collapse-title text-xl font-medium">
+          <div class="border-base-300 border rounded-b-none">
+            <div class="bg-base-200 collapse-title text-xl font-medium">
               Presets
             </div>
-            <div class="collapse-content grid grid-cols-6">
+            <div class="content grid grid-cols-6 p-4">
               <%= for preset <- @presets do %>
                 <button class="btn btn-outline uppercase col-span-3 md:col-span-2 lg:col-span-1">
                   <%= preset.name %>
                   ...

            </div>
-          <div class="collapse collapse-arrow bg-base-200 border-base-300 border rounded-t-none">
-            <input
-              type="radio"
-              name="acccordian-content"
-              value="settings"
-              class="w-full checked:bg-active"
-              checked={@acccordian == "settings"}
-            />
-            <div class="collapse-title text-xl font-medium">
+          <div class="border-base-300 border rounded-t-none">
+            <div class="bg-base-200 collapse-title text-xl font-medium">
                Settings
            </div>
-            <div class="collapse-content bg-white">
+            <div class="content bg-white p-4">
                <.simple_form
                for={@form}
                id="password-settings"
```

I also took the liberty to set the padding for the `content` section of the
former accordians and to make the background white behind the `Presets`
buttons.

I also noticed that there was a lot more padding vertically than was needed.
and removed the `py-3` class settings in the section headers and many of the
`mt-2` margins above the entry elements.

```diff
                <!-- word settings -->
-                <div id="section_words" class="grid grid-cols-6 w-full gap-1 mt-0 py-3 g-1">
+                <div id="section_words" class="grid grid-cols-6 w-full gap-1 mt-0 g-1">
                    <h5 class="text-xl font-medium leading-5 shrink-0 mb-2 col-span-6">Words</h5>
-                  <div class="mt-2 col-span-6 md:col-span-3 lg:col-span-2">
+                  <div class="col-span-6 md:col-span-3 lg:col-span-2">
                    <.input
                      ...
                    </div>
-                  <div class="mt-2 col-span-6 md:col-span-3 lg:col-span-2">
+                  <div class="col-span-6 md:col-span-3 lg:col-span-2">
                    <.input
                      ...
                    </div>
-                  <div class="mt-2 col-span-6 md:col-span-3 lg:col-span-2">
+                  <div class="col-span-6 md:col-span-3 lg:col-span-2">
                    <.input
                      ...
                <!-- Word Transformations -->
                <div
                    id="section_transformations"
-                  class="grid grid-cols-1 w-full gap-1 mt-0 py-3 g-1"
+                  class="grid grid-cols-1 w-full gap-1 mt-0 g-1"
                >
                    <h5 class="text-xl font-medium leading-5 shrink-0 mb-2 col-span-1">
                    Transformations
                    ...
                 <!-- Separator -->
-                <div id="section_separator" class="grid grid-cols-1 w-full gap-1 mt-0 py-3 g-1">
+                <div id="section_separator" class="grid grid-cols-1 w-full gap-1 mt-0 g-1">
                    <h5 class="text-xl font-medium leading-5 shrink-0 mb-2 col-span-1">
                    Separator
                    </h5>
                    ...
                <!-- Padding -->
                <div id="section_padding" class="grid grid-cols-2 w-full gap-1 mt-0 py-3 g-1">
                    <h5 class="text-xl font-medium leading-5 shrink-0 mb-2 col-span-2">Padding</h5>
-                  <div class="mt-2 col-span-2 md:col-span-1">
+                  <div class="col-span-2 md:col-span-1">
                    <!-- padding digits before -->
                    <.input
                      ...
                    <!-- /padding_digits_before -->
-                  <div class="mt-2 col-span-2 md:col-span-1">
+                  <div class="col-span-2 md:col-span-1">
                    <!-- padding digits after -->
                    <.input
                      ...
                    <!-- padding_characters -->
-                  <div class="mt-2 col-span-2">
+                  <div class="col-span-2">
                    <.input
                      ...
                    <!-- /padding_characters -->
-                  <div class="mt-2 col-span-2">
+                  <div class="col-span-2">
                    <div class="join w-full w-max-full flex flex-row">
                        <input
                          ...
                    <!-- padding characters before -->
-                  <div class="mt-2 col-span-2 md:col-span-1 pl-7">
+                  <div class="col-span-2 md:col-span-1 pl-7">
                    <.input
                      ...
                    <!-- padding characters after -->
-                  <div class="mt-2 col-span-2 md:col-span-1 pl-7 md:pl-0">
+                  <div class="col-span-2 md:col-span-1 pl-7 md:pl-0">
                    <.input
                      ...
-                  <div class="mt-2 col-span-2">
+                  <div class="col-span-2">
                    <div class="join w-full w-max-full flex flex-row">
                        <input
                          ...
                    <!-- padding characters before -->
-                  <div class="mt-2 col-span-2 md:col-span-1 pl-7">
+                  <div class="col-span-2 md:col-span-1 pl-7">
                    <.input
                      ...
                    <!-- padding characters after -->
-                  <div class="mt-2 col-span-2 md:col-span-1 pl-7 md:pl-0">
+                  <div class="col-span-2 md:col-span-1 pl-7 md:pl-0">
                    <.input
                      ...
                    <!-- pad to length -->
-                  <div class="mt-2 col-span-2">
+                  <div class="col-span-2">
                    <div class="join w-full w-max-full flex flex-row">
                        <input
                          ...
                    </div>
-                  <div class="mt-2 col-span-2 pl-7">
+                  <div class="col-span-2 pl-7">
                    <.input
                      ...
```

That was a lot of them. But it feels a little better to me. But then again,
I have a tendency to prefer everything be close together so that I can take
it all in rather than scroll. Still, scrolling will be necessary.

## Remove Menu Bar

This one is pretty straight forward. Remove the `<header>` block that contains
the `navbar`.

```diff
+++ b/lib/exk_passwd_web/live/home_live.html.heex
@@ -25,69 +25,6 @@
         </section>
       </div>
       <!-- close row for topBanner on mobile screens -->
-      <header class="flex flex-wrap gap-6 mt-0 -mx-3">
-        <!-- open row for nav -->
-        <div class="navbar bg-primary text-primary-content flex-wrap justify-start rounded-lg w-11/12">
-          <div class="navbar-start">
             ...
-          </div>
-        </div>
-      </header>
-      <!-- close row for nav -->
    <section id="content" class="flex flex-wrap gap-6 mt-0 -mx-3">
        <!-- open row for content below nav -->
        <div class="join join-vertical shrink-0 w-11/12 mt-6">
```

That was easy enough.

## Update "Powered by" Notice

The other quick and easy "fix" is to update the "Powered by" footer to point
to the `EXKPasswd` repository.

In the `<footer>`, change the link and add an `E` to the anchor's test:

```diff
</a>
|
Powered by
-      <a href="https://github.com/bartificer/xkpasswd-js" target="_blank" class="link">XKPasswd on
+      <a href="https://github.com/westbaystars/exk_passwd" target="_blank" class="link">EXKPasswd on
  GitHub</a>
</div>
</footer>
```

Okay. Now anyone can modify and host this on their own. The joys of Open
Source!

## Make the Preset Buttons into Pills

This is another easy one. Convert the `<button>`s to `<div>`s with the
`badge` related classes.

```diff
            <div class="bg-base-200 collapse-title text-xl font-medium">
              Presets
            </div>
-            <div class="content grid grid-cols-6 p-4">
+            <div class="content flex p-4">
              <%= for preset <- @presets do %>
-                <button class="btn btn-outline uppercase col-span-3 md:col-span-2 lg:col-span-1">
+                <div class="badge badge-info uppercase flex-1">
                  <%= preset.name %>
-                </button>
+                </div>
              <% end %>
            </div>
```

I was considering making them all yellow, but blue is a bit easier on the
eyes. (I cannot be trusted with what looks good, apparently.)

## Enable Presets to Populate Settings

Now the final tweak that will be a little more involved. When a preset is
clicked, the form below should be populated with that preset's values.

Let's start by triggering an event when clicking a preset.

```elixir
<%= for preset <- @presets do %>
  <div
    class="badge badge-info uppercase flex-1 cursor-pointer"
    phx-click="select-preset"
    phx-value-preset={preset.name}
  >
    <%= preset.name %>
  </div>
<% end %>
```

This will call `handle_event` with `select-preset` as the event and the
name of the preset as the `preset` parameter. I also added the
`cursor-pointer` to the `class` so make it clear that these are clickable.

So now we need to handle the event:

```elixir
def handle_event(
      "select-preset",
      %{"preset" => preset_name},
      socket
    ) do
  preset = Presets.get(preset_name)

  if preset == nil
    do {:noreply, socket}
    else {:noreply,
     socket
     |> assign(settings: preset)
     |> assign_form(Settings.changeset(preset, %{}))
     |> assign_padding(preset)
    }
  end
end
```

We need to make sure that the preset exists. Otherwise, it's much like a
trimmed down version of the `mount/3` function. Get the `preset`, verify
that it exists, if so, assign `:settings` to the preset, pass it as a
`Changeset` to `assign_form/2`, and be sure to set the `padding` radio
button appropriately.

Checking that all of the presets generate appropriate passwords, I got an
error with `WI-FI`. Hmmm. The error was stating that the `padding_character`
can't be blank. But it should be able to! Ah, it's in the `validate_required`
list. Also, I appear to have set the `validate_length` to `min: 1`.

In `settings.ex`, let's remove both `:separator_character` and
`padding_character` from the `validate_required` list. Also, remove the
`min: 1` from `:padding_character`'s `validate_length`.

Another anomoly with `WI-FI` is that `padding_after`, which should be `0`
is defaulting to `1`. That's because we aren't setting it specifically to
`0`, so let's initialize both `padding_before` and `padding_after` to
`0` in `settings.ex`.

And that does it! We now have a working password generating site!

Time to release this as version 1.0.0 and deploy it.

This was a fun exercise.
