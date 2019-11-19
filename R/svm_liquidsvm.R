#' Wrapper to add the `liquidSVM` engine to the parsnip svm_rbf model
#' specification
#'
#' @return NULL
#' @export
#' @importFrom parsnip set_model_engine set_dependency set_model_arg set_fit
#' set_pred
add_liquidSVM_engine <- function() {
  set_model_engine("svm_rbf", "classification", "liquidSVM")
  set_model_engine("svm_rbf", "regression", "liquidSVM")
  set_dependency("svm_rbf", "liquidSVM", "liquidSVM")
  
  set_model_arg(
    model = "svm_rbf",
    eng = "liquidSVM",
    parsnip = "cost",
    original = "lambdas",
    func = list(pkg = "dials", fun = "cost"),
    has_submodel = FALSE
  )
  
  set_model_arg(
    model = "svm_rbf",
    eng = "liquidSVM",
    parsnip = "rbf_sigma",
    original = "gammas",
    func = list(pkg = "dials", fun = "rbf_sigma"),
    has_submodel = FALSE
  )
  
  set_model_arg(
    model = "svm_rbf",
    eng = "liquidSVM",
    parsnip = "margin",
    original = "epsilon",
    func = list(pkg = "dials", fun = "margin"),
    has_submodel = FALSE
  )
  
  set_fit(
    model = "svm_rbf",
    eng = "liquidSVM",
    mode = "regression",
    value = list(
      interface = "matrix",
      protect = c("x", "y"),
      func = c(pkg = "liquidSVM", fun = "svm"),
      defaults = list(folds = 5)
    )
  )
  
  set_fit(
    model = "svm_rbf",
    eng = "liquidSVM",
    mode = "classification",
    value = list(
      interface = "matrix",
      protect = c("x", "y"),
      func = c(pkg = "liquidSVM", fun = "svm"),
      defaults = list(folds = 5)
    )
  )
  
  set_pred(
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
  
  set_pred(
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
  
  set_pred(
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
  
  set_pred(
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
        res <- as_tibble(result)
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
  
  set_pred(
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