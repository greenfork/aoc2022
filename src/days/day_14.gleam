import gleam/iterator.{Done, Next}
import gleam/string
import gleam/int
import gleam/list
import gleam/function
import gleam/bool
import gleam/io
import gleam/result
import gleam/set.{Set}

pub type Pos {
  Pos(x: Int, y: Int)
}

pub type Rocks =
  Set(Pos)

pub type Sand =
  Set(Pos)

pub type Dimensions {
  Dimensions(x_start: Int, x_end: Int, y_end: Int)
}

const start = Pos(500, 0)

pub fn pt_1(input: String) {
  let #(rocks, dimensions) = parse(input)
  let sand = fill_with_sand(rocks, dimensions.y_end, False)
  // draw(dimensions, rocks, sand, False)
  set.size(sand)
}

pub fn pt_2(input: String) {
  let #(rocks, dimensions) = parse(input)
  let y_end = dimensions.y_end + 2
  let sand = fill_with_sand(rocks, y_end, True)
  // draw(
  //   Dimensions(x_start: 500 - y_end, x_end: 500 + y_end, y_end: y_end),
  //   rocks,
  //   sand,
  //   True,
  // )
  set.size(sand)
}

fn fill_with_sand(rocks: Rocks, bottom_line: Int, finite_bottom: Bool) -> Sand {
  let sand =
    iterator.iterate(
      Ok(set.new()),
      fn(sand) -> Result(Sand, Sand) {
        let sand = result.unwrap_both(sand)
        case finite_bottom {
          False ->
            case fall(rocks, sand, bottom_line, False, start) {
              Ok(new_grain) -> Ok(set.insert(sand, new_grain))
              Error(Nil) -> Error(sand)
            }
          True -> {
            assert Ok(new_grain) = fall(rocks, sand, bottom_line, True, start)
            let sand = set.insert(sand, new_grain)
            case new_grain == start {
              True -> Error(sand)
              False -> Ok(sand)
            }
          }
        }
      },
    )
    |> iterator.find(result.is_error)
  assert Ok(Error(sand)) = sand
  sand
}

fn fall(
  rocks: Rocks,
  sand: Sand,
  bottom_line: Int,
  bottom_is_rock: Bool,
  grain: Pos,
) -> Result(Pos, Nil) {
  let is_free = fn(pos) -> Bool {
    case set.contains(rocks, pos) {
      True -> False
      False ->
        case set.contains(sand, pos) {
          True -> False
          False ->
            case bottom_is_rock {
              False -> True
              True -> pos.y != bottom_line
            }
        }
    }
  }
  let add = fn(pos1: Pos, pos2: Pos) -> Pos {
    Pos(pos1.x + pos2.x, pos1.y + pos2.y)
  }
  let new_grain =
    [add(grain, Pos(0, 1)), add(grain, Pos(-1, 1)), add(grain, Pos(1, 1))]
    |> list.find(is_free)

  case new_grain {
    Error(Nil) -> Ok(grain)
    Ok(new_grain) ->
      case new_grain.y == bottom_line {
        True -> Error(Nil)
        False -> fall(rocks, sand, bottom_line, bottom_is_rock, new_grain)
      }
  }
}

fn parse(input: String) -> #(Rocks, Dimensions) {
  let patch_dimensions = fn(dimensions: Dimensions, pos1: Pos, pos2: Pos) -> Dimensions {
    Dimensions(
      x_start: dimensions.x_start
      |> int.min(pos1.x)
      |> int.min(pos2.x),
      x_end: dimensions.x_end
      |> int.max(pos1.x)
      |> int.max(pos2.x),
      y_end: dimensions.y_end
      |> int.max(pos1.y)
      |> int.max(pos2.y),
    )
  }
  string.split(input, "\n")
  |> iterator.from_list
  |> iterator.filter(function.compose(string.is_empty(_), bool.negate))
  |> iterator.flat_map(fn(line) {
    string.split(line, " -> ")
    |> iterator.unfold(fn(list) {
      case list {
        [_] -> Done
        [a, b, ..rest] -> Next([a, b], [b, ..rest])
      }
    })
  })
  |> iterator.map(fn(pair) {
    assert [Ok(x1), Ok(y1), Ok(x2), Ok(y2)] =
      list.map(pair, string.split(_, ","))
      |> list.flatten
      |> list.map(int.parse)
    #(Pos(x1, y1), Pos(x2, y2))
  })
  |> iterator.fold(
    #(set.new(), Dimensions(x_start: 1000, x_end: 0, y_end: 0)),
    fn(memo, pair) {
      let #(rocks, dimensions) = memo
      let #(pos1, pos2) = pair
      case pos1.x == pos2.x {
        True -> {
          let rocks =
            list.range(pos1.y, pos2.y)
            |> list.fold(
              rocks,
              fn(rocks, y) { set.insert(rocks, Pos(pos1.x, y)) },
            )
          #(rocks, patch_dimensions(dimensions, pos1, pos2))
        }
        False -> {
          let rocks =
            list.range(pos1.x, pos2.x)
            |> list.fold(
              rocks,
              fn(rocks, x) { set.insert(rocks, Pos(x, pos1.y)) },
            )
          #(rocks, patch_dimensions(dimensions, pos1, pos2))
        }
      }
    },
  )
}

pub fn draw(
  dimensions: Dimensions,
  rocks: Rocks,
  sand: Sand,
  with_bottom_line: Bool,
) -> Nil {
  iterator.range(0, dimensions.y_end)
  |> iterator.map(fn(y) {
    iterator.range(dimensions.x_start - 1, dimensions.x_end + 1)
    |> iterator.map(fn(x) {
      case with_bottom_line && dimensions.y_end == y {
        True -> io.print("#")
        False ->
          case set.contains(rocks, Pos(x, y)) {
            True -> io.print("#")
            False ->
              case set.contains(sand, Pos(x, y)) {
                True -> io.print("o")
                False ->
                  case Pos(x, y) == Pos(500, 0) {
                    True -> io.print("+")
                    False -> io.print(".")
                  }
              }
          }
      }
    })
    |> iterator.run()
    io.print("\n")
  })
  |> iterator.run
}
