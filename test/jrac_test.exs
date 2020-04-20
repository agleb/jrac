defmodule JracTest do
  use ExUnit.Case
  doctest Jrac

  test "do_get_single" do
    assert {:ok,
            %{
              "data" => _data
            }} = Jrac.do_get_single("users", "4")
  end

  test "do_get_page" do
    assert {:ok,
            %{
              "data" => _data
            }} = Jrac.do_get_page("users", %{"page" => "2"})
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

    assert {:ok, %{"updatedAt" => _}} = Jrac.do_put("users", "2", params)
  end

  test "do_patch" do
    params = %{
      "name" => "morpheus",
      "job" => "leader"
    }

    assert {:ok, %{"updatedAt" => _}} = Jrac.do_patch("users", "2", params)
  end

  test "do_delete" do
    assert {:ok} = Jrac.do_delete("users", "4")
  end
end
