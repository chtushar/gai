import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/option.{type Option}

import core/types.{
  type LanguageModel, type Output, type Prompt, type StopCondition,
  type Timeout, type Tool, type ToolChoice,
}

pub type GenerateTextParams {
  GenerateTextParams(
    model: LanguageModel,
    system: Option(String),
    prompt: Prompt,
    tools: Option(Dict(String, Tool)),
    tool_choice: Option(ToolChoice),
    max_output_tokens: Option(Int),
    temperature: Option(Float),
    top_p: Option(Float),
    top_k: Option(Int),
    presence_penalty: Option(Float),
    frequency_penalty: Option(Float),
    stop_sequences: Option(List(String)),
    seed: Option(Int),
    max_retries: Option(Int),
    timeout: Option(Timeout),
    headers: Option(Dict(String, String)),
    provider_options: Option(Dict(String, Dynamic)),
    active_tools: Option(List(String)),
    stop_when: Option(List(StopCondition)),
    output: Option(Output),
  )
}

pub fn generate_text(params: GenerateTextParams) {
  todo
}
