defmodule UnmClassScheduler.Repo do
  use Ecto.Repo,
    otp_app: :unm_class_scheduler,
    adapter: Ecto.Adapters.Postgres
end
