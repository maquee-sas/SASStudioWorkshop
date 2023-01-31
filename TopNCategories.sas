/*************************************************/
/* Copyright 2008-2010 SAS Institute Inc.        */
/* Top N report for data across categories       */
/* Use macro variables to customize the data     */
/* source.                                       */
/* DATA - SAS library.member for input data      */
/* REPORT - column to report on                  */
/* MEASURE - column to measure for the report    */
/* MEASUREFORMAT - specify to preserve measure   */
/*  format in the report (currency, for example) */
/* STAT - SUM or MEAN                            */
/* N - The "N" in Top N - how many to show       */ 
/* CATEGORY - across which category?             */ 
/*************************************************/
%let data=SASHELP.CARS;
%let report=Model;
%let measure=MPG_City;
%let measureformat=%str(format=BEST6.);
%let stat=MEAN;
%let n=5;
%let category=Origin;
title "Top Models by MPG_City for each region of Origin";
footnote;

/* summarize the data across a category and store */
/* the output in an output data set */
proc means data=&data &stat noprint;
	var &measure;
	class &category &report;
	output out=summary &stat=&measure &category /levels;
run;

/* store the value of the measure for ALL rows and 
/* the row count into a macro variable for use  */
/* later in the report */
proc sql noprint;
select &measure,_FREQ_ into :overall,:numobs
from summary where _TYPE_=0;
select count(distinct &category) into :categorycount from summary;
quit;

/* sort the results so that we get the TOP values */
/* rising to the top of the data set */
proc sort data=work.summary out=work.topn;
  where _type_>2;
  by &category descending &measure;
run;

/* Pass through the data and output the first N */
/* values for each category */
data topn;
  length rank 8;
  label rank="Rank";
  set topn;
  by &category descending &measure;
  if first.&category then rank=0;
  rank+1;
  if rank le &n then output;
run;

/* Create a report listing for the top values in each category */
footnote2 "&stat of &measure for ALL values of &report: &overall (&numobs total rows)";
proc report data=topn;
	column &category rank &report &measure;
	define &category /group;
	define rank /display;
	define &measure / analysis &measureformat;	
run;
quit; 


/* Create a simple bar graph for the data to show the rankings */
/* and relative values */
/* Calculate size of chart based on number of category values */
goptions ypixels=%eval(250 * &categorycount) xpixels=500;
proc gchart data=topn
;
	hbar &report / 
		sumvar=&measure
		group=&category
		descending
		nozero
		clipref
		frame	
		discrete
		type=&stat
		patternid=group
;
run;
quit;

