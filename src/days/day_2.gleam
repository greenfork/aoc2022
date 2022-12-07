import gleam/list
import gleam/string
import gleam/int

const loss = 0

const draw = 3

const win = 6

pub type Shape {
  Rock
  Paper
  Scissors
}

pub type Round {
  Round(opponent: Shape, me: Shape)
}

fn score(round: Round) -> Int {
  let shape_score = fn(shape: Shape) -> Int {
    case shape {
      Rock -> 1
      Paper -> 2
      Scissors -> 3
    }
  }
  let outcome_score = fn(opponent_shape: Shape, my_shape: Shape) -> Int {
    case opponent_shape, my_shape {
      Rock, Rock -> draw
      Rock, Paper -> win
      Rock, Scissors -> loss
      Paper, Rock -> loss
      Paper, Paper -> draw
      Paper, Scissors -> win
      Scissors, Rock -> win
      Scissors, Paper -> loss
      Scissors, Scissors -> draw
    }
  }
  shape_score(round.me) + outcome_score(round.opponent, round.me)
}

pub type Outcome {
  Win
  Loss
  Draw
}

fn shape_to(opponent: Shape, outcome: Outcome) -> Shape {
  case opponent, outcome {
    Rock, Win -> Paper
    Paper, Win -> Scissors
    Scissors, Win -> Rock
    Rock, Loss -> Scissors
    Paper, Loss -> Rock
    Scissors, Loss -> Paper
    Rock, Draw -> Rock
    Paper, Draw -> Paper
    Scissors, Draw -> Scissors
  }
}

pub fn pt_1(input: String) -> Int {
  input
  |> parse(False)
  |> list.map(score(_))
  |> int.sum
}

pub fn pt_2(input: String) -> Int {
  input
  |> parse(True)
  |> list.map(score(_))
  |> int.sum
}

fn my_shape_no_strategy(s: String) -> Shape {
  case s {
    "X" -> Rock
    "Y" -> Paper
    "Z" -> Scissors
  }
}

fn my_shape_with_strategy(opponent: Shape, me: String) -> Shape {
  case me {
    "X" -> shape_to(opponent, Loss)
    "Y" -> shape_to(opponent, Draw)
    "Z" -> shape_to(opponent, Win)
  }
}

fn parse(input: String, strategy: Bool) -> List(Round) {
  string.split(input, "\n")
  |> list.filter(fn(line) { !string.is_empty(line) })
  |> list.map(string.split(_, " "))
  |> list.map(fn(pair) {
    let [opponent, me] = pair
    let opponent_shape = case opponent {
      "A" -> Rock
      "B" -> Paper
      "C" -> Scissors
    }
    let my_shape = case strategy {
      False -> my_shape_no_strategy(me)
      True -> my_shape_with_strategy(opponent_shape, me)
    }
    Round(opponent_shape, my_shape)
  })
}
