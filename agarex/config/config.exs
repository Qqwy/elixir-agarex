# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :agarex, AgarexWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "JgVpiAlp7lr3RT8tVy02oK7Hle84LZC4BRciOyTTloAGe9uQlrabagHHW4U4autP",
  render_errors: [view: AgarexWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Agarex.PubSub,
  live_view: [signing_salt: "JrNI5hVM"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
