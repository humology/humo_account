defmodule HumoAccount.UsersServiceTest do
  use HumoAccount.DataCase, async: true

  alias HumoAccount.UsersService
  alias HumoAccount.UsersService.User
  alias Humo.Authorizer.{AllAccess, Mock, NoAccess}

  @valid_attrs %{
    email: "some@teST.invalid",
    first_name: "some first_name",
    last_name: "some last_name",
    password: "some password"
  }
  @update_attrs %{
    email: "uPDated@test.invalid",
    first_name: "some updated first_name",
    last_name: "some updated last_name",
    password: "updated password",
    current_password: "password"
  }
  @invalid_attrs %{
    email: nil,
    first_name: nil,
    last_name: nil,
    password: nil,
    current_password: nil
  }

  describe "page_users/4" do
    setup do
      user = insert(:user, inserted_at: ~N[2022-03-15 00:00:00])
      user2 = insert(:user, email: "user2@example.invalid", inserted_at: ~N[2022-03-16 00:00:00])
      user3 = insert(:user, email: "user3@example.invalid", inserted_at: ~N[2022-03-17 00:00:00])

      %{user: user, user2: user2, user3: user3}
    end

    test "without access returns no users" do
      fn ->
        assert UsersService.page_users(nil, 1, 2, nil) == []
      end
      |> Mock.with_mock(can_all: &NoAccess.can_all/3)
    end

    test "returns 2 users on 1st page", %{user2: user2, user3: user3} do
      fn ->
        assert UsersService.page_users(nil, 1, 2, nil) == [user3, user2]
      end
      |> Mock.with_mock(can_all: &AllAccess.can_all/3)
    end

    test "returns 1 user on 2nd page", %{user: user} do
      fn ->
        assert UsersService.page_users(nil, 2, 2, nil) == [user]
      end
      |> Mock.with_mock(can_all: &AllAccess.can_all/3)
    end

    test "finds user by email", %{user: user} do
      fn ->
        assert UsersService.page_users(nil, 1, 5, user.email) == [user]
      end
      |> Mock.with_mock(can_all: &AllAccess.can_all/3)
    end

    test "finds user by id", %{user: user} do
      fn ->
        assert UsersService.page_users(nil, 1, 5, user.id) == [user]
      end
      |> Mock.with_mock(can_all: &AllAccess.can_all/3)
    end

    test "cannot find user by query" do
      fn ->
        assert UsersService.page_users(nil, 1, 5, "wrong search") == []
      end
      |> Mock.with_mock(can_all: &AllAccess.can_all/3)
    end
  end

  describe "count_users/2" do
    setup do
      user = insert(:user)
      insert(:user, email: "user2@example.invalid")
      %{user: user}
    end

    test "without access returns 0" do
      fn ->
        assert UsersService.count_users(nil, nil) == 0
      end
      |> Mock.with_mock(can_all: &NoAccess.can_all/3)
    end

    test "with all access returns 2" do
      fn ->
        assert UsersService.count_users(nil, nil) == 2
      end
      |> Mock.with_mock(can_all: &AllAccess.can_all/3)
    end

    test "when email matches, returns 1", %{user: user} do
      fn ->
        assert UsersService.count_users(nil, user.email) == 1
      end
      |> Mock.with_mock(can_all: &AllAccess.can_all/3)
    end

    test "when id matches, returns 1", %{user: user} do
      fn ->
        assert UsersService.count_users(nil, user.id) == 1
      end
      |> Mock.with_mock(can_all: &AllAccess.can_all/3)
    end

    test "when query doesn't match, returns 0" do
      fn ->
        assert UsersService.count_users(nil, "wrong query") == 0
      end
      |> Mock.with_mock(can_all: &AllAccess.can_all/3)
    end
  end

  describe "get_user!/1" do
    test "returns existing user by id" do
      user = insert(:user)

      assert user == UsersService.get_user!(user.id)
    end

    test "when cannot find user by id, raises error" do
      assert_raise Ecto.NoResultsError, fn ->
        UsersService.get_user!(Ecto.UUID.generate())
      end
    end
  end

  describe "get_user_by_email/1" do
    test "returns existing user by email" do
      user = insert(:user)

      assert user == UsersService.get_user_by_email(user.email)
    end

    test "when cannot find user by email, returns nil" do
      refute UsersService.get_user_by_email("wrong@example.invalid")
    end
  end

  describe "create_user/1" do
    test "with valid data creates user" do
      assert {:ok, %User{} = user} = UsersService.create_user(@valid_attrs)
      assert user.email == "some@test.invalid"
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
      assert Bcrypt.verify_pass("some password", user.password_hash)
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UsersService.create_user(@invalid_attrs)
    end
  end

  describe "update_user/2" do
    test "with valid data updates user" do
      user = insert(:user)
      assert {:ok, %User{} = user} = UsersService.update_user(user, @update_attrs)
      assert user.email == "updated@test.invalid"
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
      refute Bcrypt.verify_pass("updated password", user.password_hash)
    end

    test "with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = UsersService.update_user(user, @invalid_attrs)
      assert user == UsersService.get_user!(user.id)
    end
  end

  describe "update_user_profile/2" do
    test "with valid data updates user profile" do
      user = insert(:user)
      assert {:ok, %User{} = user} = UsersService.update_user_profile(user, @update_attrs)
      refute user.email == "updated@test.invalid"
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
      refute Bcrypt.verify_pass("updated password", user.password_hash)
    end

    test "with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = UsersService.update_user_profile(user, @invalid_attrs)
      assert user == UsersService.get_user!(user.id)
    end
  end

  describe "update_user_reset_password/2" do
    test "with valid data updates user password" do
      user = insert(:user)
      assert {:ok, %User{} = user} = UsersService.update_user_reset_password(user, @update_attrs)
      refute user.email == "updated@test.invalid"
      refute user.first_name == "some updated first_name"
      refute user.last_name == "some updated last_name"
      assert Bcrypt.verify_pass("updated password", user.password_hash)
    end

    test "with invalid data returns error changeset" do
      user = insert(:user)

      assert {:error, %Ecto.Changeset{}} =
               UsersService.update_user_reset_password(user, @invalid_attrs)

      assert user == UsersService.get_user!(user.id)
    end
  end

  describe "update_user_email_verified/1" do
    test "sets email verified" do
      user = insert(:user)
      assert {:ok, %User{} = user} = UsersService.update_user_email_verified(user)
      assert user.email_verified_at
    end
  end

  describe "update_user_password/2" do
    test "with valid data updates user's password" do
      user = insert(:user)
      assert {:ok, %User{} = user} = UsersService.update_user_password(user, @update_attrs)
      refute user.email == "updated@test.invalid"
      refute user.first_name == "some updated first_name"
      refute user.last_name == "some updated last_name"
      assert Bcrypt.verify_pass("updated password", user.password_hash)
    end

    test "when current password is wrong, returns error changeset" do
      user = insert(:user)
      attrs = %{@update_attrs | current_password: "wrong password"}
      assert {:error, %Ecto.Changeset{}} = UsersService.update_user_password(user, attrs)

      user = UsersService.get_user!(user.id)

      refute user.email == "updated@test.invalid"
      refute user.first_name == "some updated first_name"
      refute user.last_name == "some updated last_name"
      refute Bcrypt.verify_pass("updated password", user.password_hash)
    end

    test "with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = UsersService.update_user_password(user, @invalid_attrs)
      assert user == UsersService.get_user!(user.id)
    end
  end

  describe "update_user_email/2" do
    test "with valid data updates the user" do
      user = insert(:user)
      assert {:ok, %User{} = user} = UsersService.update_user_email(user, @update_attrs)
      assert user.email == "updated@test.invalid"
      refute user.first_name == "some updated first_name"
      refute user.last_name == "some updated last_name"
      refute Bcrypt.verify_pass("updated password", user.password_hash)
    end

    test "with invalid data returns error changeset" do
      user = insert(:user)
      assert {:error, %Ecto.Changeset{}} = UsersService.update_user_email(user, @invalid_attrs)
      assert user == UsersService.get_user!(user.id)
    end
  end

  describe "delete_user/1" do
    test "deletes user" do
      user = insert(:user)

      UsersService.delete_user(user)

      assert_raise Ecto.NoResultsError, fn ->
        UsersService.get_user!(user.id)
      end
    end
  end

  describe "change_user/1" do
    test "returns user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = UsersService.change_user(user)
    end
  end
end
