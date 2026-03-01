@external(erlang, "http_ffi", "post")
pub fn post(
  url: String,
  headers: List(#(String, String)),
  body: String,
) -> Result(String, String)
