#include <caml/memory.h>
#include <caml/mlvalues.h>
#include <caml/custom.h>
#include <amx.h>

static struct custom_operations caml_amx_custom_ops = {
  .identifier = "amx handling",
  .finalize = custom_finalize_default,
  .compare = custom_compare_default,
  .hash = custom_hash_default,
  .serialize = custom_serialize_default,
  .deserialize = custom_deserialize_default
};

CAMLprim value __pawn_ocaml_stubs__new_amx_object() {
  CAMLparam0();
  CAMLlocal1(amx);

  amx = caml_alloc_custom(&caml_amx_custom_ops, sizeof(AMX), 0, 1);

  CAMLreturn(amx);
}
