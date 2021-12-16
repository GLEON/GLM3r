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
    stdout_ver_line <- run_glm(dirname(nml_template_path()), verbose=NULL, system.args='--help')[3]
    if (!grepl('Version', stdout_ver_line, fixed = TRUE)){
      stop('"Version" not found in the expected message from GLM, try `as_char = FALSE`')
    }
    out <- regmatches(stdout_ver_line, regexec("(?<=Version\ ).+?(?=\ )", stdout_ver_line, perl = TRUE))[[1]]
    return(out)
  } else {
    run_glm(dirname(nml_template_path()), verbose=TRUE, system.args='--help')
  }
	
}
