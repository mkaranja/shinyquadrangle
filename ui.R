
library(shiny)
library(shinyjs)
library(base64enc)
library(magick)
library(quadrangle)

fluidPage(
  useShinyjs(),
  tags$video(id = "video", width = 300, height = 300) |> hidden(),
  tags$canvas(id = "canvas", width = 300, height = 300) |> hidden(),
  actionButton("scan", "Scan QR Code"),
  verbatimTextOutput(("result2")),
  shiny::tags$a(href="https://github.com/mkaranja/shinyquadrangle", target="_blank", "Source code in github")
)
