import gleam/bytes_tree
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{Response}
import gleam/io
import gleam/string
import mist.{type Connection}
import simplifile

fn string_response(status, body, headers) {
  Response(
    status: status,
    body: mist.Bytes(bytes_tree.from_string(body)),
    headers: headers,
  )
}

fn loadfile(filename, headers) {
  let file = simplifile.read(filename)

  case file {
    Ok(content) -> string_response(200, content, headers)
    Error(_) ->
      string_response(404, "File " <> filename <> " not found", headers)
  }
}

fn handle_request(req: Request(Connection)) {
  case req.path {
    "/" ->
      loadfile("../main.html", [
        #("Content-Type", "text/html"),
      ])

    _ ->
      case string.ends_with(req.path, ".mjs") {
        True ->
          // TODO: possible security issue if the path contains loads of ../s
          loadfile("../client/build/dev/javascript/" <> req.path, [
            #("Content-Type", "application/javascript"),
          ])
        _ -> string_response(404, "Not found", [])
      }
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
