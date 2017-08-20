open Pawn
open Pawn.Util

let return x _ = x

let fatal_amx_error error =
  failwith (Printf.sprintf "Fatal AMX Error: %s" (AMX.show_error error))

let check_err = function
  | AMX.AMX_ERR_NONE -> ()
  | _ as error       -> fatal_amx_error error

let check_err_result = function
  | Result.Ok v        -> v
  | Result.Error error -> fatal_amx_error error

exception ParsingError of int * string

(*
let parse_test_file file =
  let ic = open_in file in

  let rec group_entry_loop base_line_number =
    let rec check_line index =
      try
        let line_number = base_line_number + index in
        let line = input_line ic in
        if Str.string_match (Str.regexp ("^\\s+\\(\\w+\\)(\\(?:\\w+\\)\\(?:,\\s*\\w+\\))\\s*=\\s*\\(\\w+\\)\\s*$"))
      with
        | End_of_file -> []
    in
    check_line 0
  in

  let rec group_loop line_number =
    try
      let line = input_line ic in
      if Str.string_match (Str.regexp "^\\(\\w+\\):.*$") line 0 then
        let filename = Str.matched_group 1 line in
        let (lines_advanced, entries) = group_entry_loop (line_number + 1) in
        (filename, entries) :: group_loop (line_number + 1 + lines_advanced)
      else if Str.string_match (Str.regexp "[^ ]") line 0 then
        raise (ParsingError (line_number, "expected group header"))
      else
        group_loop (line_number + 1)
    with
      | End_of_file -> []
  in
*)


let run_test_public amx (name, _) =
  match AMX.find_public amx name |@> (AMX.exec amx) with
    | Result.Ok r      -> if r <> 0n then (name, Result.Ok ()) else (name, Result.Error "test failed")
    | Result.Error err -> (name, Result.Error ("AMX Error: " ^ AMX.show_error err))

let map_result result ok_fn error_fn =
  match result with
    | Result.Ok r      -> ok_fn r
    | Result.Error err -> error_fn err

let report_test_result (name, result) =
  Printf.printf "%s - %s\n" name (map_result result (return "pass") ((^) "fail: "))

let () =
  (if Array.length Sys.argv < 2 then failwith "Invalid number of arguments");
  let test_file = Sys.argv.(1) in

  let amx = AMX.create () in
  check_err (AUX.load_program amx test_file Ctypes.null);

  let publics = check_err_result (AMX.enumerate_publics amx) in
  let test_publics = List.filter (fun (name, _) -> print_endline ("name: " ^ name); Str.string_match (Str.regexp "^@test") name 0) publics in
  let test_results = List.map (run_test_public amx) test_publics in
  List.iter report_test_result test_results;

  check_err (AUX.free_program amx)
