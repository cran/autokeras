R Interface to AutoKeras
================

[![Travis Build
Status](https://travis-ci.org/r-tensorflow/autokeras.svg?branch=master)](https://travis-ci.org/r-tensorflow/autokeras)
[![Coverage
status](https://img.shields.io/codecov/c/github/jcrodriguez1989/autokeras/master.svg)](https://codecov.io/github/jcrodriguez1989/autokeras?branch=master)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

[AutoKeras](https://autokeras.com/) is an open source software library
for automated machine learning (AutoML). It is developed by [DATA
Lab](https://people.engr.tamu.edu/xiahu/index.html) at Texas A&M
University and community contributors. The ultimate goal of AutoML is to
provide easily accessible deep learning tools to domain experts with
limited data science or machine learning background. AutoKeras provides
functions to automatically search for architecture and hyperparameters
of deep learning models.

Check out the [AutoKeras blogpost at the **RStudio TensorFlow for R
blog**](https://blogs.rstudio.com/tensorflow/posts/2019-04-16-autokeras/).

## Dependencies

-   [AutoKeras](https://autokeras.com/) requires Python &gt;= 3.5 .

## Installation

Install the current released version of `{autokeras}` from
[CRAN](https://cran.r-project.org/package=autokeras):

``` r
install.packages("autokeras")
```

Or install the development version from GitHub:

``` r
if (!require("remotes")) {
  install.packages("remotes")
}
remotes::install_github("r-tensorflow/autokeras")
```

Then, use the `install_autokeras()` function to install TensorFlow:

``` r
library("autokeras")
install_autokeras()
```

## Docker

`autokeras` R package has a configured Docker image.

Steps to run it:

From a bash console:

``` bash
docker pull jcrodriguez1989/r-autokeras:1.0.0
docker run -it jcrodriguez1989/r-autokeras:1.0.0 /bin/bash
```

To run the docker image, and share the current folder (in home machine)
to the `/data` path (in the docker machine), then do:

``` bash
docker run -it -v ${PWD}:/data jcrodriguez1989/r-autokeras:1.0.0 /bin/bash
ls /data # once when the docker image is running
```

## Examples

### CIFAR-10 dataset

``` r
library("keras")

# Get CIFAR-10 dataset, but not preprocessing needed
cifar10 <- dataset_cifar10()
c(x_train, y_train) %<-% cifar10$train
c(x_test, y_test) %<-% cifar10$test
```

``` r
library("autokeras")

# Create an image classifier, and train 10 different models
clf <- model_image_classifier(max_trials = 10) %>%
  fit(x_train, y_train)
```

``` r
# And use it to evaluate, predict
clf %>% evaluate(x_test, y_test)
```

``` r
clf %>% predict(x_test[1:10, , , ])
```

``` r
# Get the best trained Keras model, to work with the keras R library
(keras_model <- export_model(clf))
```

### IMDb dataset

``` r
library("keras")

# Get IMDb dataset
imdb <- dataset_imdb(num_words = 1000)
c(x_train, y_train) %<-% imdb$train
c(x_test, y_test) %<-% imdb$test

# AutoKeras procceses each text data point as a character vector,
# i.e., x_train[[1]] "<START> this film was just brilliant casting..",
# so we need to transform the dataset.
word_index <- dataset_imdb_word_index()
word_index <- c(
  "<PAD>", "<START>", "<UNK>", "<UNUSED>",
  names(word_index)[order(unlist(word_index))]
)
x_train <- lapply(x_train, function(x) {
  paste(word_index[x + 1], collapse = " ")
})
x_test <- lapply(x_test, function(x) {
  paste(word_index[x + 1], collapse = " ")
})

x_train <- matrix(unlist(x_train), ncol = 1)
x_test <- matrix(unlist(x_test), ncol = 1)
y_train <- array(unlist(y_train))
y_test <- array(unlist(y_test))
```

``` r
library("autokeras")

# Create a text classifier, and train 10 different models
clf <- model_text_classifier(max_trials = 10) %>%
  fit(x_train, y_train)
```

``` r
# And use it to evaluate, predict
clf %>% evaluate(x_test, y_test)
```

``` r
clf %>% predict(x_test[1:10])
```

``` r
# Get the best trained Keras model, to work with the keras R library
export_model(clf)
```
