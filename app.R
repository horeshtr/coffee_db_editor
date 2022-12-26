#
# This Shiny web app allows for the management of a coffee brewing "database"
#   maintained in Google Sheets
#

library(shiny)
library(tidyverse)
library(googledrive)
library(googlesheets4)

#######################################################
# temporary setup code
#######################################################

# authenticate
drive_auth(email = NA)
gs4_auth(token = drive_token())
drive_user()

data_file <- drive_get("Coffee Brew Log")
sheet_id <- as_sheets_id(data_file)
gs4_get(data_file)

data <- read_sheet(sheet_id)
head(data)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Coffee Brewing Data Editor"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            # radio input to select edit or create new
            radioButtons(
              inputId = "record_type",
              label = "Select:",
              choices = c("Create New Record" = "new",
                          "Edit Existing Record" = "edit")
              ),
            
            # date input for brew date
            dateInput(
              inputId = "brew_date",
              label = "Select the brew date:",
              value = today()
            )
            # text input for roaster
            # text input for country of origin
            # text input for lot/farm/region
            # text input for process
            # text input for variety
            # text input for altitude
            # date input for roast date
            # number input for coffee weight
            # number input for water weight
            # text input for grinder
            # number input for grind setting
            # number input for flavor score
            # number input for acidity score
            # number input for sweetness score
            # number input for body score
            # text input for notes
          
          # ideally, text inputs would be select inputs based on existing values, 
          #   or "other" which opens a text input
        ),

        # Show a plot of the generated distribution
        mainPanel(
           # display table output
        )
    )
)

# Define server logic
server <- function(input, output) {
  # edit existing record or write new
  
  # generate table output
  
}

# Run the application 
shinyApp(ui = ui, server = server)
