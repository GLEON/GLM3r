#'@title run the GLM model
#'
#'@description
#'This runs the GLM model on the specific simulation stored in \code{sim_folder}. 
#'The specified \code{sim_folder} must contain a valid NML file.
#'
#'@param sim_folder the directory where simulation files are contained
#'@param version GLM version. Default is '3.0'. Can also choose '2.2'
#'@param verbose Logical: Should output of GLM be shown
#'@param args Optional arguments to pass to GLM executable
#'
#'@keywords methods
#'@author
#'Jordan Read, Luke Winslow
#'@examples 
#'sim_folder <- system.file('extdata', package = 'GLMr')
#'run_glm(sim_folder)
#'\dontrun{
#'out_file <- file.path(sim_folder,'output.nc')
#'nml_file <- file.path(sim_folder,'glm2.nml')
#'library(glmtools)
#'fig_path <- tempfile("temperature", fileext = '.png')
#'plot_temp(file = out_file, fig_path = fig_path)
#'cat('find plot here: '); cat(fig_path)
#' }
#'@export
#'@importFrom utils packageName
run_glm <- function(sim_folder = '.', version = '3.0', verbose=TRUE, args=character()) {
	
  # Must have .nml file in sim folder. Can be either glm2.nml or glm3.nml
	if(!any((c('glm2.nml','glm3.nml') %in% list.files(sim_folder)))){
		stop('You must have a valid glm2.nml or glm3.nml file in your sim_folder: ', sim_folder)
	}
	

	### Windows ###
	if(.Platform$pkgType == "win.binary"){
	  if(version == '3.0'){
		  return(run_glm3.0_Win(sim_folder, verbose, args))
	  } else if (version == '2.2') {
	    return(run_glm2.2_Win(sim_folder, verbose, args))
	  }
	}
  
  ### macOS ###
  if (grepl('mac.binary',.Platform$pkgType)) { 
    maj_v_number <- as.numeric(strsplit(
      Sys.info()["release"][[1]],'.', fixed = TRUE)[[1]][1])
    
    if (maj_v_number < 13.0) {
      stop('pre-mavericks mac OSX is not supported. Consider upgrading')
    }
    
    if(version == '3.0'){
      return(run_glm3.0_OSx(sim_folder, verbose, args))
    } else if (version == '2.2') {
      return(run_glm2.2_OSx(sim_folder, verbose, args))
    }
  }
    
  if(.Platform$pkgType == "source") {
		## Probably running linux
		#stop("Currently UNIX is not supported by ", getPackageName())
    if(version == '3.0'){
      return(run_glmNIX(sim_folder, verbose, args))
    } else if (version == '2.2') {
      return(run_glmNIX(sim_folder, verbose, args))
    }
	}
	
}

  
glm.systemcall <- function(sim_folder = sim_folder, glm_path = glm_path, verbose = verbose, args = args) {
  origin <- getwd()
  setwd(sim_folder)
  
  tryCatch({
    if (verbose){
      out <- system2(glm_path, wait = TRUE, stdout = "", 
                     stderr = "", args=args)
    } else {
      out <- system2(glm_path, wait = TRUE, stdout = NULL, 
                     stderr = NULL, args=args)
    }
    setwd(origin)
    return(out)
  }, error = function(err) {
    print(paste("GLM_ERROR:  ",err))
    setwd(origin)
  })
}

### Windows ###
run_glm2.2_Win <- function(sim_folder, verbose, args){
  if(.Platform$r_arch == 'i386'){
    glm_path <- system.file('extbin/glm_2.2.0_x32/glm.exe', package=packageName())
    glm.systemcall(sim_folder, glm_path, verbose, args)
  }else{
    glm_path <- system.file('extbin/glm_2.2.0_x64/glm.exe', package=packageName())
    glm.systemcall(sim_folder, glm_path, verbose, args)
  }
}

run_glm3.0_Win <- function(sim_folder, verbose, args){
    glm_path <- system.file('extbin/glm_3.0.0_x64/glm.exe', package=packageName())
    glm.systemcall(sim_folder, glm_path, verbose, args)
}

### macOS ###
run_glm3.0_OSx <- function(sim_folder, verbose, args){
  glm_path <- system.file('exec/macglm3', package=packageName())
  glm.systemcall(sim_folder, glm_path, verbose, args)
  
}

run_glm2.2_OSx <- function(sim_folder, verbose, args){
  glm_path <- system.file('exec/glm_2.2.0_macos/macglm', package=packageName())
  glm.systemcall(sim_folder, glm_path, verbose, args)
}

run_glmNIX <- function(sim_folder, verbose, args){
  glm_path <- system.file('exec/nixglm', package=packageName())
  
  Sys.setenv(LD_LIBRARY_PATH=system.file('extbin/nixGLM', 
                                         package=packageName()))
  glm.systemcall(sim_folder, glm_path, verbose, args)

}
