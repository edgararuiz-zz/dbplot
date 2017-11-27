context("db_bin")


test_that("Correct bin formula is returned",
          expect_equal(db_bin(var),
                       rlang::expr(
                         (((max(var) - min(var))/(30)) * ifelse((as.integer(floor(((var) -
                            min(var))/((max(var) - min(var))/(30))))) == (30), (as.integer(floor(((var) - 
                            min(var))/((max(var) - min(var))/(30))))) - 1, (as.integer(floor(((var) - 
                            min(var))/((max(var) - min(var))/(30))))))) + min(var))
                       ))


test_that("Correct bin formula is returned with 10 bins",
          expect_equal(db_bin(var, bins = 10),
                       rlang::expr(
                         (((max(var) - min(var))/(10)) * ifelse((as.integer(floor(((var) -
                          min(var))/((max(var) - min(var))/(10))))) == (10), (as.integer(floor(((var) - 
                          min(var))/((max(var) - min(var))/(10))))) - 1, (as.integer(floor(((var) - 
                          min(var))/((max(var) - min(var))/(10))))))) + min(var))
          ))

test_that("Correct binwidth formula is returned",
          expect_equal(db_bin(var, binwidth = 10),
                       rlang::expr(
                         ((10) * ifelse((as.integer(floor(((var) - min(var))/(10)))) == 
                          (as.integer((max(var) - min(var))/(10))), (as.integer(floor(((var) - 
                          min(var))/(10)))) - 1, (as.integer(floor(((var) - min(var))/(10)))))) + min(var))
                       ))
