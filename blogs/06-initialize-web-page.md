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
    <section id="main" class="col order-2"> <!-- open section for content right of graphic -->
```

Looking at how this is rendered, I've got the CSS according to the debug tools for each given element and the equivilent TailwindCSS class as the comment above.

```css
/* h-[350px] */
.container {
    height: 350px;
}
/* w-full px-3 mx-auto */
.container, .container-fluid, .container-lg, .container-md, .container-sm, .container-xl, .container-xxl {
    --bs-gutter-x: 1.5rem;
    --bs-gutter-y: 0;
    width: 100%;
    padding-right: calc(var(--bs-gutter-x)* .5);
    padding-left: calc(var(--bs-gutter-x)* .5);
    margin-right: auto;
    margin-left: auto;
}
/* mt-4 */
.mt-3 {
    margin-top: 1rem !important;
}
/* flex flex-wrap gap-6 mt-0 -mx-3 */
.row {
    --bs-gutter-x: 1.5rem;
    --bs-gutter-y: 0;
    display: flex;
    flex-wrap: wrap;
    margin-top: calc(-1* var(--bs-gutter-y));
    margin-right: calc(-.5* var(--bs-gutter-x));
    margin-left: calc(-.5* var(--bs-gutter-x));
}
/* order-2 */
.order-2 {
    order: 2 !important;
}
/* flex-[1 0 0%] */
.col {
    flex: 1 0 0%;
}
/* shrink-0 w-full max-w-full mx-3 */
.row>* {
    flex-shrink: 0;
    width: 100%;
    max-width: 100%;
    padding-right: calc(var(--bs-gutter-x)* .5);
    padding-left: calc(var(--bs-gutter-x)* .5);
    margin-top: var(--bs-gutter-y);
}
```

I'm not sure what the `fouc="true"` flag is for. The best I can tell, FOUC stands for "Flash Of Unstyled Content," usually caused by CSS being loaded asyncronously. I don't think that this will be a problem for us, so I've removed the attribute.

Now, let's translate these first three elements to use TailwindCSS.

```html
<div class="h-[350px] mt-4">
  <div class="flex flex-wrap gap-6 mt-0 -mx-3"> <!-- open row for all content above footer -->
    <section id="main" class="flex-[1 0 0%] order-2 shrink-0 w-full max-w-full mx-3"> <!-- open section for content right of graphic -->
```

The order of the images change so that the side title image is now on top followed by the header title image. Okay.

Next is the header title banner, which is displayed by default on mobile screens.

```html
<div class="row"> <!-- open row for topBanner on mobile screens -->
  <section id="top-art" class="col order-4 d-inline-flex d-lg-none">
    <picture>
      <!-- show this up to lg -->
      <source media="(max-width: 768px)" srcset="/images/topBanner.png">
      <!-- else show this -->
      <img class="img-fluid" aria-hidden="true" alt="XKPasswd - A Secure Memorable Password Generator"
        src="/images/topBanner.png">
    </picture>
  </section>
</div> <!-- close row for topBanner on mobile screens -->
```

The new CSS that we see here gets translated as:

```css
/* order-4 */
.order-4 {
    order: 4 !important;
}
/* inline-flex */
.d-inline-flex {
    display: inline-flex !important;
}
/* lg:hidden */
@media (min-width: 992px) {
    .d-lg-none {
        display: none !important;
    }
}
/* block w-auto max-h-[350px] */
.container .img-fluid {
    display: block;
    width: auto;
    max-height: 350px;
}
/* max-w-full h-auto */
.img-fluid {
    max-width: 100%;
    height: auto;
}
```

And substituting the classes, we get:

```html
<div class="flex flex-wrap gap-6 mt-0 -mx-3"> <!-- open row for topBanner on mobile screens -->
  <section id="top-art" class="shrink-0 w-full max-w-full mx-3 flex-[1 0 0%] order-4 inline-flex lg:hidden">
    <picture>
      <!-- show this up to lg -->
      <source media="(max-width: 768px)" srcset="/images/topBanner.png">
      <!-- else show this -->
      <img class="block w-auto max-h-[350px] max-w-full h-auto" aria-hidden="true" alt="XKPasswd - A Secure Memorable Password Generator"
        src="/images/topBanner.png">
    </picture>
  </section>
</div> <!-- close row for topBanner on mobile screens -->
```

The top banner now disappears when we have a wide screen, but appears when the screen is less than 1,024 pixels wide. We're starting to get some functionality with the CSS.

Next is the `navbar` row. Rather than tweak the CSS to make it work under TailwindCSS, let's take a navbar the way it's done with Tailwind and use it.

We do need to bring over a couple of CSS attributes so that our navbar will fit into place. Namely:

```css
/* flex-[1 0 0%] */
.col-md {
    flex: 1 0 0%;
}
/* flex-[0 0 auto] w-11/12 */
.col-11 {
    flex: 0 0 auto;
    width: 91.66666667%;
}
```


```html
<header class="row"> <!-- open row for nav -->
  <nav class="navbar navbar-expand-lg rounded bg-primary bg-gradient col-11 col-md mx-auto">
    <div class="container-fluid">
      <!-- <a class="navbar-brand text-white" href="#"><img class="img-responsive" src="assets/logo.png"><br /><small class="fs-6">Password Generator</small></a> -->
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
        data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false"
        aria-label="Toggle navigation">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="navbarSupportedContent">
        <ul class="navbar-nav me-auto mb-2 mb-lg-0">
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle text-white" href="#" role="button" data-bs-toggle="dropdown"
              aria-expanded="false">
              Actions
            </a>
            <ul class="dropdown-menu">
              <li><a class="dropdown-item" data-bs-toggle="modal" data-bs-target="#load_config" href="#">Import Config</a></li>
              <li><a class="dropdown-item disabled" href="#">Export Config</a></li>
              <li>
                <hr class="dropdown-divider">
              </li>
              <li><a class="dropdown-item" href="docs/index.html">Developer docs</a></li>
            </ul>
          </li>
          <li class="nav-item"><a class="nav-link text-white" href="https://userguide.xkpasswd.net">User Guide</a></li>
        </ul>
        <ul class="navbar-nav ms-auto mb-2 mb-lg-0">
          <li class="nav-item">
            <a class="nav-link text-white" data-bs-toggle="modal" data-bs-target="#about" href="#">About</a>
          </li>
          <li class="nav-item">
            <a class="nav-link text-white" data-bs-toggle="modal" data-bs-target="#donate" href="#">Please
              donate</a>
          </li>
        </ul>
      </div>
    </div>
  </nav>
</header> <!-- close row for nav -->
```

New CSS translations are:

```css
```
