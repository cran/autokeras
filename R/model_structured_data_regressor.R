#' AutoKeras Structured Data Regressor Model
#'
#' AutoKeras structured data regression class.\cr
#' To `fit`, `evaluate` or `predict`, format inputs as:
#' \itemize{
#' \item{
#' x : character or array. If the data is from a csv file, it should be a
#'   character specifying the path of the csv file of the training data.
#' }
#' \item{
#' y : character or array. If the data is from a csv file, it should be a
#'   character, which is the name of the target column. Otherwise, it can be
#'   single-column or multi-column. The values should all be numerical.
#' }
#' }
#'
#' Important: The object returned by this function behaves like an R6 object,
#' i.e., within function calls with this object as parameter, it is most likely
#' that the object will be modified. Therefore it is not necessary to assign
#' the result of the functions to the same object.
#'
#' @param column_names : A list of characters specifying the names of the
#'   columns. The length of the list should be equal to the number of columns of
#'   the data excluding the target column. Defaults to `NULL`. If `NULL`, it
#'   will obtained from the header of the csv file or the `data.frame`.
#' @param column_types : A list of characters. The names are the column names.
#'   The values should either be 'numerical' or 'categorical', indicating the
#'   type of that column. Defaults to `NULL`. If not `NULL`, the `column_names`
#'   need to be specified. If `NULL`, it will be inferred from the data.
#' @param output_dim : numeric. The number of output dimensions. Defaults to
#'   `NULL`. If `NULL`, it will infer from the data.
#' @param loss : A Keras loss function. Defaults to use "mean_squared_error".
#' @param metrics : A list of Keras metrics. Defaults to use
#'   "mean_squared_error".
#' @param name : character. The name of the AutoModel. Defaults to
#'   "structured_data_regressor".
#' @param max_trials : numeric. The maximum number of different Keras Models to
#'   try. The search may finish before reaching the `max_trials`. Defaults to
#'   `100`.
#' @param directory : character. The path to a directory for storing the search
#'   outputs. Defaults to `tempdir()`, which would create a folder with the name
#'   of the AutoModel in the current directory.
#' @param objective : character. Name of model metric to minimize or maximize,
#'   e.g. "val_accuracy". Defaults to "val_loss".
#' @param overwrite : logical. Defaults to `TRUE`. If `FALSE`, reloads an
#'   existing project of the same name if one is found. Otherwise, overwrites
#'   the project.
#' @param seed : numeric. Random seed. Defaults to `runif(1, 0, 10e6)`.
#'
#' @return A non-trained structured data regressor AutokerasModel.
#'
#' @examples
#' \dontrun{
#' library("magrittr")
#'
#' # use the iris dataset as an example
#' set.seed(8818)
#' # balanced sample 80% for training
#' train_idxs <- unlist(by(seq_len(nrow(iris)), iris$Species, function(x) {
#'   sample(x, length(x) * .8)
#' }))
#' train_data <- iris[train_idxs, ]
#' test_data <- iris[-train_idxs, ]
#'
#' colnames(iris)
#' # Sepal.Length will be the interest column to predict
#'
#' train_file <- paste0(tempdir(), "/iris_train.csv")
#' write.csv(train_data, train_file, row.names = FALSE)
#'
#' # file to predict, cant have the response "Sepal.Length" column
#' test_file_to_predict <- paste0(tempdir(), "/iris_test_2_pred.csv")
#' write.csv(test_data[, -1], test_file_to_predict, row.names = FALSE)
#'
#' test_file_to_eval <- paste0(tempdir(), "/iris_test_2_eval.csv")
#' write.csv(test_data, test_file_to_eval, row.names = FALSE)
#'
#' library("autokeras")
#'
#' # Initialize the structured data regressor
#' reg <- model_structured_data_regressor(max_trials = 10) %>% # It tries 10 different models
#'   fit(train_file, "Sepal.Length") # Feed the structured data regressor with training data
#'
#' # If you want to use own valitadion data do:
#' reg <- model_structured_data_regressor(max_trials = 10) %>%
#'   fit(
#'     train_file,
#'     "Sepal.Length",
#'     validation_data = list(test_file_to_eval, "Sepal.Length")
#'   )
#'
#' # Predict with the best model
#' (predicted_y <- reg %>% predict(test_file_to_predict))
#'
#' # Evaluate the best model with testing data
#' reg %>% evaluate(test_file_to_eval, "Sepal.Length")
#'
#' # Get the best trained Keras model, to work with the keras R library
#' export_model(reg)
#' }
#'
#' @importFrom stats runif
#' @importFrom methods new
#'
#' @export
#'
model_structured_data_regressor <- function(column_names = NULL,
                                            column_types = NULL,
                                            output_dim = NULL,
                                            loss = "mean_squared_error",
                                            metrics = NULL,
                                            name = "structured_data_regressor",
                                            max_trials = 100,
                                            directory = tempdir(),
                                            objective = "val_loss",
                                            overwrite = TRUE,
                                            seed = runif(1, 0, 10e6)) {
  if (!is.null(output_dim)) {
    output_dim <- as.integer(output_dim)
  }

  new(
    "AutokerasModel",
    model_name = "structured_data_regressor",
    model = autokeras$StructuredDataRegressor(
      column_names = column_names, column_types = column_types,
      output_dim = output_dim, loss = loss, metrics = metrics, project_name = name,
      max_trials = as.integer(max_trials), directory = directory,
      objective = objective, overwrite = overwrite, seed = as.integer(seed)
    )
  )
}
