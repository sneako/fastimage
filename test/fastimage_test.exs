defmodule FastimageTest do
  use ExUnit.Case, async: true

  @expected_size %Fastimage.Dimensions{width: 283, height: 142}
  @fastimage_task_timeout 1_500

  @jpg_url "https://raw.githubusercontent.com/stephenmoloney/fastimage/master/priv/test.jpg"
  @jpg_url_with_query "https://avatars0.githubusercontent.com/u/12668653?v=2&s=40"
  @jpg_with_redirect "http://seanmoloney.com/images/cover1.jpg"
  @png_url "https://raw.githubusercontent.com/stephenmoloney/fastimage/master/priv/test.png"
  @gif_url "https://raw.githubusercontent.com/stephenmoloney/fastimage/master/priv/test.gif"
  @bmp_url "https://raw.githubusercontent.com/stephenmoloney/fastimage/master/priv/test.bmp"

  @jpg_file "./priv/test.jpg"
  @png_file "./priv/test.png"
  @gif_file "./priv/test.gif"
  @bmp_file "./priv/test.bmp"

  test "Get type and size of remote jpeg url" do
    actual_type = Fastimage.type(@jpg_url)
    actual_size = Fastimage.size(@jpg_url)

    expected_type = {:ok, "jpeg"}
    expected_size = {:ok, @expected_size}

    assert(actual_type == expected_type)
    assert(actual_size == expected_size)
  end

  test "Get type and size of remote image with query in url" do
    actual_type = Fastimage.type(@jpg_url_with_query)
    expected_type = {:ok, "jpeg"}

    actual_size = Fastimage.size(@jpg_url_with_query)
    expected_size = {:ok, %Fastimage.Dimensions{width: 40, height: 40}}

    assert(actual_type == expected_type)
    assert(actual_size == expected_size)
  end

#  test "Get type and size of local jpeg file" do
#    actual_type = Fastimage.type(@jpg_file)
#    actual_size = Fastimage.size(@jpg_file)
#
#    expected_type = {:ok, "jpeg"}
#    expected_size = {:ok, @expected_size}
#
#    assert(actual_type == expected_type)
#    assert(actual_size == expected_size)
#  end

  test "Get type and size of remote png url" do
    actual_type = Fastimage.type(@png_url)
    actual_size = Fastimage.size(@png_url)

    expected_type = {:ok, "png"}
    expected_size = {:ok, @expected_size}

    assert(actual_type == expected_type)
    assert(actual_size == expected_size)
  end

#  test "Get type and size of local png file" do
#    actual_type = Fastimage.type(@png_file)
#    actual_size = Fastimage.size(@png_file)
#
#    expected_type = {:ok, "png"}
#    expected_size = {:ok, @expected_size}
#
#    assert(actual_type == expected_type)
#    assert(actual_size == expected_size)
#  end

  test "Get type and size of remote gif url" do
    actual_type = Fastimage.type(@gif_url)
    actual_size = Fastimage.size(@gif_url)

    expected_type = {:ok, "gif"}
    expected_size = {:ok, @expected_size}

    assert(actual_type == expected_type)
    assert(actual_size == expected_size)
  end

#  test "Get type and size of local gif file" do
#    actual_type = Fastimage.type(@gif_file)
#    actual_size = Fastimage.size(@gif_file)
#
#    expected_type = {:ok, "gif"}
#    expected_size = {:ok, @expected_size}
#
#    assert(actual_type == expected_type)
#    assert(actual_size == expected_size)
#  end

  test "Get type and size of remote bmp url" do
    actual_type = Fastimage.type(@bmp_url)
    actual_size = Fastimage.size(@bmp_url)

    expected_type = {:ok, "bmp"}
    expected_size = {:ok, @expected_size}

    assert(actual_type == expected_type)
    assert(actual_size == expected_size)
  end

#  test "Get type and size of local bmp file" do
#    actual_type = Fastimage.type(@bmp_file)
#    actual_size = Fastimage.size(@bmp_file)
#
#    expected_type = {:ok, "bmp"}
#    expected_size = {:ok, @expected_size}
#
#    assert(actual_type == expected_type)
#    assert(actual_size == expected_size)
#  end

  test "Get the size of multiple image files synchronously" do
    list_results =
      list()
      |> Enum.map(fn image -> Kernel.elem(Fastimage.size(image), 1) end)

    assert(list_results, list_expected_results())
  end

  test "Get the size of multiple image files asynchronously" do
    list_results =
      list()
      |> Enum.map(&Task.async(Fastimage, :size, [&1]))
      |> Enum.map(&handle_task/1)

    assert(list_results, list_expected_results())
  end

  test "Get the size of an image behind a redirect" do
    actual_size = Fastimage.size(@jpg_with_redirect)
    expected_size = {:ok, %Fastimage.Dimensions{width: 1200, height: 1230}}

    assert(actual_size == expected_size)
  end

  # private

  defp list do
    Enum.reduce(1..10, [], fn _i, acc ->
      Enum.concat(acc, [
        @jpg_url,
        @jpg_url_with_query,
        @jpg_with_redirect,
        @png_url,
        @gif_url,
        @bmp_url
      ])
    end)
  end

  defp list_expected_results do
    result = [
      %Fastimage.Dimensions{width: 283, height: 142},
      %Fastimage.Dimensions{width: 40, height: 40},
      %Fastimage.Dimensions{width: 1200, height: 1230},
      %Fastimage.Dimensions{width: 283, height: 142},
      %Fastimage.Dimensions{width: 283, height: 142},
      %Fastimage.Dimensions{width: 283, height: 142}
    ]

    Enum.reduce(1..10, [], fn _i, acc ->
      Enum.concat(acc, result)
    end)
  end

  defp handle_task(task) do
    with {:ok, {:error, error}} <-
           Task.yield(task, @fastimage_task_timeout) || Task.shutdown(task) do
      Og.log(error, __ENV__, :error)
      nil
    else
      {:ok, val} ->
        val

      _ ->
        nil
    end
  end
end


#defmodule FastimageTest do
#  use ExUnit.Case
#  @expected_size %{width: 283, height: 142}
#
#  @jpg_url "https://raw.githubusercontent.com/stephenmoloney/fastimage/master/priv/test.jpg"
#  @jpg_url_with_query "https://avatars0.githubusercontent.com/u/12668653?v=2&s=40"
#  @jpg_with_redirect "http://seanmoloney.com/images/cover1.jpg"
#  @png_url "https://raw.githubusercontent.com/stephenmoloney/fastimage/master/priv/test.png"
#  @gif_url "https://raw.githubusercontent.com/stephenmoloney/fastimage/master/priv/test.gif"
#  @bmp_url "https://raw.githubusercontent.com/stephenmoloney/fastimage/master/priv/test.bmp"
#
#
#  @jpg_file "./priv/test.jpg"
#  @png_file "./priv/test.png"
#  @gif_file "./priv/test.gif"
#  @bmp_file "./priv/test.bmp"
#
#
#  test "Get type and size of remote jpeg url" do
#    assert(Fastimage.type(@jpg_url) == "jpeg")
#    assert(Fastimage.size(@jpg_url) == @expected_size)
#  end
#  test "Get type and size of remote image with query in url" do
#    assert(Fastimage.type(@jpg_url_with_query) == "jpeg")
#    assert(Fastimage.size(@jpg_url_with_query) == %{width: 40, height: 40})
#  end
#  test "Get type and size of local jpeg file" do
#    assert(Fastimage.type(@jpg_file) == "jpeg")
#    assert(Fastimage.size(@jpg_file) == @expected_size)
#  end
#
#
#  test "Get type and size of remote png url" do
#    assert(Fastimage.type(@png_url) == "png")
#    assert(Fastimage.size(@png_url) == @expected_size)
#  end
#  test "Get type and size of local png file" do
#    assert(Fastimage.type(@png_file) == "png")
#    assert(Fastimage.size(@png_file) == @expected_size)
#  end
#
#
#  test "Get type and size of remote gif url" do
#    assert(Fastimage.type(@gif_url) == "gif")
#    assert(Fastimage.size(@gif_url) == @expected_size)
#  end
#  test "Get type and size of local gif file" do
#    assert(Fastimage.type(@gif_file) == "gif")
#    assert(Fastimage.size(@gif_file) == @expected_size)
#  end
#
#
#  test "Get type and size of remote bmp url" do
#    assert(Fastimage.type(@bmp_url) == "bmp")
#    assert(Fastimage.size(@bmp_url) == @expected_size)
#  end
#  test "Get type and size of local bmp file" do
#    assert(Fastimage.type(@bmp_file) == "bmp")
#    assert(Fastimage.size(@bmp_file) == @expected_size)
#  end
#
#
#  test "Get the size of multiple image files synchronously" do
#    list_results = list()
#    |> Enum.map(
#     fn(image) -> Fastimage.size(image) end
#    )
#    assert(list_results, list_expected_results())
#  end
#
#
#  test "Get the size of multiple image files asynchronously" do
#    list_results = list()
#    |> Enum.map(
#      &Task.async(Fastimage, :size, [&1])
#    )
#    |> Enum.map(
#      &Task.await(&1, 10000)
#    )
#
#    assert(list_results, list_expected_results())
#  end
#
#
#  test "Get the size of an image behind a redirect" do
#    assert(Fastimage.size(@jpg_with_redirect) == %{width: 1200, height: 1230})
#  end
#
#
#  # private
#
#
#  defp list() do
#    Enum.reduce(1..10, [], fn(_i, acc) ->
#      Enum.concat(acc, [@jpg_url, @jpg_url_with_query, @jpg_with_redirect, @png_url, @gif_url, @bmp_url])
#    end)
#  end
#
#
#  defp list_expected_results() do
#    result = [
#    %{width: 283, height: 142},
#    %{width: 40, height: 40},
#    %{width: 1200, height: 1230},
#    %{width: 283, height: 142},
#    %{width: 283, height: 142},
#    %{width: 283, height: 142}
#    ]
#    Enum.reduce(1..10, [], fn(_i, acc) ->
#      Enum.concat(acc, result)
#    end)
#  end
#
#
#end
