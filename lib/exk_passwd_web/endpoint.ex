defmodule EXKPasswdWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :exk_passwd_app

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_exk_passwd_key",
    signing_salt: "k4lDGtsv",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :exk_passwd_app,
    gzip: false,
    only: EXKPasswdWeb.static_paths()

  # ⚠️ If your app runs behind a Proxy, you must add this plug as well.
  # Otherwise, we'll block your Proxy and all incoming traffic
  # because Proxies usually override the request IP with their own.
  plug RemoteIp

  # 👇 Add the Phx2Ban.Plug behind your Plug.Static
  plug Phx2Ban.Plug

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug EXKPasswdWeb.Router
end
