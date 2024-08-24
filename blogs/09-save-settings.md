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

#### Bring in Ecto

After numerous tries to wire up just handling the `num_words` item, I have
reached the conclusion that Ecto is necessary to handle errors efficiently.

To that end, it's time to add Ecto into the project and modify the settings
with an Ecto context. We won't be using a database on the server side. Only
the `Changeset` functionality.

The first thing we need is to add `{:ecto, "~> 3.12"},` to the `deps` in
`mix.exs`, then run `mix deps.get` and `mix deps.compile`.
