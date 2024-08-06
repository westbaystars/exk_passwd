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

Just as the Official Port uses Bootstrap for not only CSS but also for compoents, the Tailwind component library I'm most used to is DaisyUI. So let's next get it setup.

In the `assets` directory, run:

```sh
npm i -D daisyui@latest
```

Now we need to add the `require("daisyui")` to the list of `plugins` in `assets/tailwind.config.js` as so:

```js
...
plugins: [
  require("daisyui"),
  require("@tailwindcss/forms"),
  ...
```

And when we save that, WOW! All kinds of things appear on our page. DaisyUI has a lot in common with Bootstrap, so many of the components that were built with Bootstrap suddenly show up. It's not quite right yet, but it gives us something more to work with.

The default purple theme is also a bit, ..., something. Let's go with the same color theme as the Official Port and set the primary color to be blue with the secondary color to a gray:

```js
...
theme: {
  extend: {
    colors: {
      brand: "#FD4F00",
      primary: "#0d6efd",
      secondary: "#6c757d",
    },
  },
},
...
```

Save that and the navbar turns blue. Whew. That's easier to look at.

### Flex Layout

Next up, let's fix the layout. Right now, everything is shoved to the left edge rather than neatly centered. Also, resising the page does not do any of the magical responsive design stuff. Let's get that working.

Looking at the Official Port with browswer debug tools, it appears that they are using the `flex` layout to manage resizing and organizing the various blocks on the screen. Let's start with the three main sections:

* `.container`
* `#main`
* `#sidebar-left`

The `#sidebar-left` section is only displayed when the screen size exceeds `992px` in width. The responsive sizes are different between Bootstrap and Tailwind, so we can deviate a bit on our implementation. Let's set the `min-width` of `1024px` to show the `#sidebar-left` section, which is the `lg:` prefix in CSS.

```html
      <section id="sidebar-left" class="flex-[0_0_auto] w-1/6 order-1 hidden lg:inline shrink-0 w-full max-w-full mx-3" aria-flowto="password-card"> <!-- open section for graphic -->
        <picture>
          <!-- show this on large and above -->
          <source media="(max-width: 1024px)" srcset="/images/sideBanner.png">
          <!-- else show this -->
          <img class="img-fluid" aria-hidden="true" alt="XKPasswd - A Secure Memorable Password Generator" src="assets/sideBanner.png">
        </picture>
      </section>
```

This successfully shows and hids the side banner only when the width of the browser window is `1024px` or more.

The `.container` parent needs to be `flex` at least for the side banner to be properly placed, so let's fix it next.

```html
<div class="h-[350px] m-4 gap-6 w-full max-w-lg sm:max-w-xl md:max-w-2xl lg:max-w-4xl xl:max-w-6xl px-3 mx-auto">
  <div class="flex flex-wrap gap-6 mt-0 -mx-3"> <!-- open row for all content above footer -->
    ...
```

Ah, this does a good job centering the contents on the page in steps as the page gets wider, with the side banner appearing when the width gets to `1024px` or more.

Now, the top banner should disappear once `1024px` width is reached, so let's work on it next.

```html
<section
  id="main"
  class="flex-[1_0_0%] order-2 shrink-0 w-full max-w-full mx-3"
> <!-- open section for content right of graphic -->

  <div class="flex flex-wrap gap-6 mt-0 -mx-3"> <!-- open row for topBanner on mobile screens -->
    <section
      id="top-art"
      class="flex-[1_0_0%] order-4 inline-flex lg:hidden shrink-0 w-full max-w-full mx-3"
    >
    <picture>
        <!-- show this up to lg -->
        <source media="(max-width: 768px)" srcset="/images/topBanner.png" />
        <!-- else show this -->
        <img
        class="block w-auto max-h-[350px]"
        aria-hidden="true"
        alt="XKPasswd - A Secure Memorable Password Generator"
        src="/images/topBanner.png"
        />
    </picture>
    </section>
  </div> <!-- close row for topBanner on mobile screens -->
  ...
```

That got the main layout working, with the top banner only showing when the screen width is less that `1024px`, and the side banner only showing at `1024px` or greater size.

### Navbar

We now get to our first component. The [responsive (dropdown menu on small screen, center menu on large screen)](https://daisyui.com/components/navbar/#responsive-dropdown-menu-on-small-screen-center-menu-on-large-screen) sample has most of what we need. Namely, a drop down and items on both the left and right sides of the menu bar (we can ignore the center, but it's nice to know that it's available).

```html
<header class="flex flex-wrap gap-6 mt-0 -mx-3">
  <!-- open row for nav -->
  <div class="navbar bg-primary text-primary-content flex-wrap justify-start rounded-lg w-11/12">
    <div class="navbar-start">
      <div class="dropdown">
        <div tabindex="0" role="button" class="btn btn-ghost lg:hidden">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-5 w-5"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M4 6h16M4 12h8m-8 6h16"
            />
          </svg>
        </div>
        <ul
          tabindex="0"
          class="menu menu-sm text-lg dropdown-content bg-primary text-primary-content rounded-box z-[1] mt-3 w-52 p-2 shadow"
        >
          <li>
            <a>Actions</a>
            <ul class="p-2">
              <li><a>Import Config</a></li>
              <li><a>Export Config</a></li>
              <li><hl class="w-full" /></li>
              <li><a>Developer Docs</a></li>
            </ul>
          </li>
          <li><a>User Guide</a></li>
          <li><a>About</a></li>
          <li><a>Please Donate</a></li>
        </ul>
      </div>
      <ul class="menu menu-horizontal text-lg hidden lg:inline-flex px-1">
        <li>
          <details>
            <summary>Actions</summary>
            <ul class="bg-primary text-primary-content p-2 w-48 z-20">
              <li><a>Import Config</a></li>
              <li><a>Export Config</a></li>
              <li><hl class="w-full" /></li>
              <li><a>Developer Docs</a></li>
            </ul>
          </details>
        </li>
        <li><a>User Guide</a></li>
      </ul>
    </div>
    <div class="navbar-end">
      <ul class="menu menu-horizontal hidden text-lg lg:inline-flex px-1">
        <li><a>About</a></li>
        <li><a>Please Donate</a></li>
      </ul>
    </div>
  </div>
</header>
<!-- close row for nav -->
```

I dropped the sample DaisyUI navbar into the page over the Official Port `<navbar>` element. I then replaced the sample items with those of the Official Port. The links don't go anywhere yet. The main thing now is that it looks like the navbar we were trying to replicate. Well, it has a bit more padding, but looks good.

One major difference is that the contents of the "hamburger menu" is a duplicate of the items on the navbar, whereas they are only listed once to appear in both places for the Bootstrap component. Maybe I'll make a Phoenix component that only requires them once. But let's go with this for now.

### Accordian Presets and Settings
