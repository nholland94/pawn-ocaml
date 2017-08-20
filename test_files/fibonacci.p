fib(n) {
  new first = 0
  new second = 1
  new next

  for(new i = 0; i < n; i++) {
    if(i <= 1) {
      next = i
    } else {
      next = first + second
      first = second
      second = next
    }
  }

  return next
}
