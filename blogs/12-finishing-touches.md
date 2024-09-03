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

## Remove the menu bar at the top

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

## Update the "Powered by" notice on the footer

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

## Make the preset buttons into pills
## Enable the presets to populate the settings when clicked
