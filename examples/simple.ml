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

  let result = check_err_result
    (AMX.find_public amx "@proc" |@> (fun proc_index ->
      AMX.error_result (AMX.push amx 50n) (return ()) |@> (fun () ->
        AMX.exec amx proc_index )))
  in

  Printf.printf "Result: %nd\n" result;

  check_err (AUX.free_program amx)
