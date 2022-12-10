import gleam/string
import gleam/iterator
import gleam/int
import gleam/function
import gleam/bool
import gleam/io

pub fn pt_1(input: String) {
  string.split(input, "\n")
  |> iterator.from_list
  |> iterator.filter(function.compose(string.is_empty(_), bool.negate))
  |> iterator.flat_map(fn(line) {
    case line {
      "noop" -> iterator.from_list(["noop"])
      "addx " <> _ -> iterator.from_list(["noop", line])
    }
  })
  |> iterator.index
  |> iterator.fold(
    #(1, 0),
    fn(memo, idx_op) {
      let #(idx, op) = idx_op
      let sum =
        memo.1 + case idx + 1 {
          20 | 60 | 100 | 140 | 180 | 220 -> memo.0 * { idx + 1 }
          _ -> 0
        }
      let x = case op {
        "noop" -> memo.0
        "addx " <> n -> {
          assert Ok(n) = int.parse(n)
          memo.0 + n
        }
      }
      #(x, sum)
    },
  )
}

pub fn pt_2(input: String) {
  string.split(input, "\n")
  |> iterator.from_list
  |> iterator.filter(function.compose(string.is_empty(_), bool.negate))
  |> iterator.flat_map(fn(line) {
    case line {
      "noop" -> iterator.from_list(["noop"])
      "addx " <> _ -> iterator.from_list(["noop", line])
    }
  })
  |> iterator.index
  |> iterator.fold(
    1,
    fn(memo, idx_op) {
      let #(idx, op) = idx_op
      case idx == memo - 1 || idx == memo || idx == memo + 1 {
        True -> io.print("#")
        False -> io.print(".")
      }
      let memo = case idx {
        39 | 79 | 119 | 159 | 199 | 239 -> {
          io.print("\n")
          memo + 40
        }
        _ -> memo
      }
      case op {
        "noop" -> memo
        "addx " <> n -> {
          assert Ok(n) = int.parse(n)
          memo + n
        }
      }
    },
  )
}
