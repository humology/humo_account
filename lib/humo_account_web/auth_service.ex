defmodule HumoAccountWeb.AuthService do
  @moduledoc false

  alias HumoAccount.Accounts
  alias HumoAccount.Accounts.User
  import HumoWeb, only: [routes: 0]
  alias HumoAccountWeb.Mailer

  @auth Application.compile_env!(:humo_account, __MODULE__)
  @auth_secret @auth[:secret]
  @auth_salt @auth[:salt]
  @auth_timeout_seconds @auth[:timeout_seconds]

  def authenticate_by_email_password(email, password) do
    with %User{email_verified_at: %DateTime{}} = user <-
           Accounts.get_user_by_email(email),
         true <- Bcrypt.verify_pass(password, user.password_hash) do
      {:ok, user}
    else
      %User{email_verified_at: nil} = user ->
        {:error, :email_not_verified, user}

      _ ->
        {:error, :unauthorized}
    end
  end

  def get_user_by_id(user_id) when is_binary(user_id) do
    Accounts.get_user(user_id)
  end

  def get_user_by_id(_user_id), do: nil

  def set_email_verified(token) do
    with {:ok, email} when is_binary(email) <- decode_payload(token),
         %User{} = user <- Accounts.get_user_by_email(email),
         {
           :ok,
           %User{email_verified_at: %DateTime{}}
         } <- Accounts.update_user_email_verified(user) do
      true
    else
      _ ->
        false
    end
  end

  def change_user_reset_password(token) do
    with {:ok, email} when is_binary(email) <- decode_payload(token),
         %User{} = user <- Accounts.get_user_by_email(email) do
      Accounts.change_user(user)
    else
      _ ->
        {:error, :expired_or_invalid_token}
    end
  end

  def update_user_reset_password(token, params) do
    with {:ok, email} when is_binary(email) <- decode_payload(token),
         %User{} = user <- Accounts.get_user_by_email(email) do
      Accounts.update_user_reset_password(user, params)
    else
      _ ->
        {:error, :expired_or_invalid_token}
    end
  end

  def send_verify_email(%User{id: id, email: email} = user) when not is_nil(id) do
    view = Mailer.verify_email_view()

    %{user: user, verify_email_url: get_verify_email_url(email)}
    |> view.render_email()
    |> Mailer.deliver()
  end

  def send_reset_password_email(%User{id: id, email: email} = user) when not is_nil(id) do
    view = Mailer.reset_password_view()

    %{user: user, reset_password_url: get_reset_password_url(email)}
    |> view.render_email()
    |> Mailer.deliver()
  end

  defp get_reset_password_url(email) do
    token = create_token(email)
    routes().humo_account_reset_password_url(HumoWeb.endpoint(), :edit, token)
  end

  defp get_verify_email_url(email) do
    token = create_token(email)
    routes().humo_account_verify_email_url(HumoWeb.endpoint(), :edit, token)
  end

  defp create_token(email) do
    encode_payload(email)
  end

  defp encode_payload(payload) do
    Phoenix.Token.sign(@auth_secret, @auth_salt, payload)
  end

  defp decode_payload(token) do
    opts = [max_age: @auth_timeout_seconds]
    Phoenix.Token.verify(@auth_secret, @auth_salt, token, opts)
  end
end
