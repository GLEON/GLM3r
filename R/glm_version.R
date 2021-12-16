#'@title Return the current GLM model version 
#'
#'@param as_char return glm version as a character string? (TRUE/FALSE)
#'@description 
#'Returns the current version of the GLM model being used
#'
#'@keywords methods
#'
#'@author
#'Luke Winslow, Jordan Read
#'@examples 
#' print(glm_version())
#'
#'
#'@export
glm_version <- function(as_char = FALSE){
  if (as_char){
    messg_out <- run_glm(dirname(nml_template_path()), verbose=NULL, system.args='--help')
    # only check the first 6 lines to avoid mistakenly catching words that are in the doc flags
    version_line <- grepl('Version', messg_out[1:6], fixed = TRUE)
    if (!any(version_line)){
      stop('"Version" not found in the expected message from GLM, try `as_char = FALSE`')
    }
    out <- regmatches(messg_out[version_line][1L], regexec("(?<=Version\ ).+?(?=\ )", messg_out[version_line][1L], perl = TRUE))[[1]]
    return(out)
  } else {
    run_glm(dirname(nml_template_path()), verbose=TRUE, system.args='--help')
  }
	
}
