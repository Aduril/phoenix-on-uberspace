defmodule UberphoenixWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :uberphoenix

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_uberphoenix_key",
    signing_salt: "uZ7sCbRG"
  ]
  live_url =
    case Application.get_env(:uberphoenix, :uberspace_live_path) do
      "/" -> "/live"
      path -> "#{path}/live"
    end

  socket live_url, Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: Application.get_env(:uberphoenix, :uberspace_path),
    from: :uberphoenix,
    gzip: false,
    only: ~w(assets fonts images favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    live_reload_url =
      case Application.get_env(:uberphoenix, :uberspace_path) do
        "/" -> "/phoenix/live_reload/socket"
        path -> "#{path}/phoenix/live_reload/socket"
      end

    socket live_reload_url, Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :uberphoenix
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug UberphoenixWeb.Router
end
