import gleam/string
import gleam/iterator
import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt, Order}

pub type Packet {
  I(Int)
  L(List(Packet))
}

pub type PacketPair {
  PacketPair(left: Packet, right: Packet)
}

pub fn pt_1(input: String) {
  parse(input)
  |> list.index_fold(
    0,
    fn(sum, packet_pair, idx) {
      case compare(packet_pair.left, packet_pair.right) {
        Eq | Lt -> sum + idx + 1
        Gt -> sum
      }
    },
  )
}

pub fn pt_2(input: String) {
  let divider1 = L([L([I(2)])])
  let divider2 = L([L([I(6)])])
  parse(input)
  |> list.fold(
    [divider1, divider2],
    fn(packets, pair) { [pair.left, pair.right, ..packets] },
  )
  |> list.sort(compare)
  |> list.index_fold(
    1,
    fn(product, packet, idx) {
      case packet {
        _ if packet == divider1 || packet == divider2 -> product * { idx + 1 }
        _ -> product
      }
    },
  )
}

fn compare(left: Packet, right: Packet) -> Order {
  case left, right {
    I(left), I(right) -> int.compare(left, right)
    L(_), I(_) -> compare(left, L([right]))
    I(_), L(_) -> compare(L([left]), right)
    L(left), L(right) -> {
      let result =
        list.zip(left, right)
        |> list.try_fold(
          Eq,
          fn(_, lr) {
            let #(left, right) = lr
            case compare(left, right) {
              Lt -> Error(Lt)
              Gt -> Error(Gt)
              Eq -> Ok(Eq)
            }
          },
        )
      case result {
        Ok(Eq) -> int.compare(list.length(left), list.length(right))
        Error(Lt) -> Lt
        Error(Gt) -> Gt
      }
    }
  }
}

fn parse(input: String) -> List(PacketPair) {
  string.split(input, "\n\n")
  |> iterator.from_list
  |> iterator.map(fn(two_packets) {
    assert [left, right, ..] = string.split(two_packets, "\n")
    assert #(left, "") = parse_packet(string.drop_left(left, 1), L([]))
    assert #(right, "") = parse_packet(string.drop_left(right, 1), L([]))
    PacketPair(left: left, right: right)
  })
  |> iterator.to_list
}

fn parse_packet(line: String, packet: Packet) -> #(Packet, String) {
  assert L(list) = packet
  case line {
    "[" <> rest -> {
      let #(new_list, rest) = parse_packet(rest, L([]))
      parse_packet(rest, L([new_list, ..list]))
    }
    "]" <> rest -> #(L(list.reverse(list)), rest)
    "," <> rest -> parse_packet(rest, packet)
    number_rest -> {
      let #(number, rest) = parse_number(number_rest)
      parse_packet(rest, L([I(number), ..list]))
    }
  }
}

fn parse_number(s: String) -> #(Int, String) {
  let #(number, rest) =
    string.to_graphemes(s)
    |> list.split_while(fn(ch) {
      case ch {
        "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
        _ -> False
      }
    })
  assert Ok(number) = int.parse(string.join(number, ""))
  #(number, string.join(rest, ""))
}
