import gleam/iterator
import gleam/map.{Map}
import gleam/queue.{Queue}
import gleam/string
import gleam/function
import gleam/bool
import gleam/list
import gleam/int
import gleam/result

pub type Pos {
  Pos(x: Int, y: Int)
}

pub type Dimensions {
  Dimensions(x: Int, y: Int)
}

pub type Heightmap =
  Map(Pos, Int)

pub type TotalSteps =
  Map(Pos, Int)

pub type PrevPos =
  Map(Pos, Pos)

pub type PQ =
  Queue(Pos)

pub fn pt_1(input: String) {
  let Agg(heightmap, start, end, dimensions) = parse(input)
  let end_steps = find(heightmap, start, end, dimensions)
  end_steps
}

fn find_all_starting_points(heightmap: Heightmap) -> List(Pos) {
  map.fold(
    heightmap,
    [],
    fn(memo, pos, height) {
      case height == 0 {
        True -> [pos, ..memo]
        False -> memo
      }
    },
  )
}

pub fn pt_2(input: String) {
  let Agg(heightmap, _start, end, dimensions) = parse(input)
  find_all_starting_points(heightmap)
  |> list.map(find(heightmap, _, end, dimensions))
  |> list.reduce(int.min)
  |> result.unwrap(-1)
}

fn find(
  heightmap: Heightmap,
  start: Pos,
  end: Pos,
  dimensions: Dimensions,
) -> Int {
  let pq = queue.from_list([start])
  let prev_pos = map.from_list([#(start, Pos(-1, -1))])
  let total_steps =
    gen_total_steps(heightmap)
    |> map.insert(start, 0)
  do_find(heightmap, total_steps, end, dimensions, pq, prev_pos)
}

fn do_find(
  heightmap heightmap: Heightmap,
  total_steps total_steps: TotalSteps,
  end end: Pos,
  dimensions dimensions: Dimensions,
  pq pq: PQ,
  prev_pos prev_pos: PrevPos,
) -> Int {
  let pop = fn(pq: PQ, fun) -> Int {
    case queue.pop_front(pq) {
      Ok(pair) -> fun(pair)
      Error(Nil) -> max_int
    }
  }
  use item_pq <- pop(pq)
  let #(current_pos, pq) = item_pq
  let adjacent =
    adjacent_positions(current_pos, heightmap, total_steps, dimensions)
  assert Ok(current_steps) = map.get(total_steps, current_pos)
  case list.find(adjacent, fn(adj_pos) { adj_pos == end }) {
    Ok(_) -> current_steps + 1
    Error(Nil) ->
      do_find(
        heightmap: heightmap,
        total_steps: list.fold(
          adjacent,
          total_steps,
          fn(total_steps, adj_pos) {
            map.insert(total_steps, adj_pos, current_steps + 1)
          },
        ),
        end: end,
        dimensions: dimensions,
        pq: list.fold(
          adjacent,
          pq,
          fn(pq, adj_pos) { queue.push_back(pq, adj_pos) },
        ),
        prev_pos: list.fold(
          adjacent,
          prev_pos,
          fn(prev_pos, adj_pos) { map.insert(prev_pos, adj_pos, current_pos) },
        ),
      )
  }
}

fn adjacent_positions(
  pos: Pos,
  heightmap: Heightmap,
  total_steps: TotalSteps,
  dimensions: Dimensions,
) -> List(Pos) {
  assert Ok(current_height) = map.get(heightmap, pos)
  assert Ok(current_total_steps) = map.get(total_steps, pos)
  [
    Pos(pos.x - 1, pos.y),
    Pos(pos.x + 1, pos.y),
    Pos(pos.x, pos.y - 1),
    Pos(pos.x, pos.y + 1),
  ]
  |> list.filter(fn(pos) {
    pos.x >= 0 && pos.x < dimensions.x && pos.y >= 0 && pos.y < dimensions.y
  })
  |> list.filter(fn(pos) {
    assert Ok(height) = map.get(heightmap, pos)
    // We can climb at most one level higher.
    height <= current_height + 1
  })
  |> list.filter(fn(pos) {
    assert Ok(total_steps) = map.get(total_steps, pos)
    // We must only explore paths with more number of total_steps.
    total_steps > current_total_steps + 1
  })
}

pub type Agg {
  Agg(heightmap: Heightmap, start: Pos, end: Pos, dimensions: Dimensions)
}

fn parse(input: String) -> Agg {
  string.split(input, "\n")
  |> iterator.from_list
  |> iterator.filter(function.compose(string.is_empty(_), bool.negate))
  |> iterator.index
  |> iterator.fold(
    Agg(map.new(), Pos(-1, -1), Pos(-1, -1), Dimensions(-1, -1)),
    fn(agg, idx_line) {
      let #(y, line) = idx_line
      string.to_graphemes(line)
      |> iterator.from_list
      |> iterator.index
      |> iterator.fold(
        agg,
        fn(agg, idx_letter) {
          let #(x, letter) = idx_letter
          Agg(
            heightmap: map.insert(agg.heightmap, Pos(x, y), elevation(letter)),
            start: case letter == "S" {
              True -> Pos(x, y)
              False -> agg.start
            },
            end: case letter == "E" {
              True -> Pos(x, y)
              False -> agg.end
            },
            dimensions: Dimensions(x + 1, y + 1),
          )
        },
      )
    },
  )
}

fn elevation(letter: String) -> Int {
  case <<letter:utf8>> {
    <<"S":utf8>> -> 0
    <<"E":utf8>> -> 25
    <<n:int>> -> n - 97
    _ -> {
      assert False = True
      0
    }
  }
}

// 2^31
const max_int = 2147483648

fn gen_total_steps(heightmap: Heightmap) -> TotalSteps {
  map.fold(
    heightmap,
    map.new(),
    fn(memo, key, _value) { map.insert(memo, key, max_int) },
  )
}
