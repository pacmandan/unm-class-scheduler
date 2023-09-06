defmodule UnmClassSchedulerWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :unm_class_scheduler

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_unm_class_scheduler_key",
    signing_salt: "RSJLgu/l"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # THIS IS A COMPILE-TIME APPLICATION VAR
  # I couldn't get this to work with a runtime var
  if Application.compile_env!(:unm_class_scheduler, :json_logging) do
    #plug LoggerJSON.Plug, formatter: LoggerJSON.Plug.MetadataFormatters.GoogleCloudLogger
  end

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :unm_class_scheduler,
    gzip: false,
    only: ~w(assets fonts images webapp favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :unm_class_scheduler
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
  plug UnmClassSchedulerWeb.Router
end
