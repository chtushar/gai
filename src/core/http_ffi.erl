-module(http_ffi).

-export([post/3]).

post(Url, Headers, Body) ->
    ensure_started(inets),
    ensure_started(ssl),
    UrlStr = binary_to_list(Url),
    HeadersList = [{binary_to_list(K), binary_to_list(V)} || {K, V} <- Headers],
    BodyStr = binary_to_list(Body),
    case httpc:request(post,
                       {UrlStr, HeadersList, "application/json", BodyStr},
                       [{ssl, [{verify, verify_none}]}],
                       [])
    of
        {ok, {{_, 200, _}, _, ResponseBody}} ->
            {ok, list_to_binary(ResponseBody)};
        {ok, {{_, StatusCode, _}, _, ResponseBody}} ->
            {error, list_to_binary(io_lib:format("HTTP ~p: ~s", [StatusCode, ResponseBody]))};
        {error, Reason} ->
            {error, list_to_binary(io_lib:format("Request failed: ~p", [Reason]))}
    end.

ensure_started(App) ->
    case application:ensure_all_started(App) of
        {ok, _} ->
            ok;
        {error, {already_started, _}} ->
            ok
    end.
