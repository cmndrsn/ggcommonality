devtools::load_all()

library(ggplot2)

yhat_model <- yhat::regr(
  lm(
    formula = mpg ~ cyl + disp + vs + drat + hp + wt + am + gear +carb,
    data = mtcars
  )
)


ggcommonality::df_ggcommonality(yhat_model)



ggcommonality::ggcommonality(yhat_model)

