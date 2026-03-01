import gleam/list
import gleam/option.{None, Some}
import gleeunit
import gleeunit/should

import core/generate_text.{GenerateTextParams}
import core/provider
import core/types

pub fn main() -> Nil {
  gleeunit.main()
}

fn mock_model(
  handler: fn(provider.GenerateRequest) ->
    Result(provider.GenerateResponse, provider.GenerateError),
) -> provider.LanguageModel {
  provider.LanguageModel(
    provider: "mock",
    model_id: "mock-1",
    do_generate: handler,
  )
}

pub fn generate_text_with_text_prompt_test() {
  let model =
    mock_model(fn(request) {
      request.system |> should.equal(None)
      request.messages |> list.length |> should.equal(1)
      let assert [types.UserMessage([types.UserText(text)])] = request.messages
      text |> should.equal("Hello")
      Ok(provider.GenerateResponse(text: "Hi there"))
    })

  generate_text.generate_text(GenerateTextParams(
    model: model,
    system: None,
    prompt: types.TextPrompt("Hello"),
  ))
  |> should.be_ok
  |> fn(res) { res.text }
  |> should.equal("Hi there")
}

pub fn generate_text_with_system_prompt_test() {
  let model =
    mock_model(fn(request) {
      request.system |> should.equal(Some("You are helpful."))
      let assert [types.UserMessage([types.UserText(text)])] = request.messages
      text |> should.equal("Hi")
      Ok(provider.GenerateResponse(text: "Hello!"))
    })

  generate_text.generate_text(GenerateTextParams(
    model: model,
    system: Some("You are helpful."),
    prompt: types.TextPrompt("Hi"),
  ))
  |> should.be_ok
  |> fn(res) { res.text }
  |> should.equal("Hello!")
}

pub fn generate_text_with_messages_prompt_test() {
  let messages = [
    types.UserMessage([types.UserText("What is 2+2?")]),
    types.AssistantMessage([types.AssistantText("4")]),
    types.UserMessage([types.UserText("And 3+3?")]),
  ]

  let model =
    mock_model(fn(request) {
      request.messages |> list.length |> should.equal(3)
      Ok(provider.GenerateResponse(text: "6"))
    })

  generate_text.generate_text(GenerateTextParams(
    model: model,
    system: None,
    prompt: types.MessagesPrompt(messages),
  ))
  |> should.be_ok
  |> fn(res) { res.text }
  |> should.equal("6")
}

pub fn generate_text_returns_error_from_model_test() {
  let model =
    mock_model(fn(_request) {
      Error(provider.GenerateError(message: "API key invalid"))
    })

  generate_text.generate_text(GenerateTextParams(
    model: model,
    system: None,
    prompt: types.TextPrompt("Hello"),
  ))
  |> should.be_error
  |> fn(err) { err.message }
  |> should.equal("API key invalid")
}
