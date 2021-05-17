import Config

################################################################################
# Secrets ######################################################################
################################################################################

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

port = String.to_integer(System.get_env("PORT", "4000"))

live_view_salt =
  System.get_env("LIVE_VIEW_SALT") ||
    raise """
    environment variable LIVE_VIEW_SALT is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :bibcheck, BibcheckWeb.Endpoint,
  secret_key_base: secret_key_base,
  url: [host: System.get_env("APP_HOST")],
  http: [
    port: port,
    transport_options: [socket_opts: [:inet6]]
  ],
  live_view: [signing_salt: live_view_salt],
  server: true

################################################################################
# Timezone #####################################################################
################################################################################

timezone =
  System.get_env("TZ") ||
    raise """
    Environment variable timezone is missing.
    """

config :bibcheck, timezone: timezone

debuglevel =
  System.get_env("DEBUG") ||
    false

config :logger, level: if(debuglevel, do: :debug, else: :info)
