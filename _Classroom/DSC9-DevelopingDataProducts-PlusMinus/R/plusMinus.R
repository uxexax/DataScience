EVAL <- function(x, y)
{
  unit <- sign(y)
  y <- abs(y)
  while (y > 0)
  {
    x <- x + unit
    y <- y - 1
  }
  return(x)
}

#' Plus (+)
#'
#' Adds an integer to another integer (x+y).
#'
#' @param x The base of the addition (to which the other integer is added).
#' @param y The addition to the base.
#' @return The sum of x and y.
#' @author Istvan Andras Horvath
#' @details Calls the internal function EVAL with \emph{x} and \emph{y}. EVAL implements a loop of unit value addition.
#' @seealso \code{while}
#' @export
#' @examples
#' plus(7, 5)
#' plus(9, -3)
#' plus(-6, 4)
#' plus(-8, -8)

plus <- function(x, y)
{
  return(EVAL(x, y))
}

#' Minus (-)
#'
#' Subtracts an integer from another integer (x-y).
#'
#' @param x The base of the subtraction (from which the other integer is subtracted).
#' @param y The subtraction from the base.
#' @return The difference between x and y.
#' @author Istvan Andras Horvath
#' @details Calls the internal function EVAL with \emph{x} and \emph{-y}. EVAL implements a loop of unit value addition.
#' @seealso \code{while}
#' @export
#' @examples
#' minus(1, 10)
#' minus(-3, -3)
#' minus(-9, 1)
#' minus(1, -1)

minus <- function(x, y)
{
  return(EVAL(x, -y))
}
