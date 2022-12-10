import gleam/string
import gleam/iterator
import gleam/int
import gleam/list
// import gleam/io
import gleam/set.{Set}

const total_space = 70000000

const required_unused_space = 30000000

pub type File {
  File(path: String, size: Int)
}

pub type DirectoryState {
  DirectoryState(files: Set(File), current: String)
}

pub fn pt_1(input: String) {
  build_directories(input)
  |> list.filter(fn(file) {
    file.size <= 100000 && string.ends_with(file.path, "/")
  })
  |> list.map(fn(file) { file.size })
  |> int.sum
}

pub fn pt_2(input: String) {
  let files = build_directories(input)
  assert [root, ..] = files
  let minimum_size = required_unused_space - { total_space - root.size }
  list.filter(
    files,
    fn(file) { file.size >= minimum_size && string.ends_with(file.path, "/") },
  )
  |> list.fold(
    total_space,
    fn(memo, file) {
      case file.size < memo {
        True -> file.size
        False -> memo
      }
    },
  )
}

fn build_directories(input: String) -> List(File) {
  let files =
    input
    |> string.split("\n")
    |> iterator.from_list
    |> iterator.filter(fn(line) { !string.is_empty(line) })
    |> iterator.fold(
      DirectoryState(
        [File("/", 0)]
        |> set.from_list,
        "",
      ),
      fn(memo, line) {
        case line {
          "$ cd /" -> DirectoryState(memo.files, current: "/")
          "$ cd .." -> pop_directory(memo)
          "$ cd " <> dest -> change_directory(memo, dest)
          "$ ls" -> memo
          "dir " <> dirname -> add_directory(memo, dirname)
          file_line -> {
            assert [size, filename] = string.split(file_line, " ")
            assert Ok(size) = int.parse(size)
            add_file(memo, filename, size)
          }
        }
      },
    )
    |> fn(dirstate: DirectoryState) { dirstate.files }
    |> set.to_list
    |> list.sort(fn(file_a, file_b) { string.compare(file_a.path, file_b.path) })
  list.map(
    files,
    fn(file) {
      File(
        ..file,
        size: list.filter(
          files,
          fn(f) { string.starts_with(f.path, file.path) },
        )
        |> list.map(fn(f) { f.size })
        |> int.sum,
      )
    },
  )
}

fn pop_directory(dirstate: DirectoryState) -> DirectoryState {
  let path = string.split(dirstate.current, "/")
  let new_dir =
    list.take(path, list.length(path) - 2)
    |> string.join("/")
  DirectoryState(..dirstate, current: new_dir <> "/")
}

fn change_directory(dirstate: DirectoryState, dest: String) -> DirectoryState {
  let new_dir = dirstate.current <> dest <> "/"
  DirectoryState(
    files: set.insert(dirstate.files, File(new_dir, 0)),
    current: new_dir,
  )
}

fn add_directory(dirstate: DirectoryState, dirname: String) -> DirectoryState {
  DirectoryState(
    ..dirstate,
    files: set.insert(
      dirstate.files,
      File(dirstate.current <> dirname <> "/", 0),
    ),
  )
}

fn add_file(
  dirstate: DirectoryState,
  filename: String,
  size: Int,
) -> DirectoryState {
  DirectoryState(
    ..dirstate,
    files: set.insert(dirstate.files, File(dirstate.current <> filename, size)),
  )
}
