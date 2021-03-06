#' Wrapper to add the `liquidSVM` engine to the parsnip svm_rbf model
#' specification
#'
#' @return NULL
#' @export
add_liquidSVM_engine <- function() {
  parsnip::set_model_engine("svm_rbf", "classification", "liquidSVM")
  parsnip::set_model_engine("svm_rbf", "regression", "liquidSVM")
  parsnip::set_dependency("svm_rbf", "liquidSVM", "liquidSVM")
  
  parsnip::set_model_arg(
    model = "svm_rbf",
    eng = "liquidSVM",
    parsnip = "cost",
    original = "lambdas",
    func = list(pkg = "dials", fun = "cost"),
    has_submodel = FALSE
  )
  parsnip::set_model_arg(
    model = "svm_rbf",
    eng = "liquidSVM",
    parsnip = "rbf_sigma",
    original = "gammas",
    func = list(pkg = "dials", fun = "rbf_sigma"),
    has_submodel = FALSE
  )
  parsnip::set_fit(
    model = "svm_rbf",
    eng = "liquidSVM",
    mode = "regression",
    value = list(
      interface = "matrix",
      protect = c("x", "y"),
      func = c(fun = "train_liquid"),
      defaults = list(
        folds = 1,
        threads = 0
      )
    )
  )
  parsnip::set_fit(
    model = "svm_rbf",
    eng = "liquidSVM",
    mode = "classification",
    value = list(
      interface = "matrix",
      protect = c("x", "y"),
      func = c(fun = "train_liquid"),
      defaults = list(
        folds = 1,
        threads = 0
      )
    )
  )
  parsnip::set_pred(
    model = "svm_rbf",
    eng = "liquidSVM",
    mode = "regression",
    type = "numeric",
    value = list(
      pre = NULL,
      post = NULL,
      func = c(fun = "predict"),
      args =
        list(
          object = quote(object$fit),
          newdata = quote(new_data)
        )
    )
  )
  parsnip::set_pred(
    model = "svm_rbf",
    eng = "liquidSVM",
    mode = "regression",
    type = "raw",
    value = list(
      pre = NULL,
      post = NULL,
      func = c(fun = "predict"),
      args = list(
        object = quote(object$fit),
        newdata = quote(new_data))
    )
  )
  parsnip::set_pred(
    model = "svm_rbf",
    eng = "liquidSVM",
    mode = "classification",
    type = "class",
    value = list(
      pre = NULL,
      post = NULL,
      func = c(fun = "predict"),
      args =
        list(
          object = quote(object$fit),
          newdata = quote(new_data)
        )
    )
  )
  parsnip::set_pred(
    model = "svm_rbf",
    eng = "liquidSVM",
    mode = "classification",
    type = "prob",
    value = list(
      pre = function(x, object) {
        if (object$fit$predict.prob == FALSE)
          stop("`svm` model does not appear to use class probabilities. Was ",
               "the model fit with `predict.prob = TRUE`?", call. = FALSE)
        x
      },
      post = function(result, object) {
        res <- tibble::as_tibble(result)
        names(res) <- object$lvl
        res
      },
      func = c(fun = "predict"),
      args =
        list(
          object = quote(object$fit),
          newdata = quote(new_data),
          predict.prob = TRUE
        )
    )
  )
  parsnip::set_pred(
    model = "svm_rbf",
    eng = "liquidSVM",
    mode = "classification",
    type = "raw",
    value = list(
      pre = NULL,
      post = NULL,
      func = c(fun = "predict"),
      args = list(
        object = quote(object$fit),
        newdata = quote(new_data))
    )
  )
}

#' Wrapper to train the `liquidSVM` engine
#'
#' @param x A matrix of training data/
#' @param y A vector of response data.
#' @param lambdas A numeric with the amount of regularization.
#' @param gammas A numeric with the bandwidth of the gaussian kernel.
#' @param ... Other engine arguments.
#'
#' @return
#' @export
train_liquid <- function(x, y, lambdas, gammas, ...) {

  others <- list(...)

  args <- list(
    x = expr(x),
    y = expr(y),
    lambdas = expr(lambdas),
    gammas = rlang::quo(1 / !!gammas)
  )

  call <- rlang::call2(.fn = "svm", .ns = "liquidSVM", !!!args)

  if (any(sapply(others, is.null)))
    others <- others[!sapply(others, is.null)]
  
  call <- rlang::call_modify(call, !!!others)

  rlang::eval_tidy(call)
}