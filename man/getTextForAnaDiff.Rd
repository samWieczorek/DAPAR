% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/logText.R
\name{getTextForAnaDiff}
\alias{getTextForAnaDiff}
\title{Build the text information for the Aggregation process}
\usage{
getTextForAnaDiff(l.params)
}
\arguments{
\item{l.params}{A list of parameters related to the process of the dataset}
}
\value{
A string
}
\description{
Build the text information for the differential Analysis process
}
\examples{
getTextForAnaDiff(list(design="OnevsOne",method="Limma"))

}
\author{
Samuel Wieczorek
}
