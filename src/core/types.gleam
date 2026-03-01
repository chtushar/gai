import gleam/dynamic.{type Dynamic}
import gleam/option.{type Option}

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
  AssistantToolCall(tool_call_id: String, tool_name: String, input: Dynamic)
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

// -- Input Types --

pub type Prompt {
  TextPrompt(String)
  MessagesPrompt(List(Message))
}
