% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/agregation.R
\name{aggregateSum}
\alias{aggregateSum}
\title{Compute the intensity of proteins with the sum of the intensities
of their peptides.}
\usage{
aggregateSum(obj.pep, X)
}
\arguments{
\item{obj.pep}{A matrix of intensities of peptides}

\item{X}{An adjacency matrix in which lines and columns correspond 
respectively to peptides and proteins.}
}
\value{
A matrix of intensities of proteins
}
\description{
This function computes the intensity of proteins based on the sum of the 
intensities of their peptides.
}
\examples{
utils::data(Exp1_R25_pept, package='DAPARdata')
protID <- "Protein_group_IDs"
obj.pep <- Exp1_R25_pept[1:10]
X <- BuildAdjacencyMatrix(obj.pep, protID, FALSE)
ll.agg <- DAPAR::aggregateSum(obj.pep, X)

}
\author{
Alexia Dorffer
}
