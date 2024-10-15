devtools::load_all()

library(ggplot2)

yhat_model <- yhat::regr(
  lm(
    formula = mpg ~ cyl + disp + vs + drat + hp + wt + am + gear +carb,
    data = mtcars
  )
)


commonalitybarplot::get_commonality_barplot_df(yhat_model)



commonalitybarplot::ggcommonality(yhat_model)

