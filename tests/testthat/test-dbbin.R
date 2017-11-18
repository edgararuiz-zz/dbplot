context("db_bin")


test_that("Correct bin formula is returned",
          expect_equal(db_bin(var),
                       rlang::expr(
                         (((max(var, na.rm = TRUE) - min(var, na.rm = TRUE))/(30)) * ifelse((as.integer(floor(((var) -
                            min(var, na.rm = TRUE))/((max(var, na.rm = TRUE) - min(var, na.rm = TRUE))/(30))))) == (30), (as.integer(floor(((var) - 
                            min(var, na.rm = TRUE))/((max(var, na.rm = TRUE) - min(var, na.rm = TRUE))/(30))))) - 1, (as.integer(floor(((var) - 
                            min(var, na.rm = TRUE))/((max(var, na.rm = TRUE) - min(var, na.rm = TRUE))/(30))))))) + min(var, na.rm = TRUE))
                       ))


test_that("Correct bin formula is returned with 10 bins",
          expect_equal(db_bin(var, bins = 10),
                       rlang::expr(
                         (((max(var, na.rm = TRUE) - min(var, na.rm = TRUE))/(10)) * ifelse((as.integer(floor(((var) -
                          min(var, na.rm = TRUE))/((max(var, na.rm = TRUE) - min(var, na.rm = TRUE))/(10))))) == (10), (as.integer(floor(((var) - 
                          min(var, na.rm = TRUE))/((max(var, na.rm = TRUE) - min(var, na.rm = TRUE))/(10))))) - 1, (as.integer(floor(((var) - 
                          min(var, na.rm = TRUE))/((max(var, na.rm = TRUE) - min(var, na.rm = TRUE))/(10))))))) + min(var, na.rm = TRUE))
          ))

test_that("Correct binwidth formula is returned",
          expect_equal(db_bin(var, binwidth = 10),
                       rlang::expr(
                         ((10) * ifelse((as.integer(floor(((var) - min(var, na.rm = TRUE))/(10)))) == 
                          (as.integer((max(var, na.rm = TRUE) - min(var, na.rm = TRUE))/(10))), (as.integer(floor(((var) - 
                          min(var, na.rm = TRUE))/(10)))) - 1, (as.integer(floor(((var) - min(var, na.rm = TRUE))/(10)))))) + min(var, na.rm = TRUE))
                       ))