defmodule ExcmsAccount.UsersService.User do
  use Ecto.Schema
  use ExcmsCore.Resource
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Inspect, only: [:id]}

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :email_verified_at, :utc_datetime_usec, default: nil
    field :password, :string, virtual: true
    field :current_password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email])
    |> validate_required([:first_name, :last_name, :email])
    |> unique_constraint(:email)
    |> put_downcase_email()
  end

  def profile_changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name])
    |> validate_required([:first_name, :last_name])
  end

  def signup_changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :password])
    |> validate_required([:first_name, :last_name, :email, :password])
    |> unique_constraint(:email)
    |> put_downcase_email()
    |> put_password_hash()
  end

  def reset_password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> put_password_hash()
  end

  def email_verified_changeset(user, attrs) do
    user
    |> cast(attrs, [:email_verified_at])
    |> validate_required([:email_verified_at])
  end

  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [:password, :current_password])
    |> validate_required([:password, :current_password])
    |> validate_current_password()
    |> put_password_hash()
  end

  def email_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :current_password])
    |> validate_required([:email, :current_password])
    |> unique_constraint(:email)
    |> validate_current_password()
    |> put_downcase_email()
  end

  def roles_changeset(user, attrs) do
    user
    |> cast(attrs, [])
    # |> put_assoc(:roles, get_roles(attrs))
  end

  #defp get_roles(%{"roles" => ids}), do: RolesService.get_roles(ids)
  #defp get_roles(_), do: []

  def validate_current_password(%Ecto.Changeset{valid?: true} = changeset) do
    current_password = get_change(changeset, :current_password)
    password_hash = get_field(changeset, :password_hash)
    if Bcrypt.verify_pass(current_password, password_hash) do
      changeset
    else
      add_error(changeset, :current_password, "invalid current password")
    end
  end

  def validate_current_password(changeset), do: changeset

  def put_password_hash(%Ecto.Changeset{valid?: true} = changeset) do
    case get_change(changeset, :password) do
      nil ->
        changeset
      password ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    end
  end

  def put_password_hash(changeset), do: changeset

  def put_downcase_email(%Ecto.Changeset{valid?: true} = changeset) do
    email = changeset
    |> get_field(:email)
    |> String.downcase()

    put_change(changeset, :email, email)
  end

  def put_downcase_email(changeset), do: changeset
end
