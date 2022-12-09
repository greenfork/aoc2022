import gleam/string
import gleam/iterator
import gleam/int
import gleam/io
import gleam/list
import gleam/erlang/process
import gleam/set.{Set}

// Standard coordinates.
pub type Pos =
  #(Int, Int)

pub type Grid {
  Grid(snek: Snek, visited: Set(Pos))
}

pub type Snek =
  List(Pos)

pub type Direction {
  Up
  Right
  Down
  Left
}

pub fn pt_1(input: String) {
  solve(input, 2)
}

pub fn pt_2(input: String) {
  solve(input, 10)
}

fn parse_number(n: String) -> Int {
  assert Ok(n) = int.parse(n)
  n
}

fn solve(input: String, length: Int) -> Int {
  let new_grid = Grid(snek: list.repeat(#(0, 0), length), visited: set.new())
  let grid =
    input
    |> string.split("\n")
    |> iterator.from_list
    |> iterator.filter(fn(line) { !string.is_empty(line) })
    |> iterator.flat_map(fn(line) {
      case line {
        "U " <> number ->
          iterator.take(iterator.repeat(Up), parse_number(number))
        "R " <> number ->
          iterator.take(iterator.repeat(Right), parse_number(number))
        "D " <> number ->
          iterator.take(iterator.repeat(Down), parse_number(number))
        "L " <> number ->
          iterator.take(iterator.repeat(Left), parse_number(number))
      }
    })
    |> iterator.fold(new_grid, move)

  set.size(grid.visited)
}

fn move(grid: Grid, dir: Direction) -> Grid {
  // draw_grid(grid)
  // process.sleep(500)

  let record_tail_movement = fn(fun: fn() -> Grid) -> Grid {
    let grid = fun()
    assert Ok(last) = list.last(grid.snek)
    Grid(..grid, visited: set.insert(grid.visited, last))
  }
  use <- record_tail_movement

  assert [head, ..rest] = grid.snek
  let new_snek = do_move(rest, [move_pos(head, dir)])
  Grid(..grid, snek: new_snek)
}

fn do_move(snek: Snek, new_snek: Snek) -> Snek {
  case snek {
    [] -> list.reverse(new_snek)
    [tail, ..rest] -> {
      assert Ok(head) = list.first(new_snek)
      case head == tail || are_adjacent(head, tail) {
        True ->
          list.reverse(snek)
          |> list.append(new_snek)
          |> list.reverse
        False -> do_move(rest, [move_closer(tail, to: head), ..new_snek])
      }
    }
  }
}

fn move_closer(tail: Pos, to head: Pos) -> Pos {
  let cmp = fn(a: Int, b: Int) -> Int {
    case a > b {
      True -> 1
      False -> -1
    }
  }
  case tail, head {
    #(tx, ty), #(hx, hy) if tx == hx -> #(tx, ty + cmp(hy, ty))
    #(tx, ty), #(hx, hy) if ty == hy -> #(tx + cmp(hx, tx), ty)
    #(tx, ty), #(hx, hy) -> #(tx + cmp(hx, tx), ty + cmp(hy, ty))
  }
}

fn move_pos(pos: Pos, direction: Direction) -> Pos {
  case direction {
    Up -> #(pos.0, pos.1 + 1)
    Right -> #(pos.0 + 1, pos.1)
    Down -> #(pos.0, pos.1 - 1)
    Left -> #(pos.0 - 1, pos.1)
  }
}

fn are_adjacent(pos: Pos, another: Pos) -> Bool {
  [
    #(pos.0, pos.1 + 1),
    #(pos.0 + 1, pos.1 + 1),
    #(pos.0 + 1, pos.1),
    #(pos.0 + 1, pos.1 - 1),
    #(pos.0, pos.1 - 1),
    #(pos.0 - 1, pos.1 - 1),
    #(pos.0 - 1, pos.1),
    #(pos.0 - 1, pos.1 + 1),
  ]
  |> set.from_list
  |> set.contains(another)
}

fn draw_grid(grid: Grid) -> Grid {
  io.println("Grid:")
  let it = {
    use y <- iterator.map(iterator.range(0, 25))
    use x <- iterator.map(iterator.range(0, 21))
    #(x, y)
  }
  iterator.map(
    it,
    fn(line_it) {
      iterator.map(
        line_it,
        fn(pos) {
          case find_index(grid.snek, pos) {
            Error(Nil) -> io.print(".")
            Ok(index) ->
              case index {
                _ if index > 0 && index < 9 -> io.print(string.inspect(index))
                9 -> io.print("T")
                0 -> io.print("H")
              }
          }
        },
      )
      |> iterator.run
      io.print("\n")
    },
  )
  |> iterator.run
  grid
}

fn find_index(xs: List(a), elem: a) -> Result(Int, Nil) {
  do_find_index(xs, elem, 0)
}

fn do_find_index(xs, elem, index) -> Result(Int, Nil) {
  case xs {
    [] -> Error(Nil)
    [x, ..] if x == elem -> Ok(index)
    [x, ..rest] -> do_find_index(rest, elem, index + 1)
  }
}
