import gleam/string
import gleam/iterator.{Done, Next}
import gleam/list
import gleam/pair
import gleam/io
import gleam/int
import gleam/set

pub fn pt_1(input: String) -> Int {
  input
  |> string.to_graphemes()
  |> iterator.unfold(fn(xs) {
    case list.length(xs) < 4 {
      True -> Done
      False -> Next(element: list.take(xs, 4), accumulator: list.drop(xs, 1))
    }
  })
  |> iterator.index
  |> iterator.find(fn(idx_xs) {
    case idx_xs.1 {
      [a, b, c, d] if a != b && a != c && a != d && b != c && b != d && c != d ->
        True
      _ -> False
    }
  })
  |> force_unwrap
  |> pair.first
  |> int.add(4)
}

fn force_unwrap(result: Result(a, b)) -> a {
  assert Ok(a) = result
  a
}

pub fn pt_2(input: String) -> Int {
  input
  |> string.to_graphemes()
  |> iterator.unfold(fn(xs) {
    case list.length(xs) < 14 {
      True -> Done
      False -> Next(element: list.take(xs, 14), accumulator: list.drop(xs, 1))
    }
  })
  |> iterator.index
  |> iterator.find(fn(idx_xs) {
    case set.size(set.from_list(idx_xs.1)) {
      14 -> True
      _ -> False
    }
  })
  |> force_unwrap
  |> pair.first
  |> int.add(14)
}
