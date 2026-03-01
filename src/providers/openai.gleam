import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/result

import core/http
import core/provider
import core/types

pub fn openai(api_key: String, model_id: String) -> provider.LanguageModel {
  provider.LanguageModel(
    provider: "openai",
    model_id: model_id,
    do_generate: fn(request) { do_generate(api_key, model_id, request) },
  )
}

fn do_generate(
  api_key: String,
  model_id: String,
  request: provider.GenerateRequest,
) -> Result(provider.GenerateResponse, provider.GenerateError) {
  let messages = build_messages(request)
  let body =
    json.object([
      #("model", json.string(model_id)),
      #("messages", json.preprocessed_array(messages)),
    ])
    |> json.to_string

  let headers = [
    #("authorization", "Bearer " <> api_key),
    #("content-type", "application/json"),
  ]

  http.post("https://api.openai.com/v1/chat/completions", headers, body)
  |> result.map_error(fn(e) { provider.GenerateError(message: e) })
  |> result.try(parse_response)
}

fn build_messages(request: provider.GenerateRequest) -> List(json.Json) {
  let system_messages = case request.system {
    Some(system) -> [
      json.object([
        #("role", json.string("system")),
        #("content", json.string(system)),
      ]),
    ]
    None -> []
  }

  let chat_messages = list.map(request.messages, message_to_json)

  list.append(system_messages, chat_messages)
}

fn message_to_json(message: types.Message) -> json.Json {
  case message {
    types.SystemMessage(content) ->
      json.object([
        #("role", json.string("system")),
        #("content", json.string(content)),
      ])
    types.UserMessage(parts) ->
      json.object([
        #("role", json.string("user")),
        #("content", json.string(user_parts_to_text(parts))),
      ])
    types.AssistantMessage(parts) ->
      json.object([
        #("role", json.string("assistant")),
        #("content", json.string(assistant_parts_to_text(parts))),
      ])
    types.ToolMessage(_) ->
      json.object([
        #("role", json.string("tool")),
        #("content", json.string("")),
      ])
  }
}

fn user_parts_to_text(parts: List(types.UserContentPart)) -> String {
  list.filter_map(parts, fn(part) {
    case part {
      types.UserText(text) -> Ok(text)
      _ -> Error(Nil)
    }
  })
  |> join_strings
}

fn assistant_parts_to_text(parts: List(types.AssistantContentPart)) -> String {
  list.filter_map(parts, fn(part) {
    case part {
      types.AssistantText(text) -> Ok(text)
      _ -> Error(Nil)
    }
  })
  |> join_strings
}

fn join_strings(strings: List(String)) -> String {
  list.fold(strings, "", fn(acc, s) {
    case acc {
      "" -> s
      _ -> acc <> " " <> s
    }
  })
}

type Choice {
  Choice(content: String)
}

type ChatResponse {
  ChatResponse(choices: List(Choice))
}

fn parse_response(
  body: String,
) -> Result(provider.GenerateResponse, provider.GenerateError) {
  let choice_decoder = {
    use content <-
      decode.field("message", decode.at(["content"], decode.string), _)
    decode.success(Choice(content:))
  }

  let response_decoder = {
    use choices <- decode.field("choices", decode.list(choice_decoder), _)
    decode.success(ChatResponse(choices:))
  }

  case json.parse(body, response_decoder) {
    Ok(ChatResponse(choices: [Choice(content:), ..])) ->
      Ok(provider.GenerateResponse(text: content))
    Ok(_) -> Error(provider.GenerateError(message: "No choices in response"))
    Error(_) ->
      Error(provider.GenerateError(
        message: "Failed to parse response: " <> body,
      ))
  }
}
