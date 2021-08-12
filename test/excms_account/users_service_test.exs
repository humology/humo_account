defmodule ExcmsAccount.UsersServiceTest do
  use ExcmsAccount.DataCase

  alias ExcmsAccount.UsersService
  alias ExcmsAccount.UsersService.User

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

  describe "user" do
    test "page_users/3 returns paginated users by optional search query" do
      user = UsersService.get_user!(insert(:user).id)
      user2 = UsersService.get_user!(insert(:user).id)
      user3 = UsersService.get_user!(insert(:user).id)

      assert UsersService.page_users(1, 2, nil) == [user3, user2]
      assert UsersService.page_users(2, 2, nil) == [user]
      assert UsersService.page_users(1, 5, user.email) == [user]
      assert UsersService.page_users(1, 5, user.id) == [user]
      assert UsersService.page_users(1, 5, "some wrong search query") == []
    end

    test "count_users/1 returns user count by optional search query" do
      user = insert(:user)
      insert(:user)

      assert UsersService.count_users(nil) == 2
      assert UsersService.count_users(user.email) == 1
      assert UsersService.count_users(user.id) == 1
      assert UsersService.count_users("some wrong search query") == 0
    end

    test "get_user!/1 returns a user" do
      user = UsersService.get_user!(insert(:user).id)

      assert user == UsersService.get_user!(user.id)
    end

    test "get_user_by_email/1 returns a user by email" do
      user = UsersService.get_user!(insert(:user).id)

      assert user == UsersService.get_user_by_email(user.email)
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = UsersService.create_user(@valid_attrs)
      assert user.email == "some@test.invalid"
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
      assert Bcrypt.verify_pass("some password", user.password_hash)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UsersService.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user)
      assert {:ok, %User{} = user} = UsersService.update_user(user, @update_attrs)
      assert user.email == "updated@test.invalid"
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
      refute Bcrypt.verify_pass("updated password", user.password_hash)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = UsersService.get_user!(insert(:user).id)
      assert {:error, %Ecto.Changeset{}} = UsersService.update_user(user, @invalid_attrs)
      assert user == UsersService.get_user!(user.id)
    end

    test "update_user_profile/2 with valid data updates the user" do
      user = insert(:user)
      assert {:ok, %User{} = user} = UsersService.update_user_profile(user, @update_attrs)
      refute user.email == "updated@test.invalid"
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
      refute Bcrypt.verify_pass("updated password", user.password_hash)
    end

    test "update_user_profile/2 with invalid data returns error changeset" do
      user = UsersService.get_user!(insert(:user).id)
      assert {:error, %Ecto.Changeset{}} = UsersService.update_user_profile(user, @invalid_attrs)
      assert user == UsersService.get_user!(user.id)
    end

    test "update_user_reset_password/2 with valid data updates the user" do
      user = insert(:user)
      assert {:ok, %User{} = user} = UsersService.update_user_reset_password(user, @update_attrs)
      refute user.email == "updated@test.invalid"
      refute user.first_name == "some updated first_name"
      refute user.last_name == "some updated last_name"
      assert Bcrypt.verify_pass("updated password", user.password_hash)
    end

    test "update_user_reset_password/2 with invalid data returns error changeset" do
      user = UsersService.get_user!(insert(:user).id)

      assert {:error, %Ecto.Changeset{}} =
               UsersService.update_user_reset_password(user, @invalid_attrs)

      assert user == UsersService.get_user!(user.id)
    end

    test "update_user_email_verified/1 with valid data updates the user" do
      user = insert(:user)
      assert {:ok, %User{} = user} = UsersService.update_user_email_verified(user)
      assert user.email_verified_at
    end

    test "update_user_password/2 with valid data updates the user" do
      user = insert(:user)
      assert {:ok, %User{} = user} = UsersService.update_user_password(user, @update_attrs)
      refute user.email == "updated@test.invalid"
      refute user.first_name == "some updated first_name"
      refute user.last_name == "some updated last_name"
      assert Bcrypt.verify_pass("updated password", user.password_hash)
    end

    test "update_user_password/2 with wrong current password returns error changeset" do
      user = insert(:user)
      attrs = %{@update_attrs | current_password: "wrong password"}
      assert {:error, %Ecto.Changeset{}} = UsersService.update_user_password(user, attrs)

      user = UsersService.get_user!(user.id)

      refute user.email == "updated@test.invalid"
      refute user.first_name == "some updated first_name"
      refute user.last_name == "some updated last_name"
      refute Bcrypt.verify_pass("updated password", user.password_hash)
    end

    test "update_user_password/2 with invalid data returns error changeset" do
      user = UsersService.get_user!(insert(:user).id)
      assert {:error, %Ecto.Changeset{}} = UsersService.update_user_password(user, @invalid_attrs)
      assert user == UsersService.get_user!(user.id)
    end

    test "update_user_email/2 with valid data updates the user" do
      user = insert(:user)
      assert {:ok, %User{} = user} = UsersService.update_user_email(user, @update_attrs)
      assert user.email == "updated@test.invalid"
      refute user.first_name == "some updated first_name"
      refute user.last_name == "some updated last_name"
      refute Bcrypt.verify_pass("updated password", user.password_hash)
    end

    test "update_user_email/2 with invalid data returns error changeset" do
      user = UsersService.get_user!(insert(:user).id)
      assert {:error, %Ecto.Changeset{}} = UsersService.update_user_email(user, @invalid_attrs)
      assert user == UsersService.get_user!(user.id)
    end

    test "delete_user/1 deletes user" do
      user = insert(:user)

      UsersService.delete_user(user)

      assert_raise Ecto.NoResultsError, fn ->
        UsersService.get_user!(user.id)
      end
    end

    test "change_user/1 returns a user changeset" do
      user = insert(:user)
      assert %Ecto.Changeset{} = UsersService.change_user(user)
    end
  end
end
