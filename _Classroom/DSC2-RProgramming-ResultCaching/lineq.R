## These functions implement cached solve of a linear equation system(s).

## Object which stores a linear equation system and its solution.

makeCacheEquation <- function(M, V = NULL) {
  
  solution <- NULL
  
  set.matrices <- function(M.in, V.in) {
    M <<- M.in
    V <<- V.in
    solution <<- NULL
  }
  
  get.matrices <- function() list(M = M, V = V)
  set.solution <- function(s) solution <<- s
  get.solution <- function() solution
  
  list(set.matrices = set.matrices, get.matrices = get.matrices, 
       set.solution = set.solution, get.solution = get.solution)
}


## Solves the linear equation system(s) described by matrices M and V inside 
## object X. If the same equations were already solved previously, then the
## solution is taken from cache, and no computation is done. 
##
## Note: if matrix V is not defined in X, then the result is the inverse of M.  

cacheSolve <- function(X, ...) {
  
  if (!is.null(X$get.solution())) {
    message("Solution retrieved from cache")
    return (X$get.solution())
  }
  
  M <- X$get.matrices()$M
  V <- X$get.matrices()$V
  
  if (is.null(V)) X$set.solution(solve(M, , ...))
  
  if (!is.null(V)) X$set.solution(solve(M, V, ...))
  
  X$get.solution()
}
