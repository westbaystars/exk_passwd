defmodule EXKPasswdWeb.Router do
  use EXKPasswdWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {EXKPasswdWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EXKPasswdWeb do
    pipe_through :browser

    live "/", HomeLive, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", EXKPasswdWeb do
  #   pipe_through :api
  # end
end
