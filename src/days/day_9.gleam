import gleam/string
import gleam/iterator
import gleam/int
import gleam/set.{Set}

// Standard coordinates.
pub type Pos =
  #(Int, Int)

pub type Grid {
  Grid(head: Pos, tail: Pos, visited: Set(Pos))
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
  let new_grid = Grid(head: #(0, 0), tail: #(0, 0), visited: set.new())
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

fn parse_number(n: String) -> Int {
  assert Ok(n) = int.parse(n)
  n
}

fn move(grid: Grid, dir: Direction) -> Grid {
  let record_tail_movement = fn(fun: fn() -> Grid) -> Grid {
    let grid = fun()
    Grid(..grid, visited: set.insert(grid.visited, grid.tail))
  }
  use <- record_tail_movement

  let grid = Grid(..grid, head: move_pos(grid.head, dir))
  case grid.head == grid.tail || are_adjacent(grid.head, grid.tail) {
    True -> grid
    False -> Grid(..grid, tail: move_closer(grid.tail, to: grid.head))
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

pub fn pt_2(input: String) {
  todo
}
