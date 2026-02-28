import gleam/dynamic.{type Dynamic}
import gleam/option.{type Option}

// -- Language Model --

pub type LanguageModel {
  LanguageModel(provider: String, model_id: String)
}

// -- Message Types --

pub type UserContentPart {
  UserText(text: String)
  UserImage(image: String, media_type: Option(String))
  UserFile(data: String, media_type: String)
}

pub type AssistantContentPart {
  AssistantText(text: String)
  AssistantFile(data: String, media_type: String)
  AssistantReasoning(text: String)
  AssistantToolCall(
    tool_call_id: String,
    tool_name: String,
    input: Dynamic,
  )
}

pub type ToolResultPart {
  ToolResultPart(
    tool_call_id: String,
    tool_name: String,
    output: Dynamic,
    is_error: Option(Bool),
  )
}

pub type Message {
  SystemMessage(content: String)
  UserMessage(content: List(UserContentPart))
  AssistantMessage(content: List(AssistantContentPart))
  ToolMessage(content: List(ToolResultPart))
}

// -- Tool Types --

pub type Tool {
  Tool(
    description: Option(String),
    input_schema: Dynamic,
    execute: Option(fn(Dynamic) -> Dynamic),
  )
}

pub type ToolChoice {
  Auto
  None
  Required
  SpecificTool(tool_name: String)
}

// -- Configuration Types --

pub type Timeout {
  TimeoutMs(Int)
  TimeoutConfig(total_ms: Option(Int), step_ms: Option(Int))
}

pub type Output {
  TextOutput
  ObjectOutput(
    schema: Dynamic,
    name: Option(String),
    description: Option(String),
  )
  ArrayOutput(
    element: Dynamic,
    name: Option(String),
    description: Option(String),
  )
  ChoiceOutput(
    options: List(String),
    name: Option(String),
    description: Option(String),
  )
  JsonOutput(name: Option(String), description: Option(String))
}

pub type StopCondition {
  StepCountIs(Int)
  HasToolCall(tool_name: String)
  HasNoToolCalls
  HasContent
}

// -- Input Types --

pub type Prompt {
  TextPrompt(String)
  MessagesPrompt(List(Message))
}
