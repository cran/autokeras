#' Search for the Best Model and Hyperparameters
#'
#' It will search for the best model and hyperparameters based on the
#' performances on validation data.
#'
#' @param object : An AutokerasModel instance.
#' @param x : Training data x. Check corresponding AutokerasModel help to note
#'   how it should be provided.
#' @param y : Training data y. Check corresponding AutokerasModel help to note
#'   how it should be provided.
#' @param epochs : numeric. The number of epochs to train each model during the
#'   search. If unspecified, by default we train for a maximum of `1000` epochs,
#'   but we stop training if the validation loss stops improving for 10 epochs
#'   (unless you specified an EarlyStopping callback as part of the `callbacks`
#'   argument, in which case the EarlyStopping callback you specified will
#'   determine early stopping).
#' @param callbacks : list of Keras callbacks to apply during training and
#'   validation.
#' @param validation_split : numeric between 0 and 1. Defaults to `0.2`.
#'   Fraction of the training data to be used as validation data. The model will
#'   set apart this fraction of the training data, will not train on it, and
#'   will evaluate the loss and any model metrics on this data at the end of
#'   each epoch. The validation data is selected from the last samples in the
#'   `x` and `y` data provided, before shuffling. This argument is not supported
#'   when `x` is a dataset. The best model found would be fit on the entire
#'   dataset including the validation data.
#' @param validation_data : Data on which to evaluate the loss and any model
#'   metrics at the end of each epoch. The model will not be trained on this
#'   data. `validation_data` will override `validation_split`. The type of the
#'   validation data should be the same as the training data. The best model
#'   found would be fit on the training dataset without the validation data.
#' @param ... : Unused.
#'
#' @return A trained AutokerasModel.
#'
#' @examples
#' \dontrun{
#' library("keras")
#'
#' # use the MNIST dataset as an example
#' mnist <- dataset_mnist()
#' c(x_train, y_train) %<-% mnist$train
#' c(x_test, y_test) %<-% mnist$test
#'
#' library("autokeras")
#'
#' # Initialize the image classifier
#' clf <- model_image_classifier(max_trials = 10) %>% # It tries 10 different models
#'   fit(x_train, y_train) # Feed the image classifier with training data
#'
#' # If you want to use own valitadion data do:
#' clf <- model_image_classifier(max_trials = 10) %>%
#'   fit(
#'     x_train,
#'     y_train,
#'     validation_data = list(x_test, y_test)
#'   )
#'
#' # Predict with the best model
#' (predicted_y <- clf %>% predict(x_test))
#'
#' # Evaluate the best model with testing data
#' clf %>% evaluate(x_test, y_test)
#'
#' # Get the best trained Keras model, to work with the keras R library
#' export_model(clf)
#' }
#'
#' @importFrom reticulate np_array
#' @importFrom keras fit
#' @rawNamespace export(fit)
#'
#' @name fit
NULL

#' @rdname fit
#' @export
#'
fit.AutokerasModel <- function(object,
                               x = NULL,
                               y = NULL,
                               epochs = 1000,
                               callbacks = NULL,
                               validation_split = 0.2,
                               validation_data = NULL,
                               ...) {
  if (object@model_name %in% c("text_classifier", "text_regressor")) {
    # for these models, x has to be an array of strings
    x <- np_array(x, dtype = "unicode")
    if (!is.null(validation_data) && length(validation_data) == 2) {
      validation_data[[1]] <- np_array(validation_data[[1]], dtype = "unicode")
    }
  }

  object@model$fit(
    x = x, y = y, epochs = as.integer(epochs), callbacks = callbacks,
    validation_split = validation_split, validation_data = validation_data
  )
  return(invisible(object))
}
