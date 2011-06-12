function datenow = getCurrentTime()
%get time string in the format YYYY-MM-DD_hh-mm-ss

datenow = datestr(now,31);
datenow = strrep(datenow,':','-');
datenow = strrep(datenow,' ','_');