#'@title run the GLM model
#'
#'@description
#'This runs the GLM model on the specific simulation stored in \code{sim_folder}. 
#'The specified \code{sim_folder} must contain a valid NML file.
#'
#'@param sim_folder the directory where simulation files are contained
#'@param verbose Logical: Should output of GLM be shown, or 
#' use `NULL` to capture output as a character vector
#'@param system.args Optional arguments to pass to GLM executable
#'
#'@keywords methods
#'@author
#'Jordan Read, Luke Winslow, Hilary Dugan 
#'@examples 
#'sim_folder <- system.file('extdata', package = 'GLM3r')
#'run_glm(sim_folder)
#'\dontrun{
#'out_file <- file.path(sim_folder,'Output/output.nc')
#'nml_file <- file.path(sim_folder,'glm3.nml')
#'library(glmtools)
#'plot_temp(nc_file = out_file)
#'cat('find plot here: '); cat(fig_path)
#' }
#'@importFrom utils packageName
#'@export
run_glm <- function(sim_folder = '.', verbose=TRUE, system.args=character()) {
	
  # Must have .nml file in sim folder. Can be either glm2.nml or glm3.nml
	if(!'glm3.nml' %in% list.files(sim_folder)){
		stop('You must have a valid glm3.nml file in your sim_folder: ', sim_folder)
	}
	

	### Windows ###
	if(.Platform$pkgType == "win.binary"){
		return(run_glm3.0_Win(sim_folder, verbose, system.args))
	}
  
  ### macOS ###
  if (grepl('mac.binary',.Platform$pkgType)) { 
    maj_v_number <- as.numeric(strsplit(
      Sys.info()["release"][[1]],'.', fixed = TRUE)[[1]][1])
    
    if (maj_v_number < 13.0) {
      stop('pre-mavericks mac OSX is not supported. Consider upgrading')
    }
    
    return(run_glm3.0_OSx(sim_folder, verbose, system.args))
   
  }
    
  if(.Platform$pkgType == "source") {
		## Probably running linux
		#stop("Currently UNIX is not supported by ", getPackageName())
      return(run_glmNIX(sim_folder, verbose, system.args))
	}
	
}

  
glm.systemcall <- function(sim_folder, glm_path, verbose, system.args) {
  
  if(nchar(Sys.getenv("GLM_PATH")) > 0){
    glm_path <- Sys.getenv("GLM_PATH")
    warning(paste0(
      "Custom path to GLM executable set via 'GLM_PATH' environment variable as: ", 
      glm_path))
  }
  
  origin <- getwd()
  setwd(sim_folder)
  
  tryCatch({
    if (is.null(verbose)){
      out <- system2(glm_path, wait = TRUE, stdout = TRUE, 
                     stderr = NULL, args = system.args)
    } else if (verbose) {
      out <- system2(glm_path, wait = TRUE, stdout = "", 
                     stderr = "", args = system.args)
    } else {
      out <- system2(glm_path, wait = TRUE, stdout = NULL, 
                     stderr = NULL, args = system.args)
    }
    setwd(origin)
    return(out)
  }, error = function(err) {
    print(paste("GLM_ERROR:  ",err))
    setwd(origin)
  })
}

### Windows ###
run_glm3.0_Win <- function(sim_folder, verbose, system.args){
    glm_path <- system.file('extbin/glm-3.0.5_x64/glm.exe', package=packageName())
    glm.systemcall(sim_folder, glm_path, verbose, system.args)
}

### macOS ###
run_glm3.0_OSx <- function(sim_folder, verbose, system.args){
  glm_path <- system.file('exec/macglm3', package = 'GLM3r')
  glm.systemcall(sim_folder = sim_folder, glm_path = glm_path, verbose = verbose, system.args = system.args)
}

### Linux ###
run_glmNIX <- function(sim_folder, verbose, system.args){
  glm_path <- system.file('exec/nixglm', package=packageName())
  
  if(nchar(Sys.getenv("GLM_PATH")) == 0){
    Sys.setenv(LD_LIBRARY_PATH=paste(system.file('extbin/nixGLM', 
                                           package=packageName()), 
                                     Sys.getenv('LD_LIBRARY_PATH'), 
                                     sep = ":"))
  }
  glm.systemcall(sim_folder, glm_path, verbose, system.args)

}
