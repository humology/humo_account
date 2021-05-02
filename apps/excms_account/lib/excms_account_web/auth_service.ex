defmodule ExcmsAccountWeb.AuthService do
  @moduledoc false

  alias ExcmsAccount.UsersService
  alias ExcmsAccount.UsersService.User
  alias ExcmsMailWeb.Mailer.VerifyEmail
  alias ExcmsMailWeb.Mailer.ResetPassword
  import ExcmsCoreWeb.RouterHelpers
  alias ExcmsServer.Endpoint

  @auth Application.compile_env!(:excms_account, __MODULE__)
  @auth_secret @auth[:secret]
  @auth_salt @auth[:salt]
  @auth_timeout_seconds @auth[:timeout_seconds]
  @email_service Application.compile_env!(:excms_account, :email)[:service]
  @send_email_async Application.compile_env!(:excms_account, :email)[:async_send]

  def authenticate_by_email_password(email, password) do
    email = String.downcase(email)

    with %User{
           email_verified_at: %DateTime{}
         } = user <- UsersService.get_user_by_email(email),
         true <- Bcrypt.verify_pass(password, user.password_hash) do
      {:ok, user}
    else
      %User{email_verified_at: nil, email: email} ->
        {:error, :email_not_verified, email}

      _ ->
        {:error, :unauthorized}
    end
  end

  def get_token(email) do
    email = String.downcase(email)

    case UsersService.get_user_by_email(email) do
      %User{email: email} ->
        token = encode_payload(email)
        {:ok, email, token}

      _ ->
        {:error, :not_found}
    end
  end

  def get_user_by_id(user_id) when is_binary(user_id) do
    UsersService.get_user(user_id)
  end

  def get_user_by_id(_user_id), do: nil

  def set_email_verified(token) do
    with {:ok, email} when is_binary(email) <- decode_payload(token),
         %User{} = user <- UsersService.get_user_by_email(email),
         {
           :ok,
           %User{email_verified_at: %DateTime{}}
         } <- UsersService.update_user_email_verified(user) do
      true
    else
      _ ->
        false
    end
  end

  def change_user_reset_password(token) do
    with {:ok, email} when is_binary(email) <- decode_payload(token),
         %User{} = user <- UsersService.get_user_by_email(email) do
      UsersService.change_user(user)
    else
      _ ->
        {:error, :failed}
    end
  end

  def update_user_reset_password(token, params) do
    with {:ok, email} when is_binary(email) <- decode_payload(token),
         %User{} = user <- UsersService.get_user_by_email(email) do
      UsersService.update_user_reset_password(user, params)
    else
      _ ->
        {:error, :failed}
    end
  end

  def send_verify_email(email) do
    with {:ok, email, token} <- get_token(email) do
      send_email(%VerifyEmail{
        to: email,
        email_verified_url: routes().verify_email_url(Endpoint, :edit, token)
      })
    end
  end

  def send_reset_password_email(email) do
    with {:ok, email, token} <- get_token(email) do
      send_email(%ResetPassword{
        to: email,
        reset_password_url: routes().reset_password_url(Endpoint, :edit, token)
      })
    end
  end

  defp send_email(message) do
    case @send_email_async do
      false -> @email_service.send_email(message)
      true -> Task.start(@email_service, :send_email, [message])
    end
  end

  defp encode_payload(payload) do
    Phoenix.Token.sign(@auth_secret, @auth_salt, payload)
  end

  defp decode_payload(token) do
    opts = [max_age: @auth_timeout_seconds]
    Phoenix.Token.verify(@auth_secret, @auth_salt, token, opts)
  end
end
