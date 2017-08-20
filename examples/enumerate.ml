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

let () =
  (if Array.length Sys.argv < 2 then failwith "Invalid number of arguments");

  let amx = AMX.create () in
  check_err (AUX.load_program amx Sys.argv.(1) Ctypes.null);

  let natives = check_err_result (AMX.enumerate_natives amx) in
  let publics = check_err_result (AMX.enumerate_publics amx) in

  print_endline "### Natives:";
  List.iteri (Printf.printf "%d - %s\n") natives;

  print_endline "### Publics:";
  List.iteri (fun i (name, addr) -> Printf.printf "%d - %s:0x%08nx\n" i name addr) publics;

  check_err (AUX.free_program amx)
