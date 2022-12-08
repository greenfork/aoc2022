import gleam/map.{Map}
import gleam/string
import gleam/int
import gleam/list
import gleam/result
import gleam/iterator.{Iterator}

pub type Grid {
  Grid(trees: Map(#(Int, Int), Int), dims: #(Int, Int))
}

pub fn pt_1(input: String) {
  let grid = parse(input)
  map.filter(
    grid.trees,
    fn(current_coord, current_height) {
      let is_corner = fn(coord: #(Int, Int), dims: #(Int, Int), fun) {
        case
          coord.0 == 0 || coord.1 == 0 || coord.0 == dims.0 - 1 || coord.1 == dims.1 - 1
        {
          True -> True
          False -> fun()
        }
      }
      use <- is_corner(current_coord, grid.dims)

      let #(top, right, bottom, left) = cross(current_coord, grid.dims)
      let covered = fn(side_iterator: SideIterator) -> Bool {
        side_iterator
        |> iterator.any(fn(coord) {
          assert Ok(height) = map.get(grid.trees, coord)
          height >= current_height
        })
      }
      let covered_from_all_sides =
        covered(top) && covered(right) && covered(bottom) && covered(left)
      !covered_from_all_sides
    },
  )
  |> map.size
}

pub fn pt_2(input: String) {
  let grid = parse(input)
  grid.trees
  |> map.map_values(fn(current_coord, current_height) {
    let #(top, right, bottom, left) = cross(current_coord, grid.dims)
    let count_visible_trees = fn(side_iterator: SideIterator) -> Int {
      side_iterator
      |> iterator.try_fold(
        0,
        fn(memo, coord) {
          case map.get(grid.trees, coord) {
            Error(Nil) -> Error(memo)
            Ok(height) ->
              case height < current_height {
                True -> Ok(memo + 1)
                False -> Error(memo + 1)
              }
          }
        },
      )
      |> result.unwrap_both
    }

    count_visible_trees(top) * count_visible_trees(right) * count_visible_trees(
      bottom,
    ) * count_visible_trees(left)
  })
  |> map.fold(
    0,
    fn(memo, _coord, scenic_score) {
      case scenic_score > memo {
        True -> scenic_score
        False -> memo
      }
    },
  )
}

type SideIterator =
  Iterator(#(Int, Int))

fn cross(
  coord: #(Int, Int),
  dims: #(Int, Int),
) -> #(SideIterator, SideIterator, SideIterator, SideIterator) {
  let top =
    iterator.range(coord.1 - 1, 0)
    |> iterator.map(fn(y) { #(coord.0, y) })
  let bottom =
    iterator.range(coord.1 + 1, dims.1 - 1)
    |> iterator.map(fn(y) { #(coord.0, y) })
  let left =
    iterator.range(coord.0 - 1, 0)
    |> iterator.map(fn(x) { #(x, coord.1) })
  let right =
    iterator.range(coord.0 + 1, dims.0 - 1)
    |> iterator.map(fn(x) { #(x, coord.1) })
  #(top, right, bottom, left)
}

fn parse(input: String) -> Grid {
  let lofl =
    string.split(input, "\n")
    |> iterator.from_list
    |> iterator.filter(fn(line) { !string.is_empty(line) })
    |> iterator.index
    |> iterator.map(fn(y_line) {
      let #(y, line) = y_line
      string.to_graphemes(line)
      |> iterator.from_list
      |> iterator.index
      |> iterator.map(fn(x_digit) {
        let #(x, digit) = x_digit
        assert Ok(digit) = int.parse(digit)
        #(#(x, y), digit)
      })
      |> iterator.to_list
    })
    |> iterator.to_list
  assert [first_line, ..] = lofl
  Grid(
    trees: map.from_list(list.flatten(lofl)),
    dims: #(list.length(first_line), list.length(lofl)),
  )
}
