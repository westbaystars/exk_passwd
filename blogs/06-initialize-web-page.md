# Initialize Web Page

The XKPasswd is a single page application. If we look at the Official JavaScript Port of XKPasswd at [https://beta.xkpasswd.net/](https://beta.xkpasswd.net/), we'll see a kind of menu bar at the top, then "Presets" and "Settings" accordian buttons, followed by a button to generate 3 (by default) passwords, and space for the generated passwords at the bottom.

For starters, let's take the body of the HTML from that page and paste it in to `lib/exk_passwd_web/controllers/page_html/home.html.heex`.  A lot of things will break, since the CSS for that page is in Bootstrap and we're using TailwindCSS by default. Don't worry about it for now.

## Initial Page

The source HTML for the main page of the Official Port can be found in [src/index.html](https://github.com/bartificer/xkpasswd-js/blob/main/src/index.html). Take everything *inside* of the `<body>` tag (not including the `<body>` tag) and paste is after the `<.flash_group flash={@flash} />` line. The `home.html.heex` page should now start off:

```elixir
<.flash_group flash={@flash} />
<!-- Main page -->
<!-- Hidden by default to prevent a flash of unstyled content (FOUC) when the page loads. -->
<div class="container mt-3" fouc="true" style="visibility: hidden;">
  <div class="row"> <!-- open row for all content above footer -->
    <section id="main" class="col order-2"> <!-- open section for content right of graphic -->
      ...
```

Let's now start up the server with `iex -S mix phx.server` in a shell. Pointing the browser to `http://localhost:4000` now results in a blank page.

What?

Looking at the page source, it's all there. But I did notice something on the main `<div>` when I pasted it:

```html
<div class="container mt-3" fouc="true" style="visibility: hidden;">
```

Let's remove the `style="visibility: hidden;"` part of that. They hid the main `<div>` from the start due to it flashing (in the comment above). I don't think we'll have that problem with Phoenix.

Once that is saved, our browser automatically reloads and we see the title, a big gap, "Presets" and "Settings" on consecutive lines, then a large gap, and the form to generate passwords. There is no styling whatsoever.

### Assets

Looking at the console log in the shell, we also see that the following assets are requested, but failed:

* `/assets/topBanner.png`
* `/assets/sideBanner.png`
* `/assets/password_strength.png`

Let's grab these three files from the `xkpasswd-js/src/assets` directory and place them in the `priv/static/images` directory of our project. We then need to modify the `home.html.heex` file to get them.

```html
      <div class="row"> <!-- open row for topBanner on mobile screens -->
        <section id="top-art" class="col order-4 d-inline-flex d-lg-none">
          <picture>
            <!-- show this up to lg -->
            <source media="(max-width: 768px)" srcset="/images/topBanner.png">
            <!-- else show this -->
            <img class="img-fluid" aria-hidden="true" alt="XKPasswd - A Secure Memorable Password Generators"
                src="/images/topBanner.png">
          </picture>
        </section>
      </div> <!-- close row for topBanner on mobile screens -->

      ...

      <section id="sidebar-left" class="col-2 order-1 d-none d-lg-inline" aria-flowto="password-card"> <!-- open section for graphic -->
        <picture>
          <!-- show this on large and above -->
          <source media="(max-width: 992px)" srcset="/images/sideBanner.png">
            <!-- else show this -->
            <img class="img-fluid" aria-hidden="true" alt="XKPasswd - A Secure Memorable Password Generators"
            src="/images/sideBanner.png">
        </picture>
      </section> <!-- close section for graphic -->

...

      <!-- Within the `#about` modal dialog -->
      <div class="modal-body">
        <h1 class="h3">THE COMIC THAT INSPIRED THIS TOOL</h1>
        <p>
          <a href="https://xkcd.com/936/" target="_blank"><img class="img-fluid" alt="XKCD - Password Strength"
            src="/images/password_strength.png"></a>
        </p>
        <h1 class="h3">CREDITS</h1>
        ...
```

Everything is still spread out, but we have the header and side images showing. The `password_strength` file is the original XKCD comic that inspired this tool and his currently hidden in the "About" dialog. We'll eventually get around to showing it. But for now, it may remain as a hidden `<div>`.

While we're looking at the `assets` folder, let's download and replace the `favicon.ico` file in the `priv/static` directory with the official one. Once that is there, reloading the page should give us the stick figure in the tool bar of our browser. Because of the way the favicon works, nothing else needs to be set.

### Presentation (CSS)

Next up is fixing the way the page works. Using a completely different CSS library (TailwindCSS instead of Bootstrap), we need to build the page differently to get the same results.

The main `<div>` is:

```html
<div class="container mt-3" fouc="true">
  <div class="flex flex-wrap gap-6 mt-0 mx-3"> <!-- open row for all content above footer -->
```

Looking at how this is rendered, we have:

```css
.container {
    height: 350px;
}
.mt-3 {
    margin-top: 1rem !important;
}
.row {
    --bs-gutter-x: 1.5rem;
    --bs-gutter-y: 0;
    display: flex;
    flex-wrap: wrap;
    margin-top: calc(-1* var(--bs-gutter-y));
    margin-right: calc(-.5* var(--bs-gutter-x));
    margin-left: calc(-.5* var(--bs-gutter-x));
}
```

Translated to TailwindCSS, we get:

```html
<div class="h-[350px] mt-4">
```

I'm not sure what the `fouc="true"` flag is for. The best I can tell, FOUC stands for "Flash Of Unstyled Content," usually caused by CSS being loaded asyncronously. I don't think that this will be a problem for us, so I've removed the attribute.
