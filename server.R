
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

function(input, output) {
  observeEvent(input$scan, {
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
          Shiny.onInputChange('imageData', base64Image);
        }, 500); // Reduced refresh rate
      }).catch(function(err) {
        console.error('Error accessing camera: ', err);
      });
    ")
  })

  output$result <- renderPrint({
    req(input$imageData)
    imageData <- input$imageData
    # Remove the "data:image/png;base64," prefix from the base64 image data
    imageData <- gsub("data:image/png;base64,", "", imageData)
    # Convert the base64 image data to binary
    binaryImageData <- base64decode(imageData)

    # Read the binary image data into an image object
    magickImage <- image_read(binaryImageData)

    # Decode the QR code using qr_decode()
    result <- try(quadrangle::qr_scan(magickImage)$values$value)
    result
  })
}
