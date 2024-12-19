
library(MAPLE.emo)
my_data <- iris
my_formula <- Sepal.Length ~ Sepal.Width + Petal.Length + Petal.Width


{
# Random-x resampling by participant:
ggcommonality::ggcommonality(my_formula, my_data) +
  ggcommonality::ci_ggcommonality(my_formula,
                                  my_data,
                                  resample_type = "random",
                                  n_replications = 1000) +
  ggtitle("Random-x bootstrap, simple resampling") -> p1
ggcommonality::ggcommonality(my_formula, my_data) +
  ggcommonality::ci_ggcommonality(my_formula,
                                  my_data,
                                  sample_column = "Species",
                                  resample_type = "random",
                                  n_replications = 1000) +
  ggtitle("Random-x bootstrap, resampling within species") -> p2

ggcommonality::ggcommonality(my_formula, my_data) +
  ggcommonality::ci_ggcommonality(my_formula,
                                  my_data,
                                  resample_type = "fixed",
                                  n_replications = 1000) +
  ggtitle("Fixed-x bootstrap, simple resampling") -> p3

ggcommonality::ggcommonality(my_formula, my_data) +
  ggcommonality::ci_ggcommonality(my_formula,
                                  my_data,
                                  sample_column = "Species",
                                  resample_type = "fixed",
                                  n_replications = 1000) +
  ggtitle("Fixed-x bootstrap, resampling within species") -> p4
}

## Displaying only positive commonalities and CIs
gridExtra::grid.arrange(
p1+ylim(0, 1)+theme_classic(),
p2+ylim(0, 1)+theme_classic(),
p3+ylim(0, 1)+theme_classic(),
p4+ylim(0, 1)+theme_classic(),
ncol = 2
)
