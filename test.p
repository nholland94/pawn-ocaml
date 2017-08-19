#include <console>
#include <float>
#include <string>

main() {
  new test[.int, Float: .float, .string[50]]

  test.int = 20
  test.float = float(5) / float(2)
  strcopy(test.string, "testing 1 2 3", 13)

  // printf("%d\n", test.int);
  // printf("Testing... %d, %f, \"%s\"\n", test.int, test.float, test.string)

  return test.int
}
