import gleam/option.{type Option}

import core/provider.{type LanguageModel}
import core/types.{type Prompt}

pub type GenerateTextParams {
  GenerateTextParams(
    model: LanguageModel,
    system: Option(String),
    prompt: Prompt,
  )
}

pub fn generate_text(params: GenerateTextParams) {
  let messages = case params.prompt {
    types.TextPrompt(text) -> [types.UserMessage([types.UserText(text)])]
    types.MessagesPrompt(messages) -> messages
  }

  let request =
    provider.GenerateRequest(system: params.system, messages: messages)

  params.model.do_generate(request)
}
