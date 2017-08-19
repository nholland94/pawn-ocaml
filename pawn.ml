open Foreign
open Ctypes

module Util = struct
  open Result

  let (|@>) = function
    | Ok v             -> (fun f -> f v)
    | (Error _) as err -> (fun _ -> err)
  let (|@*>) = function
    | Ok v           -> (fun f -> Ok (f v))
    | Error _ as err -> (fun _ -> err)

  let lift_null_term_string buf =
    let len = String.length buf in
    let rec loop i =
      if i = len then
        raise (Invalid_argument "lift_null_term_string: no null term in buf")
      else if String.get buf i = Char.chr 0 then
        String.sub buf 0 i
      else
        loop (i + 1)
    in
    loop 0
end

module AMX = struct
  open Util

  type t = unit ptr
  let t : t typ = ptr void

  type cell = nativeint
  let cell : cell typ = nativeint
  type native_index = int
  let native_index : native_index typ = int
  type public_index = int
  let public_index : public_index typ = int

  type error =
    | AMX_INVALID_ERROR [@value -1]

    | AMX_ERR_NONE      [@value 0]
    | AMX_ERR_EXIT      [@value 1]
    | AMX_ERR_ASSERT    [@value 2]
    | AMX_ERR_STACKERR  [@value 3]
    | AMX_ERR_BOUNDS    [@value 4]
    | AMX_ERR_MEMACCESS [@value 5]
    | AMX_ERR_INVINSTR  [@value 6]
    | AMX_ERR_STACKLOW  [@value 7]
    | AMX_ERR_HEAPLOW   [@value 8]
    | AMX_ERR_CALLBACK  [@value 9]
    | AMX_ERR_NATIVE    [@value 10]
    | AMX_ERR_DIVIDE    [@value 11]
    | AMX_ERR_SLEEP     [@value 12]
    | AMX_ERR_INVSTATE  [@value 13]

    | AMX_ERR_MEMORY    [@value 16]
    | AMX_ERR_FORMAT    [@value 17]
    | AMX_ERR_VERSION   [@value 18]
    | AMX_ERR_NOTFOUND  [@value 19]
    | AMX_ERR_INDEX     [@value 20]
    | AMX_ERR_DEBUG     [@value 21]
    | AMX_ERR_INIT      [@value 22]
    | AMX_ERR_USERDATA  [@value 23]
    | AMX_ERR_INIT_JIT  [@value 24]
    | AMX_ERR_PARAMS    [@value 25]
    | AMX_ERR_DOMAIN    [@value 26]
    | AMX_ERR_GENERAL   [@value 27]
    | AMX_ERR_OVERLAY   [@value 28]
  [@@deriving enum, show]
  let error : error typ =
    let enum_to_error enum =
      match error_of_enum enum with
        | Some error -> error
        | None       -> AMX_INVALID_ERROR
    in
    view ~read:enum_to_error ~write:error_to_enum int

  let error_result error f =
    match error with
      | AMX_ERR_NONE -> Result.Ok (f ())
      | _            -> Result.Error error

  let create = foreign "__pawn_ocaml_stubs__new_amx_object" (void @-> returning t)

  module Raw = struct
    let find_native = foreign "amx_FindNative" (t @-> string @-> ptr native_index @-> returning error)
    let find_public = foreign "amx_FindPublic" (t @-> string @-> ptr public_index @-> returning error)
    let get_native = foreign "amx_GetNative" (t @-> int @-> string @-> returning error)
    let get_public = foreign "amx_GetPublic" (t @-> int @-> string @-> ptr cell @-> returning error)
    let num_natives = foreign "amx_NumNatives" (t @-> ptr int @-> returning error)
    let num_publics = foreign "amx_NumPublics" (t @-> ptr int @-> returning error)
    let push = foreign "amx_Push" (t @-> cell @-> returning error)
    let exec = foreign "amx_Exec" (t @-> ptr cell @-> public_index @-> returning error)
  end

  let find_native amx name =
    let index_ptr = allocate int 0 in
    error_result (Raw.find_native amx name index_ptr) (fun () -> !@index_ptr)
  let find_public amx name =
    let index_ptr = allocate int 0 in
    error_result (Raw.find_public amx name index_ptr) (fun () -> !@index_ptr)

  let get_native amx index =
    let name_buf = Bytes.to_string (Bytes.create 256) in
    error_result (Raw.get_native amx index name_buf) (fun () -> lift_null_term_string name_buf)
  let get_public amx index =
    let name_buf = Bytes.to_string (Bytes.create 256) in
    let addr_ptr = allocate cell 0n in
    error_result (Raw.get_public amx index name_buf addr_ptr) (fun () -> (lift_null_term_string name_buf, !@addr_ptr))

  let num_natives amx =
    let num_ptr = allocate int 0 in
    error_result (Raw.num_natives amx num_ptr) (fun () -> !@num_ptr)
  let num_publics amx =
    let num_ptr = allocate int 0 in
    error_result (Raw.num_publics amx num_ptr) (fun () -> !@num_ptr)

  let enumerate_natives amx =
    let rec gather_natives i cap =
      if i = cap then Result.Ok [] else
        get_native amx i |@> (fun native -> gather_natives (i + 1) cap |@*> (fun t -> native :: t))
    in
    num_natives amx |@> gather_natives 0
  let enumerate_publics amx =
    let rec gather_publics i cap =
      if i = cap then Result.Ok [] else
        get_public amx i |@> (fun public -> gather_publics (i + 1) cap |@*> (fun t -> public :: t))
    in
    num_publics amx |@> gather_publics 0

  let push = Raw.push

  let exec amx public_index =
    let result_ptr = allocate cell 0n in
    error_result (Raw.exec amx result_ptr public_index) (fun () -> !@result_ptr)
end

module AUX = struct
  let load_program = foreign "aux_LoadProgram" (AMX.t @-> string @-> ptr void @-> returning AMX.error)
  let free_program = foreign "aux_FreeProgram" (AMX.t @-> returning AMX.error)
end
