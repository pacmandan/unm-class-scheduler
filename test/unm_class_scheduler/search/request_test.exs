defmodule UnmClassScheduler.Search.RequestTest do
  @moduledoc false
  use ExUnit.Case, async: true

  alias UnmClassScheduler.Search.Request

  doctest UnmClassScheduler.Search.Request

  test "when all valid parameters are present" do
    params = %{
      "semester" => "202310",
      "campus" => "ABQ",
      "subject" => "CS",
      "course" => "105L",
      "crn" => "50001",
    }
    expected_result = %{
      semester: "202310",
      campus: "ABQ",
      subject: "CS",
      course: "105L",
      crn: "50001",
    }
    assert Request.prepare(params) == {:ok, expected_result}
  end

  test "when some optional parameters are missing" do
    params = %{
      "semester" => "202310",
      "campus" => "ABQ",
    }
    expected_result = %{
      semester: "202310",
      campus: "ABQ",
    }
    assert Request.prepare(params) == {:ok, expected_result}
  end

  test "when an unknown parameter is present" do
    params = %{
      "semester" => "202310",
      "campus" => "ABQ",
      "unknown_key" => "SOME VALUE"
    }
    expected_result = %{
      semester: "202310",
      campus: "ABQ",
    }
    assert Request.prepare(params) == {:ok, expected_result}
  end

  test "when required parameters are missing" do
    params = %{
      "subject" => "CS",
    }
    expected_result = [semester: {"can't be blank", [validation: :required]}]
    assert Request.prepare(params) == {:error, expected_result}
  end
end
