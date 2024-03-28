
library(shiny)
library(shinyjs)
library(base64enc)
library(magick)
library(quadrangle)

library(shiny)
library(shinyjs)
library(base64enc)
library(magick)
library(quadrangle)

function(input, output, session) {
  observeEvent(input$scan, {
    shinyjs::show("video")

    runjs("
      navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } }).then(function(stream) {
        var video = document.getElementById('video');
        video.srcObject = stream;
        video.play();
        var canvas = document.getElementById('canvas');
        var context = canvas.getContext('2d');
        var captureInterval = setInterval(function() {
          context.drawImage(video, 0, 0, 300, 300);
          var imageData = context.getImageData(0, 0, 300, 300);
          var base64Image = canvas.toDataURL('image/png');
          Shiny.setInputValue('imageData', base64Image);
        }, 500); // Increased interval for better performance
      }).catch(function(err) {
        console.error('Error accessing camera: ', err);
      });
    ")
  })

  qr_scan_result <- reactive({
    req(input$imageData)
    imageData <- input$imageData
    if (!is.null(imageData)) {

      # Remove the "data:image/png;base64," prefix from the base64 image data
      imageData <- gsub("data:image/png;base64,", "", imageData)
      # Convert the base64 image data to binary
      binaryImageData <- base64decode(imageData)

      # Read the binary image data into an image object
      magickImage <- image_read(binaryImageData)

      # Decode the QR code using qr_decode()
      try(quadrangle::qr_scan(magickImage)$values$value, silent = TRUE)
    }
  })

  observeEvent( qr_scan_result() , {
    if(length(qr_scan_result())>0){
      #updateTextInput(session, "result", "Identity", value = qr_scan_result())
      stopVideoStream()
      shinyjs::hide("video")
    }
  })


  output$result2 <- renderPrint({
    qr_scan_result()
  })

  stopVideoStream <- function() {
    runjs("
      var video = document.getElementById('video');
      var stream = video.srcObject;
      if (stream) {
        var tracks = stream.getTracks();
        tracks.forEach(function(track) {
          track.stop();
        });
        video.srcObject = null;
      }
    ")
  }
}
