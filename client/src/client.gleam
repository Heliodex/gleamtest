import gleam/fetch
import gleam/http
import gleam/http/request
import gleam/io
import gleam/javascript/promise
import gleam/option

fn read_body(res) {
  use body <- promise.await(fetch.read_text_body(res))

  case body {
    Ok(body2) -> Ok(body2.body)
    Error(_) -> Error("Failed to read body")
  }
  |> promise.resolve
}

fn fetch_req(req) {
  use res <- promise.await(fetch.send(req))

  case res {
    Ok(res2) -> read_body(res2)
    Error(_) -> Error("Failed to fetch") |> promise.resolve
  }
  |> promise.resolve
}

fn get() {
  let req =
    request.Request(
      path: "",
      method: http.Get,
      headers: [],
      body: "",
      scheme: http.Http,
      host: "localhost",
      port: option.Some(4000),
      query: option.None,
    )

  fetch_req(req)
}

pub fn main() {
  io.println("Hello from client!")

  use p1 <- promise.await(get())
  use res <- promise.await(p1)

  case res {
    Ok(value) -> io.println(value)
    Error(value) -> io.println("Error: " <> value)
  }

  promise.resolve(Nil)
}
