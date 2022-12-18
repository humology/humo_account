defmodule HumoAccount.UsersService do
  @moduledoc """
  The UsersService context.
  """

  import Ecto.Query, warn: false
  alias Humo.Repo

  alias Humo.Authorizer
  alias HumoAccount.UsersService.User

  @doc """
  Returns list of users by page, size and optional search query.

  ## Examples

      iex> page_users(authorization, page, size, search)
      [%User{}, ...]

  """
  def page_users(authorization, page, size, search) do
    Authorizer.can_all(authorization, "read", User)
    |> match_search(search)
    |> sort_by_inserted_at()
    |> paginate(page, size)
    |> Repo.all()
  end

  @doc """
  Returns users count by optional search query.

  ## Examples

      iex> count_users(authorization, search)
      3

  """
  def count_users(authorization, search) do
    Authorizer.can_all(authorization, "read", User)
    |> match_search(search)
    |> do_count_users()
  end

  @doc """
  Gets a single user with roles.

  Returns nil if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{roles: [%Role{}]}

      iex> get_user(456)
      nil

  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_by_email(email)
      %User{}

      iex> get_user_by_email(email)
      nil

  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs) do
    %User{}
    |> User.signup_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates user's profile.

  ## Examples

      iex> update_user_profile(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user_profile(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_profile(%User{} = user, attrs) do
    user
    |> User.profile_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates user's password reset.

  ## Examples

      iex> update_user_reset_password(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user_reset_password(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_reset_password(%User{} = user, attrs) do
    user
    |> User.reset_password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates user's email verified.

  ## Examples

      iex> update_user_email_verified(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user_email_verified(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_email_verified(%User{} = user) do
    user
    |> User.email_verified_changeset(%{email_verified_at: DateTime.utc_now()})
    |> Repo.update()
  end

  @doc """
  Updates user's password.

  ## Examples

      iex> update_user_password(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user_password(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(%User{} = user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates user's email.

  ## Examples

      iex> update_user_email(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user_email(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_email(%User{} = user, attrs) do
    user
    |> User.email_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  defp do_count_users(query) do
    Repo.aggregate(query, :count, :id)
  end

  defp match_search(query, search) when search in [nil, ""] do
    query
  end

  defp match_search(query, search) do
    if is_uuid(search) do
      from u in query,
        where: u.id == ^search
    else
      search = "%#{search}%"

      from u in query,
        where:
          ilike(u.first_name, ^search) or ilike(u.last_name, ^search) or ilike(u.email, ^search)
    end
  end

  defp sort_by_inserted_at(query) do
    from u in query,
      order_by: [desc: u.inserted_at]
  end

  defp paginate(query, page, size) do
    from query,
      limit: ^size,
      offset: ^((page - 1) * size)
  end

  defp is_uuid(str) do
    byte_size(str) == 36 and match?({:ok, _}, Ecto.UUID.cast(str))
  end
end
