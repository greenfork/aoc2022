import gleam/string
import gleam/list
import gleam/iterator
// import gleam/io
import gleam/int
import gleam/map.{Map}
import gleam/option.{Some}

pub fn pt_1(input: String) -> String {
  solve(input, move)
}

pub fn pt_2(input: String) -> String {
  solve(input, move2)
}

pub type Stacks =
  Map(Int, List(String))

pub type Move {
  Move(quantity: Int, from: Int, to: Int)
}

fn solve(input: String, move: fn(Stacks, Move) -> Stacks) -> String {
  let #(stacks, moves) = parse(input)
  list.fold(moves, stacks, fn(stacks, m) { move(stacks, m) })
  |> map.to_list
  |> list.sort(fn(a, b) { int.compare(a.0, b.0) })
  |> list.map(fn(stack_pair) {
    assert Ok(item) = list.first(stack_pair.1)
    item
  })
  |> string.join("")
}

fn move(stacks: Stacks, move: Move) -> Stacks {
  do_move(stacks, move.from, move.to, move.quantity)
}

fn do_move(stacks: Stacks, from: Int, to: Int, count: Int) -> Stacks {
  case count {
    0 -> stacks
    _ -> {
      assert Ok(from_stack) = map.get(stacks, from)
      assert Ok(#(item, rest)) = list.pop(from_stack, fn(_) { True })
      let stacks =
        stacks
        |> map.insert(from, rest)
        |> map.update(
          to,
          fn(stack) {
            assert Some(stack) = stack
            [item, ..stack]
          },
        )
      do_move(stacks, from, to, count - 1)
    }
  }
}

fn move2(stacks: Stacks, move: Move) -> Stacks {
  assert Ok(from_stack) = map.get(stacks, move.from)
  assert #(items, rest) = list.split(from_stack, move.quantity)
  stacks
  |> map.insert(move.from, rest)
  |> map.update(
    move.to,
    fn(stack) {
      assert Some(stack) = stack
      list.append(items, stack)
    },
  )
}

fn parse(input: String) -> #(Stacks, List(Move)) {
  assert [stacks, moves] = string.split(input, "\n\n")

  let stacks = string.split(stacks, "\n")

  let stacks =
    list.take(stacks, list.length(stacks) - 1)
    |> list.map(fn(line) {
      string.to_graphemes(line)
      |> list.sized_chunk(4)
      |> list.map(fn(chunk) {
        case list.length(chunk) {
          3 -> chunk
          4 -> list.take(chunk, 3)
        }
      })
      |> list.map(fn(chunk) {
        case chunk {
          ["[", letter, "]"] -> letter
          [" ", " ", " "] -> "."
          _ -> {
            assert True = False
            ""
          }
        }
      })
    })
    |> list.transpose
    |> list.map(fn(stack) { list.filter(stack, fn(item) { item != "." }) })
    |> list.index_fold(
      map.new(),
      fn(memo, stack, idx) { map.insert(memo, idx + 1, stack) },
    )

  let moves =
    moves
    |> string.split("\n")
    |> iterator.from_list
    |> iterator.filter(fn(line) { !string.is_empty(line) })
    |> iterator.map(fn(line) {
      assert [_, quantity, _, from, _, to] = string.split(line, " ")
      assert [Ok(quantity), Ok(from), Ok(to)] =
        list.map([quantity, from, to], int.parse)
      Move(quantity, from, to)
    })
    |> iterator.to_list

  #(stacks, moves)
}
