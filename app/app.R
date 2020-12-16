library(shiny)
library(openxlsx)
library(DT)
library(shinybusy)

source('file_utilities.r')

#allow for large excel file uploads up to 1 gb
options(shiny.maxRequestSize = 1000 * 1024^2)

# Define UI
ui <- fluidPage(
  
   # Application title
  includeCSS('www/styles.css'),
   titlePanel(h1("File Compare", align = "center")),
  
  spin_kit(spin = "fading-circle"),
   
   # Sidebar
   sidebarLayout(
     
     sidebarPanel(
       h4("1. Import files "),
       div(class='sidebar-controlset',
         
         #Import first file
         fileInput(inputId="file",
                   label="Browse for file: ",
                   accept = ".xlsx"
         ),
         numericInput(inputId = 'start_row',
            label = 'Start row',
            value=1,
            min=1,
            max=1048576,
            step=1
          ),
         selectInput(
           inputId='sheet',
           label='Worksheet',
           choices=c(),
           selected = NULL,
           multiple = FALSE
         ),
         actionButton(
           inputId="import", 
           label="Import file"
         )
      ),
     br(),
     h4('2. Specify columns'),
     div(class='sidebar-controlset',
         
         selectInput(
           inputId='join',
           label='Select join key: ',
           choices=c(),
           selected = NULL,
           multiple = FALSE
         ),
         selectInput(
           inputId='compare',
           label='Select compare columns: ',
           choices=c(),
           selected = NULL,
           multiple = TRUE
         )
     ),
     br(),
     h4('3. Compare files'),
     div(class='sidebar-controlset',
         actionButton(
           inputId="run_compare",
           label="Click to compare files"
         )
      ),
     h4('4. Download data'),
     div(class='sidebar-controlset',
        downloadButton("downloadData", "Download")
     )
     ),
      mainPanel(
        h4('4. Review Files'),
        tabsetPanel(id = 'all_files',
          tabPanel("Instructions", 
            div(class='mainbar-controlset',
                p('Upload files to begin')
                )
          ),
          tabPanel("Combined file",
                   DT::dataTableOutput(outputId='combined_data')
          )
        )
      )
    )
  )

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  #file data
  all_file_data <- reactiveValues(
    files = list(), 
    file_count=0, 
    file_names = list(),
    transform_files = list(),
    combined_data = NULL
    )
  file_upload_options <- observeEvent(input$file, {
      req(input$file)
      
      #get names of sheets
      sheet_list = openxlsx::getSheetNames(input$file$datapath)
      updateSelectInput(
        session, 
        inputId='sheet',
        choices = sheet_list ,
        selected = sheet_list[[1]]
        )
    }
  )
    
  file_upload <- observeEvent(input$import, {
      #Upload File
      req(input$file)
      
      #Get general file information
      all_file_data$file_count <- all_file_data$file_count + 1
      
      file_id <- paste0(all_file_data$file_count, '_', input$file$name)
      all_file_data$file_names <- append(all_file_data$file_names, file_id)
      

      
      #add tqb for file contents
      insertTab(inputId = "all_files",
                tabPanel(file_id, DT::dataTableOutput({outputId=file_id})),
                target='Instructions',
                position = "after")
      
      updateTabsetPanel(session, 'all_files', selected = file_id)
      show_modal_spinner(spin='fading-circle') # show the modal window
      
      #load data from file, within render datatable to trigger CSS loader
      file_info <- load_file(
        name=input$file$name, 
        path=input$file$datapath,
        start_row=input$start_row,
        sheet=input$sheet
      )
      files <- all_file_data$files
      files[[all_file_data$file_count]] <- file_info
      all_file_data$files <- files
      
      output[[file_id]] <- DT::renderDataTable({
        #render to table
        file_info
      })
      
      remove_modal_spinner() # remove it when done
      
      common_columns = get_common_columns(all_file_data$files)
      
      #get possible join keys and output columns
      updateSelectInput(
        session, 
        inputId='join',
        choices = common_columns,
        selected = common_columns[[1]]
      )
      updateSelectInput(
        session, 
        inputId='compare',
        choices = common_columns
      )
    }
  )
  
  run_compare <- observeEvent(input$run_compare,{
    updateTabsetPanel(session, 'all_files', selected = 'Combined file')
    show_modal_spinner(spin='fading-circle') 
    files <- all_file_data$files
    for(file_index in 1:length(files)){
      files[[file_index]] <-pivot_file(
        files[[file_index]],
        key_column = input$join,
        keep_columns = input$compare
      )
    }
    all_file_data$transform_files <- files
    join_on=join_on = c('field'='field')
    join_on[input$join] <- input$join
    
    all_file_data$combined_data <- join_data(files, all_file_data$file_names, join_on)
    
    output$combined_data <- DT::renderDataTable({

      
      all_file_data$combined_data
      
      })
    remove_modal_spinner()
  }
  
  )
  output$downloadData <- downloadHandler(
    filename = function() {
      "output.csv"
    },
    content = function(file) {
      write.csv(all_file_data$combined_data, file, row.names = FALSE)
    }
  )
  
}

# Run the application 
shinyApp(ui = ui, server = server)