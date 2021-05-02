defmodule ExcmsAccount.Factory do
  use ExMachina.Ecto, repo: ExcmsCore.Repo

  alias ExcmsAccount.UsersService.User

  def user_factory do
    %User{
      first_name: "Jane",
      last_name: "Smith",
      email: sequence(:email, &"email-#{&1}@example.invalid"),
      email_verified_at: DateTime.utc_now(),
      password_hash: Bcrypt.hash_pwd_salt("password"),
      inserted_at: DateTime.utc_now() |> DateTime.add(sequence(:user_inserted_at, & &1), :second)
    }
  end
end
