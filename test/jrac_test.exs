defmodule JracTest do
  use ExUnit.Case
  doctest Jrac

  test "do_get_single" do
    expected = %{
      "avatar" => "https://s3.amazonaws.com/uifaces/faces/twitter/marcoramires/128.jpg",
      "first_name" => "Eve",
      "id" => 4,
      "last_name" => "Holt"
    }

    assert Jrac.do_get_single("users", 4) == {:ok, expected}
  end

  test "do_get_page" do
    expected = %{
      "data" => [
        %{
          "avatar" => "https://s3.amazonaws.com/uifaces/faces/twitter/marcoramires/128.jpg",
          "first_name" => "Eve",
          "id" => 4,
          "last_name" => "Holt"
        },
        %{
          "avatar" => "https://s3.amazonaws.com/uifaces/faces/twitter/stephenmoon/128.jpg",
          "first_name" => "Charles",
          "id" => 5,
          "last_name" => "Morris"
        },
        %{
          "avatar" => "https://s3.amazonaws.com/uifaces/faces/twitter/bigmancho/128.jpg",
          "first_name" => "Tracey",
          "id" => 6,
          "last_name" => "Ramos"
        }
      ],
      "page" => 2,
      "per_page" => 3,
      "total" => 12,
      "total_pages" => 4
    }

    assert Jrac.do_get_page("users", 2) == {:ok, expected}
  end

  test "do_post" do
    params = %{
      "name" => "morpheus",
      "job" => "leader"
    }

    assert {:ok, %{"createdAt" => _, "id" => _}} = Jrac.do_post("users", params)
  end

  test "do_put" do
    params = %{
      "name" => "morpheus",
      "job" => "leader"
    }

    assert {:ok, %{"updatedAt" => _}} = Jrac.do_put("users", 2, params)
  end

  test "do_patch" do
    params = %{
      "name" => "morpheus",
      "job" => "leader"
    }

    assert {:ok, %{"updatedAt" => _}} = Jrac.do_patch("users", 2, params)
  end

  test "do_delete" do
    assert {:ok} = Jrac.do_delete("users", 4)
  end
end
