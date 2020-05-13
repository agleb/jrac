defmodule JracTest do
  use ExUnit.Case

  use Jrac.Behaviour,
    app_name: :jrac,
    base_url_key_name: :base_url_key,
    headers: [{"Accept", "application/json"}]

  test "build_url" do
    assert "https://reqres.in/api/test" == JracTest.build_url("test")
  end

  test "build_url/1 guard" do
    assert nil == JracTest.build_url(1)
  end

  test "build_url/2 with map" do
    assert "https://reqres.in/api/test?t=1" == JracTest.build_url("test", %{"t" => 1})
  end

  test "build_url/2 guard" do
    assert nil == JracTest.build_url(1, 1)
    assert nil == JracTest.build_url(1, %{"t" => 1})
  end

  test "do_get_single" do
    assert {:ok,
            %{
              "data" => _data
            }} = JracTest.do_get_single("users", "4")
  end

  test "do_get_page" do
    assert {:ok,
            %{
              "data" => _data
            }} = JracTest.do_get_page("users", %{"page" => "2"})
  end

  test "do_post" do
    params = %{
      "name" => "morpheus",
      "job" => "leader"
    }

    assert {:ok, %{"createdAt" => _, "id" => _}} = JracTest.do_post("users", params)
  end

  test "do_put" do
    params = %{
      "name" => "morpheus",
      "job" => "leader"
    }

    assert {:ok, %{"updatedAt" => _}} = JracTest.do_put("users", "2", params)
  end

  test "do_patch" do
    params = %{
      "name" => "morpheus",
      "job" => "leader"
    }

    assert {:ok, %{"updatedAt" => _}} = JracTest.do_patch("users", "2", params)
  end

  test "do_delete" do
    assert {:ok} = JracTest.do_delete("users", "4")
  end
end
