function [DATAVAR,DATEVAR] = GetBuildingData(FILENAME)
% B. Frank, 2010/10/14
% Script to import data from ILC LiveBuilding site
%
% Input is:
% Filename: a CSV file following the format output from 
% http://livebuilding.queensu.ca/access_data
% To create the file, copy the data generated at the webpage into a text
% file (using a text editor like Windows Notepad, Emacs, etc.), and save it
% in a file in the MATLAB path.
%
% Outputs are:
% DATAVAR is a vector of data (voltage, current, radiation, etc.) from the
% input file FILENAME
% DATEVAR is a vector of MATLAB serial date numbers that can be used to 
% compute and plot dates and times. It is translated from the date and time
% inputted in columns in the input file FILENAME.

DELIMITER = ' '; % Use a space to separate columns in inputted data file
HEADERLINES = 6; % Define number of lines of header at the top of the file

% Set the filename here - can use a comment sign to allow you to quickly
% switch between files
%FILENAME='PV.Current_daily_maximum_year.csv'
%FILENAME='PV.Current_weekly_maximum_year.csv'
%FILENAME='PV.Current_halfhr_maximum_week.csv'

%Import the data file
DataCell = importdata(FILENAME,DELIMITER,HEADERLINES); 

% This section allows string data to be turned into date fields that are
% useful for plotting
% Create new variables in the base workspace from those fields.
vars = fieldnames(DataCell);
for i = 1:length(vars)
    assignin('base', vars{i}, DataCell.(vars{i}));
end

DATAVAR=DataCell.data; % Create a variable to hold the numeric data from the file
[a b]=size(DataCell.textdata); % calculate the size of the input text data from the
                      % file, to be used in the next line
DateString = DataCell.textdata(HEADERLINES+1:a,1); % Create a variable to hold
                                              % date strings
% Create a variable to hold time strings. Use strrep to delete commas in
% the string, which is left over from importing the CSV file.
TimeString = strrep(DataCell.textdata(HEADERLINES+1:a,2),',',''); 

%Convert date strings to a format MATLAB can work with. To do this we need
%to concatenate the date and time strings, and insert a space between the
%date and time. This requires a vector of spaces the same length as the
%date and time vectors. The variable "blank" below is created to do this.

for i=1:length(TimeString)
  blankcolumn(i,:)=' , ';
end

BlankCell=cellstr(blankcolumn);

DATEVAR = datenum(strcat(DateString,BlankCell,TimeString));

end