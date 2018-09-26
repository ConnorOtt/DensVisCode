function [x, y] = robProj(lat, long, xMax, yMax)
% Reading in projection file. 
fID = fopen('robProj.txt', 'r');
robProj = fscanf(fID,'%f %f %f' ,[3 inf]);
fclose(fID);
robProj(2, :) = robProj(2, :)*xMax;
robProj(3, :) = robProj(3, :)*yMax;
PDFEconst = 0.5072; 

% Creating a parabolic fit for the latitude length values. 
fitObj = fit(robProj(1, :)', robProj(2, :)', 'poly2');
latLen = fitObj(lat);

end