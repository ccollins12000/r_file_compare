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
       ),
       #Import second file
       fileInput(
         inputId="file2",
         label="Second File: ",
         accept = ".xlsx"
       )
     )
      ,
      
      mainPanel(
        tabsetPanel(type = "tabs",
                    tabPanel("Instructions", p('Upload files to begin')),
                    tabPanel("File 1", 
                             tableOutput(outputId="file1_data")
                             ),
                    tabPanel("File 2", 
                             tableOutput(outputId="file2_data")
                    )
        )
        
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
  
  #file2###################################
  file2_data <- reactive({
    req(input$file2)
    load_file(input$file2$name, input$file2$datapath)
  })
  
  output$file2_data <- renderTable({
    file2_data()
  })
  ###########################################
}

# Run the application 
shinyApp(ui = ui, server = server)