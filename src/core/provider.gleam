import gleam/option.{type Option}

import core/types.{type Message}

pub type GenerateRequest {
  GenerateRequest(system: Option(String), messages: List(Message))
}

pub type GenerateResponse {
  GenerateResponse(text: String)
}

pub type GenerateError {
  GenerateError(message: String)
}

pub type LanguageModel {
  LanguageModel(
    provider: String,
    model_id: String,
    do_generate: fn(GenerateRequest) -> Result(GenerateResponse, GenerateError),
  )
}
