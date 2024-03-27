
library(shiny)
library(shinyjs)
library(base64enc)
library(magick)
library(quadrangle)

fluidPage(
  useShinyjs(),
  tags$video(id = "video", width = 300, height = 300),
  tags$canvas(id = "canvas", width = 300, height = 300),
  actionButton("scan", "Scan QR Code"),
  verbatimTextOutput("result"),
  shiny::tags$a(href="https://github.com/mkaranja/shinyquadrangle", target="_blank", "code")
)
