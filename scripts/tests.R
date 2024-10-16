devtools::load_all()


yhat_model <- yhat::regr(
  lm(
    formula = mpg ~ cyl + disp + vs + drat + hp + wt + am + gear +carb,
    data = mtcars
  )
)


yhat_model <- yhat::regr(
  lm(
    formula = mpg ~ cyl + disp,
    data = mtcars
  )
)



ggcommonality(yhat_model)



yhat_model <- yhat::regr(
  lm(
    formula = mpg ~ cyl + disp + vs + wt + gear,
    data = mtcars
  )
)

ggcommonality::ggcommonality(yhat_model)
