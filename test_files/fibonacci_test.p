#include "fibonacci"

forward @test_fib1()
@test_fib1() {
  return (fib(1) == 1)
}

forward @test_fib5()
@test_fib5() {
  return (fib(5) == 5)
}
