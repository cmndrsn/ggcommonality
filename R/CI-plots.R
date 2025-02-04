ci_plot_coordinates <- function(
    data.boot,
    formula,
    data,
    include_total = TRUE,
    n_replications = 1000,
    quantiles = c(.025, .975)
) {
  coef <- yhat::regr(
    lm(
      formula = formula,
      data = data
    )
  )$Commonality_Data$CC


  coef <- as.data.frame(coef)
  coef <- tibble::rownames_to_column(as.data.frame(coef), var = "var")
  names(coef) <- c("var", "cc", "cc_pct")
  bs_ci <- apply(
    data.boot,
    1,
    FUN = function(x) {
      quantile(x,
               quantiles
      )

    }


  )



  bs_ci <- t(bs_ci) |>
    as.data.frame() |>
    tibble::rownames_to_column()
  names(bs_ci) <- c("var", "lci", "uci")

  bs_ci <- merge(bs_ci, coef)

  bs_ci$var <- bs_ci$var |>
    stringr::str_remove_all("Common to |Unique to | and | ")

  bs_ci$com <- bs_ci$var

  bs_ci <- bs_ci |>
    tidyr::separate_longer_delim(
      cols = "var",
      delim = ","
    )
  bs_ci <- bs_ci |>
    group_by(com) |>
    mutate(count = as.numeric(factor(var)))
  # define length of each line based on which position it is in the CA
  #bs_ci$xmax <- bs_ci$lci + ((bs_ci$uci-bs_ci$lci)/bs_ci$count)

  bs_ci$order <- stringr::str_count(bs_ci$com, ",")+1

  bs_ci$xmin <-as.numeric(as.factor(bs_ci$com))
  bs_ci$start_pos <- as.numeric(as.factor(bs_ci$com)) - 0.45
  bs_ci$end_pos <- bs_ci$xmin + 0.45
  bs_ci$end_pos <- bs_ci$start_pos +
    bs_ci$count * ((bs_ci$end_pos-bs_ci$start_pos)/bs_ci$order)


  bs_ci <- bs_ci |>
    group_by(com) |>
    mutate(outline_ymin = min(lci),
           outline_ymax = max(uci),
           outline_xmin = min(start_pos),
           outline_xmax = max(end_pos))


  bs_ci <- bs_ci[order(bs_ci$order),]
  bs_ci <- bs_ci |>
    group_by(com) |>
    mutate(end_pos = rev(end_pos))

  bs_ci$com <- factor(bs_ci$com, levels = unique(bs_ci$com))
  bs_ci <- bs_ci |>
    group_by(com) |>
    mutate(
      end_pos = sort(
        end_pos,
        decreasing = TRUE)
      )

  if(!include_total) {
    bs_ci <- bs_ci |> dplyr::filter(com != "Total")
  }

  return(bs_ci)

}

com_linerange <- function(df, t = NULL,s = NULL) {
  df |>
    ggplot(
      aes(x = xmin, xmin = xmin, y = cc,
          ymin = lci, ymax = uci)) +
    geom_rect(aes(xmin=outline_xmin,
                  xmax = outline_xmax,
                  ymin = outline_ymin,
                  ymax = outline_ymax),
              colour = "black", size = 1.25)+
    geom_rect(aes(xmin=start_pos, xmax = end_pos, fill = var))+
    geom_point(colour = "black")+
    scale_x_continuous(breaks = df$xmin, labels = factor(df$com, levels = unique(df$com)))+
    ggtitle(t,s)
}
