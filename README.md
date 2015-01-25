# GetClean

The first time the R script named run_analysis.R is run, it creates a data folder in the current working directory and downloads the zip file from the website, as detailed in the code book.  

On subsequent occasions, run_analysis.R expects to find the zip file in the data folder.  

Running the script extracts the data from the zip file, and creates two files in the data folder, called HAR.txt and HAR_mean.txt, the details of which are given in the code book.  
