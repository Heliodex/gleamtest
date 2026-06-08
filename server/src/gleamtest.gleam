import gleam/bytes_tree
import gleam/erlang/process
import gleam/http.{type Header}
import gleam/http/request.{type Request}
import gleam/http/response.{Response}
import gleam/io
import mist.{type Connection}
import simplifile

fn string_response(status: Int, body: String, headers: List(Header)) {
  Response(
    status: status,
    body: mist.Bytes(bytes_tree.from_string(body)),
    headers: headers,
  )
}

fn handle_request(_: Request(Connection)) {
  let file = simplifile.read("../main.html")

  case file {
    Ok(content) -> string_response(200, content, [])
    Error(_) -> string_response(500, "Failed to read file", [])
  }
}

pub fn main() {
  io.println("Hello from server!")

  let ok =
    mist.new(handle_request)
    |> mist.bind("localhost")
    |> mist.with_ipv6
    |> mist.port(4000)
    |> mist.start

  case ok {
    Error(_) -> io.println("Failed to start server")
    _ -> Nil
  }

  process.sleep_forever()
}
