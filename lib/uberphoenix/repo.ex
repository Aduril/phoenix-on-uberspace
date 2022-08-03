defmodule Uberphoenix.Repo do
  use Ecto.Repo,
    otp_app: :uberphoenix,
    adapter: Ecto.Adapters.Postgres
end
