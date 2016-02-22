
defmodule EXRequester.Request do
  defstruct [:method, :base_url, :path, :headers_template, :body, :query_keys]

  def new(method: method, path: path), do: %EXRequester.Request{method: method, path: path}

  def add_base_url(request, base_url), do: Map.put(request, :base_url, base_url)

  def add_headers_keys(request, headers_keys), do: Map.put(request, :headers_template, headers_keys)

  def add_body(request, body) do
     Map.put(request, :body, body)
  end

  def add_body(request, params), do: Map.put(request, :body, params[:body])

  def add_query_keys(request, query_keys), do: Map.put(request, :query_keys, query_keys)

  def prepared_url(request, params) do
    full_url =
    params
    |> filter_body
    |> Enum.reduce(request.path, fn ({key, value}, acc) ->
      String.replace(acc, "{#{to_string(key)}}", to_string(value))
    end)
    |> (fn item -> join_parts(request.base_url, item) end).()

    url_query = prepared_query(request, params)

    join_urls(full_url, url_query)
  end

  defp join_urls(url, ""), do: url

  defp join_urls(url, query), do: "#{url}?#{query}"

  def prepared_body(request) do
    _prepared_body(Map.get(request, :body)) || ""
  end

  defp _prepared_body(nil), do: nil

  defp _prepared_body(body) when is_tuple(body) do
    body_to_json(Tuple.to_list(body))
  end

  defp _prepared_body(body) when is_map(body) or is_list(body) do
    body_to_json(body)
  end

  defp _prepared_body(body), do: body

  defp body_to_json(body) do
    case Poison.encode(body) do
      {:ok, json} -> json
      _ -> ""
    end
  end

  def prepared_headers(request, header_params) do
    header_params = header_params |> filter_body
    header_keys = Map.get(request, :headers_template, [])

    Enum.map(header_keys, fn {key, value} ->
      prepare_header_item(template_key: key, template_value: value, header_params: header_params)
    end) || []
  end

  defp prepare_header_item(template_key: key, template_value: value, header_params: header_params)
  when is_binary(value) do
    {key, value}
  end

  defp prepare_header_item(template_key: key, template_value: value, header_params: header_params) do
    {key, header_params[value]}
  end

  def prepared_query(request, params) do
    query_keys = Map.get(request, :query_keys) || []

    params
    |> Enum.filter(fn {key, value} ->
      key in query_keys
    end)
    |> Enum.map(fn {key, value} ->
      "#{key}=#{prepare_query_value(value)}"
    end)
    |> Enum.join("&")
  end

  defp prepare_query_value(value) when is_list(value) do
    Enum.join(value, ",")
  end

  defp prepare_query_value(value), do: value

  defp join_parts(base, path) do
    join_parts(String.slice(base, 0..-2),
    String.slice(base, -1..-1),
    String.slice(path, 0..0),
    String.slice(path, 1..-1))
  end

  defp join_parts(base, "/", "/", path) do
    base <> "/" <> path
  end

  defp join_parts(base, "/", path_start, path) do
    base <> "/" <> path_start <> path
  end

  defp join_parts(base, base_end, "/", path) do
    base <> base_end <> "/" <> path
  end

  defp join_parts(base, base_end, path_start, path) do
    base <> base_end <> "/" <> path_start <> path
  end

  defp filter_body(params) do
    Enum.filter(params, fn {key, value} ->
      key != :body
    end)
  end
end
