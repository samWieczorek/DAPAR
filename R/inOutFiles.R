
#' Saves the parameters of a tool in the pipeline of Prostar
#' 
#' @title Saves the parameters of a tool in the pipeline of Prostar
#' 
#' @param obj An object of class \code{MSnSet}
#' 
#' @param name.dataset The name of the dataset
#' 
#' @param name The name of the tool. Available values are: "Norm, Imputation, 
#' anaDiff, GOAnalysis,Aggregation"
#' 
#' @param l.params A list that contains the parameters
#' 
#' @return An instance of class \code{MSnSet}.
#' 
#' @author Samuel Wieczorek
#' 
#' @examples 
#' utils::data(Exp1_R25_pept, package='DAPARdata')
#' l.params=list(method="Global quantile alignment", type="overall")
#' saveParameters(Exp1_R25_pept, "Filtered.peptide", "Imputation",l.params)
#' 
#' @export
#' 
saveParameters <- function(obj,name.dataset=NULL,name=NULL,l.params=NULL){
  if ( is.null(name) || is.null(name.dataset)) {
    warning("No operation has been applied to the dataset.")
    return(obj)
  }
  tmp <- list()
  if(is.null(l.params)){
    tmp[[name]] <- list()
  } else {
    tmp[[name]] <- l.params
  }
  
  obj@experimentData@other$Params[[name.dataset]] <- tmp
  #obj@processingData@processing <- c(obj@processingData@processing , buildLogText(name, l.params, level=obj@experimentData@other$typeOfData))
  
  return(obj)
}



#' Builds an object of class \code{MSnSet} from a 
#' single tabulated-like file for quantitative and meta-data and a dataframe 
#' for the samples description. It differs from
#' the original \code{MSnSet} builder which requires three separated files 
#' tabulated-like quantitative proteomic data into a \code{MSnSet} object,
#' including metadata.
#' 
#' @title Creates an object of class \code{MSnSet} from text file
#' 
#' @param file The name of a tab-separated file that contains the data.
#' 
#' @param metadata A dataframe describing the samples (in lines).
#' 
#' @param indExpData A vector of string where each element is the name
#' of a column in designTable that have to be integrated in
#' the \code{fData()} table of the \code{MSnSet} object.
#' 
#' @param colnameForID The name of the column containing the ID of entities 
#' (peptides or proteins)
#' 
#' @param indexForMetacell xxxxxxxxxxx
#' 
#' @param logData A boolean value to indicate if the data have to be
#' log-transformed (Default is FALSE)
#' 
#' @param replaceZeros A boolean value to indicate if the 0 and NaN values of
#' intensity have to be replaced by NA (Default is FALSE)
#' 
#' @param pep_prot_data A string that indicates whether the dataset is about
#' 
#' @param proteinId xxxx
#' 
#' @param software xxx
#' 
#' @return An instance of class \code{MSnSet}.
#' 
#' @author Florence Combes, Samuel Wieczorek
#' 
#' @examples 
#' require(Matrix)
#' exprsFile <- system.file("extdata", "Exp1_R25_pept.txt", package="DAPARdata")
#' metadataFile <- system.file("extdata", "samples_Exp1_R25.txt", 
#' package="DAPARdata")
#' metadata = read.table(metadataFile, header=TRUE, sep="\t", as.is=TRUE)
#' indExpData <- c(56:61)
#' indFData <- c(1:55,62:71)
#' colnameForID <- 'id'
#' obj <- createMSnset(exprsFile, metadata,indExpData,  indFData, colnameForID, 
#' indexForMetacell = c(43:48), pep_prot_data = "peptide", software = 'maxquant')
#' 
#' 
#' exprsFile <- system.file("extdata", "Exp1_R25_pept.txt", package="DAPARdata")
#' metadataFile <- system.file("extdata", "samples_Exp1_R25.txt", package="DAPARdata")
#' metadata = read.table(metadataFile, header=TRUE, sep="\t", as.is=TRUE)
#' indExpData <- c(56:61)
#' colnameForID <- 'AutoID'
#' obj <- createMSnset(exprsFile, metadata, indExpData,  colnameForID, 
#' indexForMetacell = c(43:48), pep_prot_data = "peptide", software = 'maxquant')
#' 
#' 
#' @export
#' 
#' @importFrom MSnbase MSnSet
#' @importFrom utils read.table
#' 
createMSnset <- function(file,
                         metadata=NULL,
                         indExpData,
                         colnameForID=NULL,
                         indexForMetacell = NULL,
                         logData=FALSE, 
                         replaceZeros=FALSE,
                         pep_prot_data=NULL,
                         proteinId = NULL,
                         software = NULL){
  
  if (!is.data.frame(file)){ #the variable is a path to a text file
    data <- read.table(file, header=TRUE, sep="\t",stringsAsFactors = FALSE)
  } else {data <- file}
  
  ##building exprs Data of MSnSet file
  Intensity <- matrix(as.numeric(gsub(",", ".",as.matrix(data[,indExpData] )))
                      , ncol=length(indExpData)
                      , byrow=FALSE)
  
  colnames(Intensity) <- gsub(".", "_", colnames(data)[indExpData], fixed=TRUE)
  rownames(Intensity) <- rownames(data)
 
  
  # Get teh metacell info
  metacell <- NULL
  if (!is.null(indexForMetacell)){
    metacell <- data[, indexForMetacell]
    metacell <- apply(metacell,2,tolower)
    metacell <- as.data.frame(apply(metacell,2, function(x) gsub(" ", '', x)),
                              stringsAsFactors = FALSE)
  }
  #browser()
  
  ##building fData of MSnSet file
  if(is.null(colnameForID))
    colnameForID <- 'AutoID'
  
  if (colnameForID == 'AutoID') {
    fd <- data.frame( data, 
                      AutoID = rep(paste(pep_prot_data, "_", 1:nrow(data), sep="")) , 
                      stringsAsFactors = FALSE)
    rownames(fd) <- paste(pep_prot_data, "_", 1:nrow(fd), sep="")
    rownames(Intensity) <- paste(pep_prot_data, "_",  1:nrow(Intensity), sep="")
                               
  }else{
    fd <- data
    rownames(fd) <- data[ ,colnameForID]
    rownames(Intensity) <- data[ ,colnameForID]
  }
  
  colnames(fd) <- gsub(".", "_", colnames(fd), fixed=TRUE)
  
  pd <- as.data.frame(metadata, stringsAsFactors = FALSE)
  rownames(pd) <- gsub(".", "_", pd$Sample.name, fixed=TRUE)
  pd$Sample.name <- gsub(".", "_", pd$Sample.name, fixed=TRUE)
  
  ##Integrity tests
  if(identical(rownames(Intensity), rownames(fd))==FALSE)
    stop("Problem consistency between
             row names expression data and featureData")
  
  if(identical(colnames(Intensity), rownames(pd))==FALSE) 
    stop("Problem consistency between column names 
             in expression data and row names in phenoData")
  
  obj <- MSnSet(exprs = Intensity, fData = fd, pData = pd)
  
  
  
  if (replaceZeros) {
    Biobase::exprs(obj)[Biobase::exprs(obj) == 0] <- NA
    Biobase::exprs(obj)[is.nan(Biobase::exprs(obj))] <- NA
    Biobase::exprs(obj)[is.infinite(Biobase::exprs(obj))] <-NA
    obj@processingData@processing <- c(obj@processingData@processing, "All zeros were replaced by NA")
  }
  if (logData) {
    Biobase::exprs(obj) <- log2(Biobase::exprs(obj))
    obj@processingData@processing <- 
      c(obj@processingData@processing, "Data has been Log2 tranformed")
  }
  
  if (!is.null(pep_prot_data)) {
    obj@experimentData@other$typeOfData <- pep_prot_data
  }
  
  obj@experimentData@other$Prostar_Version <- NA
  tryCatch({
    find.package("Prostar")
    obj@experimentData@other$Prostar_Version <- Biobase::package.version('Prostar')
  },
  error = function(e) obj.prot@experimentData@other$Prostar_Version <- NA
  )
  
  obj@experimentData@other$DAPAR_Version <- NA
  tryCatch({
    find.package("DAPAR")
    obj@experimentData@other$Prostar_Version <- Biobase::package.version('DAPAR')
  },
  error = function(e) obj@experimentData@other$DAPAR_Version <- NA
  )
  
  obj@experimentData@other$proteinId <- proteinId
  obj@experimentData@other$keyId <- colnameForID
  
    obj@experimentData@other$RawPValues <- FALSE
  
 
  metacell <- BuildMetaCell(from = software,
                            level = pep_prot_data,
                            qdata = Biobase::exprs(obj), 
                            conds = Biobase::pData(obj)$Condition, 
                            df = metacell)
  
  Biobase::fData(obj) <- cbind(Biobase::fData(obj), 
                               metacell, 
                               deparse.level = 0)
  obj@experimentData@other$names_metacell <- colnames(metacell)
  
  
  return(obj)
}


#' This function exports a \code{MSnSet} data object to a Excel file.
#' Each of the three data.frames in the \code{MSnSet} object (ie experimental 
#' data, phenoData and metaData are respectively integrated into separate sheets 
#' in the Excel file).
#' The colored cells in the experimental data correspond to the original 
#' missing values which have been imputed.
#' 
#' @title This function exports a \code{MSnSet} object to a Excel file.
#' 
#' @param obj An object of class \code{MSnSet}.
#' 
#' @param filename A character string for the name of the Excel file.
#' 
#' @return A Excel file (.xlsx)
#' 
#' @author Samuel Wieczorek
#' 
#' @examples
#' \donttest{
#' Sys.setenv("R_ZIPCMD"= Sys.which("zip"))
#' utils::data(Exp1_R25_pept, package='DAPARdata')
#' obj <- Exp1_R25_pept[1:100]
#' writeMSnsetToExcel(obj, "foo")
#' }
#' 
#' @export
#' 
#' @import openxlsx
#' 
writeMSnsetToExcel <- function(obj, filename)
{
  #require(Matrix)
  POV_Style <- openxlsx::createStyle(fgFill = "lightblue")
  MEC_Style <- openxlsx::createStyle(fgFill = "orange")
  recovered_Style <- openxlsx::createStyle(fgFill = "lightgrey")
  identified_Style <- openxlsx::createStyle(fgFill = 'white')
  combined_Style <- openxlsx::createStyle(fgFill = 'red')
  
  #require(openxlsx)
  name <- paste(filename, ".xlsx", sep="")
  wb <- openxlsx::createWorkbook(name)
  n <- 1
  openxlsx::addWorksheet(wb, "Quantitative Data")
  openxlsx::writeData(wb, sheet=n, cbind(ID = rownames(Biobase::exprs(obj)),
                                         Biobase::exprs(obj)), rowNames = FALSE)
  
  
  
    mat <- Biobase::fData(obj)[ ,obj@experimentData@other$names_metacell]
    level <- obj@experimentData@other$typeOfData
    listPOV <- which(match.metacell(mat, 'missing POV', level), arr.ind=TRUE)
    listMEC <- which(match.metacell(mat, 'missing MEC', level), arr.ind=TRUE)
    listIdentified <- which(match.metacell(mat, 'identified', level), arr.ind=TRUE)
    listRecovered <- which(match.metacell(mat, 'recovered', level), arr.ind=TRUE)
    if (level == 'protein')
      listCombined <- which(match.metacell(mat, 'combined', level), arr.ind=TRUE)
  
  
  openxlsx::addStyle(wb, sheet=n, cols = listPOV[,"col"]+1, rows = listPOV[,"row"]+1, style = POV_Style)
  openxlsx::addStyle(wb, sheet=n, cols = listMEC[,"col"]+1, rows = listMEC[,"row"]+1, style = MEC_Style)
  openxlsx::addStyle(wb, sheet=n, cols = listIdentified[,"col"]+1, rows = listIdentified[,"row"]+1, style = identified_Style)
  openxlsx::addStyle(wb, sheet=n, cols = listRecovered[,"col"]+1, rows = listRecovered[,"row"]+1, style = recovered_Style)
  
  if (level == 'protein')
    openxlsx::addStyle(wb, sheet=n, cols = listCombined[,"col"]+1, rows = listCombined[,"row"]+1, style = combined_Style)
  
  
  #bodyStyleNumber <- createStyle(numFmt = "NUMBER")
  #addStyle(wb, sheet=1, bodyStyleNumber, rows = 2:nrow(Biobase::exprs(obj)), 
  #cols=2:ncol(Biobase::exprs(obj)),gridExpand = TRUE)
  
  openxlsx::addWorksheet(wb, "Samples Meta Data")
  n <- n +1
  openxlsx::writeData(wb, sheet=n, Biobase::pData(obj), rowNames = FALSE)
  n <- n +1
  if (dim(Biobase::fData(obj))[2] != 0){
    openxlsx::addWorksheet(wb, "Feature Meta Data")
    #numericCols <- which(sapply(Biobase::fData(obj), is.numeric))
    #Biobase::fData(obj)[,numericCols] <- 
    #format(Biobase::fData(obj)[,numericCols])
    
    openxlsx::writeData(wb, sheet=n, cbind(ID = rownames(Biobase::fData(obj)),
                                           Biobase::fData(obj)), rowNames = FALSE)
    #bodyStyleNumber <- createStyle(numFmt = "NUMBER")
    #addStyle(wb, sheet=3, bodyStyleNumber, 
    #rows = 2:nrow(Biobase::exprs(obj)), cols=numericCols, 
    #gridExpand = TRUE, stack=TRUE)
    
  }
  
  if (!is.null(obj@experimentData@other$GGO_analysis))
  {
    l <- length(obj@experimentData@other$GGO_analysis$ggo_res)
    for (i in 1:l){
      n <- n +1
      level <- as.numeric(obj@experimentData@other$GGO_analysis$levels[i])
      openxlsx::addWorksheet(wb, paste("Group GO - level ", level, sep=""))
      openxlsx::writeData(wb, sheet=n, obj@experimentData@other$GGO_analysis$ggo_res[[i]]$ggo_res@result)
    }
  }
  
  if (!is.null(obj@experimentData@other$EGO_analysis))
  {
    n <- n +1
    openxlsx::addWorksheet(wb, "Enrichment GO")
    openxlsx::writeData(wb, sheet=n, obj@experimentData@other$EGO_analysis$ego_res@result)
    
  }
  
  openxlsx::saveWorkbook(wb, name, overwrite=TRUE)
  return(name)
  
  
}


#' @title This function reads a sheet of an Excel file and put the data 
#' into a data.frame.
#' 
#' @param file The name of the Excel file.
#' 
#' @param extension The extension of the file
#' 
#' @param sheet The name of the sheet
#' 
#' @return A data.frame
#' 
#' @author Samuel Wieczorek
#' 
#' @export
#' 
#' @importFrom readxl read_excel
#' 
readExcel <- function(file, extension, sheet){
  # data <- NULL
  # if (extension=="xls") {
  #     data <- readxl::read_xls(file, sheet)
  # }
  # else if (extension=="xlsx") {
  #     data <- readxl::read_xlsx(file, sheet)
  # }
  # return(as.data.frame(data,asIs=T))
  
  #options(digits=10)
  data <- NULL
  data <- readxl::read_excel(file, sheet)
  
  return(as.data.frame(data,asIs=T, stringsAsFactors=F))
  
}


#' This function lists all the sheets of an Excel file.
#' 
#' @title This function returns the list of the sheets names in a Excel file.
#' 
#' @param file The name of the Excel file.
#' 
#' @return A vector
#' 
#' @author Samuel Wieczorek
#' 
#' @export
#' 
#' @importFrom openxlsx getSheetNames
#' 
listSheets <- function(file){
  #require(openxlsx)
  return(openxlsx::getSheetNames(file))
  
}


#' @title Exports a MSnset dataset into a zip archive containing three 
#' zipped CSV files.
#' 
#' @param obj An object of class \code{MSnSet}.
#' 
#' @param fname The name of the archive file.
#' 
#' @return A compressed file
#' 
#' @author Samuel Wieczorek
#' 
#' @examples
#' \donttest{
#' utils::data(Exp1_R25_pept, package='DAPARdata')
#' obj <- Exp1_R2_pept[1:1000]
#' writeMSnsetToCSV(obj, "foo")
#' }
#' 
#' @export
#' 
#' @importFrom Biobase exprs fData pData
#' @importFrom utils write.csv zip
#'
writeMSnsetToCSV <- function(obj, fname){
  
  #fname <- paste(tempdir(),fname,  sep="/")
  write.csv(Biobase::exprs(obj), paste(tempdir(), "exprs.csv", sep='/'))
  write.csv(Biobase::fData(obj), paste(tempdir(), "fData.csv", sep='/'))
  write.csv(Biobase::pData(obj), paste(tempdir(), "pData.csv", sep='/'))
  files <- c(paste(tempdir(), "exprs.csv", sep='/'),
             paste(tempdir(), "fData.csv", sep='/'),
             paste(tempdir(), "pData.csv", sep='/'))
  zip(fname, files, zip = Sys.getenv("R_ZIPCMD", "zip"))
  
  return(fname)
}



#' @title Similar to the function \code{rbind} but applies on two subsets of 
#' the same \code{MSnSet} object.
#' 
#' @param df1 An object (or subset of) of class \code{MSnSet}. May be NULL
#' 
#' @param df2 A subset of the same object as df1
#' 
#' @return An instance of class \code{MSnSet}.
#' 
#' @author Samuel Wieczorek
#' 
#' @examples
#' utils::data(Exp1_R25_pept, package='DAPARdata')
#' df1 <- Exp1_R25_pept[1:100]
#' df2 <- Exp1_R25_pept[200:250]
#' rbindMSnset(df1, df2)
#' 
#' @export
#' 
#' @importFrom MSnbase MSnSet
#' @importFrom Biobase pData fData exprs
#' 
rbindMSnset <- function(df1=NULL, df2){
  
  if (is.null(df1)){
    obj <- df2
    return(obj)
  }
  if (is.null(df1) && is.null(df2)){return(NULL)}
  
  tmp.exprs <- rbind(Biobase::exprs(df1), Biobase::exprs(df2))
  tmp.fData <- rbind(Biobase::fData(df1), Biobase::fData(df2))
  tmp.pData <- Biobase::pData(df1)
  
  obj <-  MSnSet(exprs = tmp.exprs, fData = tmp.fData, pData = tmp.pData)
  obj@protocolData <- df1@protocolData
  obj@experimentData <- df1@experimentData
  
  return(obj)
  
}
