defmodule HumoAccount.Factory do
  alias HumoAccount.UsersService.User
  alias Humo.Repo

  def insert(:user, params \\ []) do
    %User{
      first_name: "Jane",
      last_name: "Smith",
      email: "jane-smith@example.invalid",
      email_verified_at: DateTime.utc_now(),
      password_hash: Bcrypt.hash_pwd_salt("password")
    }
    |> Ecto.Changeset.change(params)
    |> Repo.insert!()
  end
end
