open Ctypes
open Result

module Util : sig
  val (|@>) : ('a, 'b) result -> ('a -> ('c, 'b) result) -> ('c, 'b) result
  val (|@*>) : ('a, 'b) result -> ('a -> 'c) -> ('c, 'b) result

  val lift_null_term_string : string -> string
end

module AMX : sig
  type t

  type cell = nativeint
  type native_index = int
  type public_index = int

  type error =
    | AMX_INVALID_ERROR
    | AMX_ERR_NONE
    | AMX_ERR_EXIT
    | AMX_ERR_ASSERT
    | AMX_ERR_STACKERR
    | AMX_ERR_BOUNDS
    | AMX_ERR_MEMACCESS
    | AMX_ERR_INVINSTR
    | AMX_ERR_STACKLOW
    | AMX_ERR_HEAPLOW
    | AMX_ERR_CALLBACK
    | AMX_ERR_NATIVE
    | AMX_ERR_DIVIDE
    | AMX_ERR_SLEEP
    | AMX_ERR_INVSTATE
    | AMX_ERR_MEMORY
    | AMX_ERR_FORMAT
    | AMX_ERR_VERSION
    | AMX_ERR_NOTFOUND
    | AMX_ERR_INDEX
    | AMX_ERR_DEBUG
    | AMX_ERR_INIT
    | AMX_ERR_USERDATA
    | AMX_ERR_INIT_JIT
    | AMX_ERR_PARAMS
    | AMX_ERR_DOMAIN
    | AMX_ERR_GENERAL
    | AMX_ERR_OVERLAY

  val error_to_enum : error -> int
  val error_of_enum : int -> error option
  val pp_error : Format.formatter -> error -> unit
  val show_error : error -> string

  val error_result : error -> (unit -> 'a) -> ('a, error) result

  val create : unit -> t

  val find_native : t -> string -> (native_index, error) result
  val find_public : t -> string -> (public_index, error) result

  val get_native : t -> int -> (string, error) result
  val get_public : t -> int -> (string * cell, error) result

  val num_natives : t -> (int, error) result
  val num_publics : t -> (int, error) result

  val enumerate_natives : t -> (string list, error) result
  val enumerate_publics : t -> ((string * cell) list, error) result

  val push : t -> cell -> error
  val exec : t -> public_index -> (cell, error) result
end

module AUX : sig
  val load_program : AMX.t -> string -> unit Ctypes_static.ptr -> AMX.error
  val free_program : AMX.t -> AMX.error
end
