library(shiny)
library(openxlsx)

source('load_file.r')

#allow for large excel file uploads up to 1 gb
options(shiny.maxRequestSize = 1000 * 1024^2)

# Define UI
ui <- fluidPage(
   
   # Application title
   titlePanel("File Compare"),
   
   # Sidebar
   sidebarLayout(
     sidebarPanel(
       #Import first file
       fileInput(
         inputId="file1",
         label="First File: ",
         accept = ".xlsx"
       )
     )
      ,
      
      mainPanel(
        tableOutput(outputId="file1_data")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  #file1###################################
  file1_data <- reactive({
    req(input$file1)
    load_file(input$file1$name, input$file1$datapath)
  })
  
  output$file1_data <- renderTable({
    file1_data()
  })
  ###########################################
}

# Run the application 
shinyApp(ui = ui, server = server)