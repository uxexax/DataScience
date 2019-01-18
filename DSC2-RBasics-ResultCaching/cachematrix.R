## These functions implement cached matrix inversion.

## Object which stores a matrix and its inverse.

makeCacheMatrix <- function(M = matrix()) {
  inv <- NULL
  set.M <- function(N) {
    M <<- N
    inv <<- NULL
  }
  get.M <- function() M
  set.inv <- function(i) inv <<- i
  get.inv <- function() inv
  list(set.matrix = set.M, get.matrix = get.M, 
       set.inverse = set.inv, get.inverse = get.inv)
}


## Inverts the matrix passed in the first argument. If the same matrix was
## already inverted previously, the inverse is taken from cache, no computation
## is done.

cacheSolve <- function(X, ...) {

  if (!is.null(X$get.inverse())) {
    message("Inverse retrieved from cache")
    return (X$get.inverse())
  }

  X$set.inverse(
    solve(X$get.matrix()))

  X$get.inverse()
}
