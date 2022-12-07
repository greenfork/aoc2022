import gleam/string
import gleam/int
import gleam/iterator

pub fn solve(input: String, fun) -> Int {
  input
  |> string.split("\n")
  |> iterator.from_list
  |> iterator.filter(fn(line) { !string.is_empty(line) })
  |> iterator.map(fn(line) {
    assert [one, two] = string.split(line, ",")
    let parse = fn(s: String) {
      assert [a, b] = string.split(s, "-")
      assert Ok(a) = int.parse(a)
      assert Ok(b) = int.parse(b)
      #(a, b)
    }
    #(parse(one), parse(two))
  })
  |> iterator.filter(fn(pair) { fun(pair.0, pair.1) })
  |> iterator.fold(0, fn(memo, _) { memo + 1 })
}

fn subset(a: #(Int, Int), b: #(Int, Int)) -> Bool {
  a.0 >= b.0 && a.1 <= b.1 || b.0 >= a.0 && b.1 <= a.1
}

fn intersect(a: #(Int, Int), b: #(Int, Int)) -> Bool {
  a.0 <= b.1 && a.1 >= b.0
}

pub fn pt_1(input: String) -> Int {
  solve(input, subset)
}

pub fn pt_2(input: String) -> Int {
  solve(input, intersect)
}
