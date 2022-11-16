import os, sys
sys.path

# define our data references
input_table = 'SASHELP.CLASS'
output_table = 'WORK.PYTHONOUT'

# set input data to pipe from SAS
dfin = SAS.sd2df(input_table)

# output to the log details about the table
print("input data shape is:", dfin.shape)

# call the python transpose
dfout = dfin.transpose()

# output to the log details about the table
print("output data shape is:", dfout.shape)

# set output data using call to pipe to SAS
SAS.df2sd(dfout, output_table)

SAS.submit('proc print data=work.pythonout;');
