import gleam/list
import gleam/string
import gleam/int

// import gleam/io

pub fn pt_1(input: String) -> Int {
  input
  |> parse_input
  |> sort
  |> find_first
}

fn find_first(sorted: List(Int)) -> Int {
  assert Ok(n) = list.first(sorted)
  n
}

pub fn pt_2(input: String) -> Int {
  input
  |> parse_input
  |> sort
  |> find_three
}

pub type Elf {
  Elf(bag: List(Int))
}

fn sort(elves: List(Elf)) -> List(Int) {
  elves
  |> list.map(fn(elf) { list.fold(elf.bag, 0, int.add) })
  |> list.sort(int.compare)
  |> list.reverse
}

fn find_three(sorted: List(Int)) -> Int {
  list.take(sorted, 3)
  |> list.fold(0, int.add)
}

fn parse_input(input: String) -> List(Elf) {
  string.split(input, "\n\n")
  |> list.map(fn(lines) { string.split(lines, "\n") })
  |> list.fold(
    [],
    fn(memo, bag) {
      let to_int = fn(bag) {
        list.map(
          bag,
          fn(s) {
            assert Ok(n) = int.parse(s)
            n
          },
        )
      }
      [Elf(bag: to_int(bag)), ..memo]
    },
  )
}
