import gleam/list
import gleam/string
import gleam/bit_string
import gleam/iterator
import gleam/set

pub fn pt_1(input: String) -> Int {
  input
  |> string.split("\n")
  |> iterator.from_list
  |> iterator.filter(fn(s) { !string.is_empty(s) })
  |> iterator.map(fn(line) {
    let #(first, second) =
      string.split(line, "")
      |> list.split(string.length(line) / 2)
    let intersection = intersection(first, second)
    intersection
  })
  |> iterator.fold(0, fn(memo, letter) { memo + value(letter) })
}

fn intersection(a: List(String), b: List(String)) -> String {
  case list.pop(a, fn(_) { True }) {
    Error(Nil) -> {
      assert True = False
      ""
    }
    Ok(#(item, rest)) ->
      case list.find(b, fn(i) { i == item }) {
        Ok(item) -> item
        Error(Nil) -> intersection(rest, b)
      }
  }
}

fn value(s: String) -> Int {
  case bit_string.from_string(s) {
    <<a>> ->
      case a < 97 {
        True -> a - 38
        False -> a - 96
      }
    _ -> {
      assert True = False
      0
    }
  }
}

pub fn pt_2(input: String) -> Int {
  input
  |> string.split("\n")
  |> list.filter(fn(s) { !string.is_empty(s) })
  |> list.sized_chunk(3)
  |> iterator.from_list
  |> iterator.map(fn(three_lines) {
    assert Ok(one_letter_set) =
      three_lines
      |> list.map(fn(line) { set.from_list(string.split(line, "")) })
      |> list.reduce(set.intersection)
    assert 1 = set.size(one_letter_set)
    assert Ok(letter) = list.first(set.to_list(one_letter_set))
    letter
  })
  |> iterator.fold(0, fn(memo, letter) { memo + value(letter) })
}
