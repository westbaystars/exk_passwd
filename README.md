# EXKPasswd -- The Unofficial Elixir Port of Crypt::HSXKPasswd via XKPasswdJS

[Bart Busschots](https://www.bartb.ie/) created the [Crypt::HSXKPasswd](https://metacpan.org/pod/Crypt::HSXKPasswd) Perl module to be a liberally licensed ([2-clause BSD](https://opensource.org/licenses/BSD-2-Clause)) password generator for producing secure but memorable passwords using the word-based approach made famous by the [*Correct Horse Battery Staple* XKCD comic](https://xkcd.com/936/).

![To anyone who understands information theory and security and is in an infuriating argument with someone who does not (possibly involving mixed case), I sincerely apologize.](https://imgs.xkcd.com/comics/password_strength.png)

Bart is leading this port of the Perl module to JavaScript with the [NosillaCast community](https://podfeet.com/slack) as part of the on-going [Programming By Stealth blog/podcast series](https://pbs.bartificer.net) he produces with [Allison Sheridan](https://www.podfeet.com/blog/about/).

As an avid fan of [Programming By Stealth blog/podcast series](https://pbs.bartificer.net) and budding Elixir programmer, I (Michael Westbay) wanted to implement this wonderful tool in Elixir/Phoenix. This is that attempt.

## Current version of the official app

For anyone interesting in playing with the official port of the app, primarily implemented in JavaScript by [hepabolu](https://github.com/bartificer/xkpasswd-js/commits?author=hepabolu),
aka, Helma van der Linden, you can check out the app here: [XKPasswd](https://bartificer.github.io/xkpasswd-js/) with the full source code available on GitHub [here](https://github.com/bartificer/xkpasswd-js).

## Project Plan

The Elixir echosystem greatly simplifies what is being done in JavaScript with the official port. I plan to take a TDD (Test Driven Development) aproach to recreating the official port in Elixir.

Along with the tests and development, I plan to document the steps taken to create the whole thing. The best way to learn is to teach, so writing up a blog for each step helps my own understanding.

## Contributor & Developer Resources & Guides

This project is managed through GitHub. To contribute by starting or commenting on feature requests or bug reports you'll need [a free GitHub account](https://github.com/signup). The project's home on GitHub is at [github.com/bartificer/xkpasswd-js](https://github.com/westbaystars/exkpasswd/).

### Versioning Policy

This project is versioned using the Semantic Versioning System, or [SemVer](https://semver.org/).

### Source Control Policy

1. Git commits to be merged into the `main` branch will be titled in line with the [Conventional Commits](https://www.conventionalcommits.org/) approach.
2. Commit messages will be in the active voice in line with Git best practices.
3. All contributions will be submitted via Pull request
   * Until the project reaches version 1.0.0 any contributions that make progress towards the initial implementation can be merged into the `main` branch
   * Once the project reaches version 1.0.0 all contributions must be *atomic*, i.e. must be a complete unit. For code contributions that means:
     1. All tests must pass
     2. New tests must be included to cover all new functionality
     3. The Doc Comments must be updated as appropriate
     4. The code must be in the project's style

### Style Guide

As a general rule, take your lead from the existing content. If your contributions look out of place, they're unlikely to be accepted as they are.

When writing documentation, try to keep your additions in the same voice as the existing docs. Additionally, when writing Markdown please use the following conventions:

1. Use `*` as the bullet symbol.
2. Use `**` for bold.
3. Use `_` for italics.
4. Use `#` symobls for all headings, even toplevel headings, i.e. don't use the post-fixed `:` notation.
5. When adding multi-line code blocks, include a language specifier. Use `elixir` to specify Elixir code.

When writing code, be sure to run the formatter before checking in. It is fairly standard for most LS (Language Servers) to do this on saving under most IDEs.
