import gleam/string
import gleam/list
import gleam/queue.{Queue}
import gleam/io
import gleam/iterator
import gleam/int
import gleam/map.{Map}
import gleam/option.{Some}

pub type ThrowToWithValue {
  TV(to: Int, value: Int)
}

pub type Monkey {
  Monkey(
    items: Queue(Int),
    throw_to: fn(Int) -> ThrowToWithValue,
    inspected: Int,
    testing_dividend: Int,
  )
}

pub type Monkeys =
  Map(Int, Monkey)

pub fn pt_1(input: String) {
  let monkeys = parse(input, with_relief: True)
  monkey_business(monkeys, after: 20)
}

pub fn pt_2(input: String) {
  let monkeys = parse(input, with_relief: False)
  monkey_business(monkeys, after: 10000)
}

fn parse(input: String, with_relief apply_relief: Bool) -> Monkeys {
  string.split(input, "\n\n")
  |> list.map(fn(monkey_desc) {
    string.split(monkey_desc, "\n")
    |> list.fold(
      #(Monkey(queue.new(), fn(_n) { TV(to: -1, value: -1) }, 0, -1), -1),
      fn(monkey_true, line) {
        let #(monkey, true_branch) = monkey_true
        case line {
          "Monkey " <> _ -> monkey_true
          "  Starting items: " <> items -> {
            let items =
              string.split(items, ", ")
              |> list.map(intparse)
              |> queue.from_list
            #(Monkey(..monkey, items: items), true_branch)
          }
          "  Operation: new = " <> expr -> {
            let operation = parse_expr(expr)
            let fun = case apply_relief {
              True -> fn(n: Int) -> ThrowToWithValue {
                TV(value: operation(n) / 3, to: -1)
              }
              False -> fn(n: Int) -> ThrowToWithValue {
                TV(value: operation(n), to: -1)
              }
            }
            #(Monkey(..monkey, throw_to: fun), true_branch)
          }
          "  Test: divisible by " <> test -> {
            let test = intparse(test)
            let testing = fn(n: Int) -> ThrowToWithValue {
              let TV(_, value) = monkey.throw_to(n)
              TV(value % test, value)
            }
            #(
              Monkey(..monkey, throw_to: testing, testing_dividend: test),
              true_branch,
            )
          }
          "    If true: throw to monkey " <> if_true -> {
            let if_true = intparse(if_true)
            #(monkey, if_true)
          }
          "    If false: throw to monkey " <> if_false -> {
            let if_false = intparse(if_false)
            let throw_to = fn(n: Int) -> ThrowToWithValue {
              let TV(to, value) = monkey.throw_to(n)
              case to {
                0 -> TV(true_branch, value)
                _ -> TV(if_false, value)
              }
            }
            #(Monkey(..monkey, throw_to: throw_to), -1)
          }
        }
      },
    )
  })
  |> list.index_fold(
    map.new(),
    fn(memo: Monkeys, monkey_true, idx) -> Monkeys {
      let #(monkey, _) = monkey_true
      map.insert(memo, idx, monkey)
    },
  )
}

fn play(monkeys: Monkeys, idx: Int) -> Monkeys {
  let common_divident = common_dividend(monkeys)
  assert Ok(monkey) = map.get(monkeys, idx)
  let inspected = queue.length(monkey.items)
  queue.to_list(monkey.items)
  |> iterator.from_list
  |> iterator.fold(
    monkeys,
    fn(monkeys, item) {
      let TV(to, value) = monkey.throw_to(item)
      let value = value % common_divident
      map.update(
        monkeys,
        to,
        fn(to_monkey) {
          assert Some(to_monkey) = to_monkey
          Monkey(..to_monkey, items: queue.push_back(to_monkey.items, value))
        },
      )
    },
  )
  |> map.insert(
    idx,
    Monkey(
      ..monkey,
      items: queue.new(),
      inspected: monkey.inspected + inspected,
    ),
  )
}

fn play_single_round(monkeys: Monkeys) -> Monkeys {
  list.range(0, map.size(monkeys) - 1)
  |> list.fold(monkeys, play)
}

fn monkey_business(monkeys: Monkeys, after rounds: Int) -> Int {
  let monkeys =
    list.fold(
      list.range(1, rounds),
      monkeys,
      fn(monkeys, _round_no) { play_single_round(monkeys) },
    )
  map.to_list(monkeys)
  |> list.map(fn(idx_monkey) {
    let #(_idx, monkey) = idx_monkey
    monkey.inspected
  })
  |> list.sort(fn(a, b) { int.compare(b, a) })
  |> list.take(2)
  |> int.product
}

fn common_dividend(monkeys: Monkeys) -> Int {
  map.fold(
    monkeys,
    1,
    fn(memo, _idx, monkey) { memo * monkey.testing_dividend },
  )
}

fn parse_expr(expr: String) -> fn(Int) -> Int {
  case string.split(expr, " ") {
    [a, op, b] if op == "+" && a == "old" && b == "old" -> fn(n: Int) { n + n }
    [a, op, b] if op == "+" && a == "old" -> fn(n: Int) { n + intparse(b) }
    [a, op, b] if op == "+" && b == "old" -> fn(n: Int) { n + intparse(a) }
    [a, op, b] if op == "*" && a == "old" && b == "old" -> fn(n: Int) { n * n }
    [a, op, b] if op == "*" && a == "old" -> fn(n: Int) { n * intparse(b) }
    [a, op, b] if op == "*" && b == "old" -> fn(n: Int) { n * intparse(a) }
  }
}

fn intparse(n: String) -> Int {
  assert Ok(n) = int.parse(n)
  n
}

pub fn print_monkey(monkeys: Monkeys, idx: Int) -> Monkeys {
  assert Ok(monkey) = map.get(monkeys, idx)
  let items =
    monkey.items
    |> queue.to_list
    |> list.map(int.to_string(_))
    |> string.join(", ")
  io.println(
    "Monkey " <> int.to_string(idx) <> " inspected " <> int.to_string(
      monkey.inspected,
    ) <> ": " <> items,
  )
  monkeys
}

pub fn print_monkeys(monkeys: Monkeys) -> Monkeys {
  list.each(
    list.range(0, map.size(monkeys) - 1),
    fn(idx) { print_monkey(monkeys, idx) },
  )
  monkeys
}
