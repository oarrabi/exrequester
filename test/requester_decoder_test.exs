
defmodule EXRequester.DEcoderTests do
  use ExUnit.Case

  test "it return error if header keys are missing" do
    defmodule TestAPIA6 do
      use EXRequester

      @put "user/{id}"
      defreq get_status
    end

    res = TestAPIA6.client("https://httpbin.org")
    |> TestAPIA6.get_status(id: 1, decoder: fn response ->
      "before-" <> response.body <> "-after"
    end)

    assert res == "before-123-after"
  end

  test "it return the same response if decoder is not set" do
    defmodule TestAPIA7 do
      use EXRequester

      @put "user/{id}"
      defreq get_status
    end

    res = TestAPIA7.client("https://httpbin.org")
    |> TestAPIA7.get_status(id: 1)

    assert res.body == "123"
  end

  test "it return passes the response to the body" do
    defmodule TestAPIA8 do
      use EXRequester

      @put "user/{id}"

      defreq get_status fn response ->
        "before-" <> response.body <> "-after"
      end
    end

    res = TestAPIA8.client("https://httpbin.org")
    |> TestAPIA8.get_status(id: 1)

    assert res == "before-123-after"
  end

  test "it return passes the response to the body when using body block" do
    defmodule TestAPIA9 do
      use EXRequester

      @put "user/{id}"
      defreq get_status do
        "before-" <> response.body <> "-after"
      end

    end

    res = TestAPIA9.client("https://httpbin.org")
    |> TestAPIA9.get_status(id: 1)

    assert res == "before-123-after"
  end

  test "the decoder passed overwrites the module level decoder" do
    defmodule TestAPIA10 do
      use EXRequester

      @put "user/{id}"
      defreq get_status fn response ->
        "before-" <> response.body <> "-after"
      end

    end

    res = TestAPIA10.client("https://httpbin.org")
    |> TestAPIA10.get_status(id: 1, decoder: fn response ->
      "before2222-" <> response.body <> "-after"
    end)

    assert res == "before2222-123-after"
  end

  test "the decoder passed overwrites the body block used" do
    defmodule TestAPIA11 do
      use EXRequester

      @put "user/{id}"
      defreq get_status do
        "before-" <> response.body <> "-after"
      end

    end

    res = TestAPIA11.client("https://httpbin.org")
    |> TestAPIA11.get_status(id: 1, decoder: fn response ->
      "before2222-" <> response.body <> "-after"
    end)

    assert res == "before2222-123-after"
  end

end
