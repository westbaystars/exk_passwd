# EXKPasswd -- The Unofficial Elixir Port of Crypt::HSXKPasswd via XKPasswdJS

Many of you probably know about xkpasswd.net, created by [Bart Bucchots](https://www.bartb.ie/) many years ago and based on the XKCD comic [*Correct Horse Battery Staple* XKCD comic](https://xkcd.com/936/).

![To anyone who understands information theory and security and is in an infuriating argument with someone who does not (possibly involving mixed case), I sincerely apologize.](https://imgs.xkcd.com/comics/password_strength.png)

[Helma van Der Linden](https://github.com/hepabolu) has been implementing the the [Official JavaScript Port of Crypt::HSXKPasswd](https://github.com/bartificer/xkpasswd-js) in JavaScript. What I plan to do (and document in this series) is my TDD (Test Driven Development) journey to an [unofficial port in Elixir](https://github.com/westbaystars/exk_password). Much of the work will be based on the official port and what I remember of the original XKPasswd service that is now shut down (due to the Pearl version used to make it going out of support).

## Create the Project

I'm going to assume that you've got the latest version of `Erlang` and `Elixir` installed. If you haven't, look up how to install the `asdf` tools for your platform and add install the latest to your environment. This is all being done with `erlang` version 27.0.1 and `elixir` 1.17.2-otp-27. A quick `mix archive.install hex phx_new` will also make sure that you have the latest version of the `mix phx.new` initialization script to run. For me, that means that it sets up for version 1.0.0-rc1 of LiveView.

For this project, I won't be using Ecto (a database), the mailer (no need to sign up users), nor the default dashboard. Also, I want to give `bandit` a try for the `Plug` adapter rather than the usual `cowboy`. With that, here is my project initialization:

```sh
mix phx.new exk_passwd --module EXKPasswd --no-ecto --no-mailer --no-dashboard --adapter bandit
```

I go ahead and pull in all of the dependencies. A run of the default tests shows five tests run with 0 errors (though there are a few warnings in the `Jason.Decoder` dependency module).

Starting up the web server with `iex -S mix phx.server` and going to `http://localhost:4000` shows the default Phoenix web page.

We're no ready to start developing.

## Store Our Progress in Git

[CTR]C two times to get back to the shell. Then let's initialize Git locally and upload it to GitHub (or which ever Git service you prefer).

```sh
git init
git add --all
git commit -m "Initial commit."
# I use the GitHub CLI to create the GitHub project then push it up
gh auth login
gh repo create
# Select to push existing repository
git push -u origin main
```

Once uploaded, add a license. The official port uses the "BSD-2-Clause" license, so let's go with it. Naturally, incorporate the copyright notice from the official port's license.

Check that in and commit. And that should do it for a start.
