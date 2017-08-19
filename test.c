#include <stdio.h>
#include <amx.h>

void fail_with(char *str) {
  printf("%s\n", str);
  exit(1);
}

int main(int argc, char **argv) {
  // AMX_NATIVE_INFO console_natives[];
  // AMX_NATIVE_INFO core_natives[];

  AMX amx;
  cell ret = 0;
  cell public_addr;
  const cell params[] = { 1, 50 };
  char name_buf[256];
  int i, num_natives, num_publics, test_cb_index, err;

  if(argc != 2) fail_with("Invalid Usage");

  err = aux_LoadProgram(&amx, argv[1], NULL);
  if(err != AMX_ERR_NONE) fail_with("failed to load program");

  // err = amx_Register(&amx, console_natives, -1);
  // if(err != AMX_ERR_NONE) fail_with("failed to register console natives");

  // err = amx_Register(&amx, core_natives, -1);
  // if(err != AMX_ERR_NONE) fail_with("failed to register core natives");
  //

  err = amx_NumNatives(&amx, &num_natives);
  if(err != AMX_ERR_NONE) fail_with("Failed to get number of natives");

  printf("num natives: %d\n", num_natives);
  for(i = 0; i < num_natives; i++) {
    err = amx_GetNative(&amx, i, name_buf);
    printf("%d -- %s\n", i, name_buf);
  }

  err = amx_NumPublics(&amx, &num_publics);
  if(err != AMX_ERR_NONE) fail_with("Failed to get number of publics");

  printf("num publics: %d\n", num_publics);
  for(i = 0; i < num_publics; i++) {
    err = amx_GetPublic(&amx, i, name_buf, &public_addr);
    printf("%d -- %s\n", i, name_buf);
  }

  err = amx_FindPublic(&amx, "@test", &test_cb_index);
  if(err != AMX_ERR_NONE) fail_with("Failed to find callback");

  amx_Push(&amx, 50);
  err = amx_Exec(&amx, &ret, test_cb_index);
  if(err != AMX_ERR_NONE) fail_with("Failed to call callback");

  printf("%s returns %ld\n", argv[1], (long)ret);

  aux_FreeProgram(&amx);
  return 0;
}
