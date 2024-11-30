library(hexSticker)


p <- ggcommonality(formula = mpg ~ cyl + disp + vs + drat,
                   data = mtcars)
p <- p + theme_void() + theme_transparent() + theme(legend.position = "none")

ggplot2::ggsave("transparent.png")

imgurl <- "transparent.png"
sticker(paste0(getwd(), "/", imgurl), package="ggcommonality",
        s_x=1, s_y=.85, s_width=.65,
        p_color = "grey",
        h_fill = "purple4", h_color = "purple",
        filename="ggcommonality_sticker.png")
