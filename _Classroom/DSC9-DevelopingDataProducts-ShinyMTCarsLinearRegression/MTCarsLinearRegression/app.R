library(shiny)
library(ggplot2)

# This is a proprietary model selection function: starting with a base model,
# the algorithm iteratively extends it with new variables from the dataset,
# one at a time, whose addition has the lowest P-value. The algorithm does this
# until there is no new variable which has statistically significant impact on
# the previous model, that is its addition bears a P-value greater than the
# pre-set significance level (or all the variables were used up). The algorithm
# uses ANOVA for testing.
model.selection <- function(data, initial.model, signif.threshold = 0.05)
{
  initial.variables <- strsplit(initial.model, " *[~+*] *")[[1]]
  potential.variables <- setdiff(colnames(data), initial.variables)
  
  if (length(initial.variables) > 1) # initial.model == "y ~ x ..."
  {
    model <- initial.model
    p.index <- 2
    operator <- "+"
  }
  else # initial.model == "y ~ "
  {
    model <- initial.variables[[1]]
    p.index <- 1
    operator <- "~"
  }
  
  while (length(potential.variables != 0))
  {
    p.values <-
      sapply(potential.variables,
             function (X)
               anova(lm(paste(model, operator, X), mtcars))$`Pr(>F)`[p.index])
    
    if (sum(p.values <= signif.threshold, na.rm = TRUE) == 0)
    {
      break
    }
    
    selected.variable <- potential.variables[which.min(p.values)]
    potential.variables <- potential.variables[-which.min(p.values)]
    model <- paste(model, operator, selected.variable)
    p.index <- p.index + 1
    operator <- "+"
  }
  message(paste("Selected model:", model))
  return(lm(model, data))
}

# Mapping of short parameter names to full names.
parameters <- c(
  "(Intercept)" = "",
  "mpg" = "Miles/(US) gallon",
  "cyl" = "Number of cylinders",
  "cyl4" = "4 cylinders",
  "cyl6" = "6 cylinders",
  "cyl8" = "8 cylinders",
  "disp" = "Displacement (cu.in.)",
  "hp" = "Gross horsepower",
  "drat" = "Rear axle ratio",
  "wt" = "Weight (1000 lbs)",
  "qsec"= "1/4 mile time",
  "vs" = "Engine (0 = V-shaped, 1 = straight)",
  "vs0" = "V-shaped engine",
  "vs1" = "Straight engine",
  "am" = "Transmission (0 = automatic, 1 = manual)",
  "am0" = "Automatic transmission",
  "am1" = "Manual transmission",
  "gear" = "Number of forward gears",
  "gear3" = "3 gears",
  "gear4" = "4 gears",
  "gear5" = "5 gears",
  "carb" = "Number of carburetors",
  "carb1" = "1 carburetors",
  "carb2" = "2 carburetors",
  "carb3" = "3 carburetors",
  "carb4" = "4 carburetors",
  "carb6" = "6 carburetors",
  "carb8" = "8 carburetors"
)

# Minor data transformation: some variables are converted into factors.
data(mtcars)
mtcars$am <- factor(mtcars$am)
mtcars$cyl <- factor(mtcars$cyl)
mtcars$vs <- factor(mtcars$vs)
mtcars$gear <- factor(mtcars$gear)
mtcars$carb <- factor(mtcars$carb)

# Shiny UI
ui <- fluidPage(
   
   titlePanel("Linear Regression on Motor Trend Car Road Tests (mtcars)"),
   
   sidebarLayout(
      sidebarPanel(
        selectInput("y",
                    "Select the response",
                    choices = list("1/4 mile time" = "qsec",
                                   "Displacement (cu.in.)" = "disp",
                                   "Gross horsepower" = "hp",
                                   "Miles per U.S. gallon" = "mpg",
                                   "Rear axle ratio" = "drat",
                                   "Weight (1000 lbs)" = "wt"),
                    selected = "mpg",
                    multiple = FALSE),
        sliderInput("sthres",
                     "Threshold of significance:",
                     min = 0.005,
                     max = 0.995,
                     value = 0.05,
                     step = 0.005),
        br(),
        p("You can use this application to create linear regression models on the Motor Trend Car Road Tests (mtcars) dataset for the selected response variables."),
        p("The application uses a proprietary model selection function: starting with a base model, the algorithm iteratively extends it with new variables from the dataset, one at a time, whose addition has the lowest P-value. The algorithm does this until there is no new variable which has statistically significant impact on the previous model, that is its addition bears a P-value greater than the pre-set significance level (or all the variables were used up). The algorithm uses ANOVA for testing."),
        p("Use the drop-down list to select the variable you want to create the model for."),
        p("Use the significance threshold slider to set the P-value limit mentioned above.")
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        textOutput("model"),
        plotOutput("residualPlot"),
        tableOutput("coeftbl")
      )
   )
)

# Shiny server
server <- function(input, output) {
  
  output$residualPlot <- renderPlot({
    
    inimodel <- paste0(input$y, " ~ ")

    M <- model.selection(mtcars, inimodel, input$sthres)

    ggplot(mapping = aes(x = 1:nrow(mtcars), y = resid(M))) +
      theme_light() +
      labs(x = "Model fit", y = "Residual") +
      coord_cartesian(ylim = c(-10,10)) +
      geom_point(color = I("steelblue")) +
      geom_hline(yintercept = sum(resid(M)), color = I("steelblue"))
    
   })
  
  output$model <- renderText({
    
    inimodel <- paste0(input$y, " ~ ")
    
    M <- model.selection(mtcars, inimodel, input$sthres)
    
    paste0("Selected model: ", inimodel, paste(names(M$coefficients)[-1], collapse = " + "))

  })
  
  output$coeftbl <- renderTable({

    inimodel <- paste0(input$y, " ~ ")

    M <- model.selection(mtcars, inimodel, input$sthres)
    
    data.frame('Model coef.' = names(M$coefficients),
               'Full name' = parameters[names(M$coefficients)],
               'Coef. value' = M$coefficients,
               row.names = NULL, check.names = FALSE)
    
  }, rownames = FALSE)
}

# Running the Shiny application 
shinyApp(ui = ui, server = server)

