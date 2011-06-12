function MB = print_mbytes( A_ )
% display the # of megabytes in shell of a variable
% also return the number of MB 
  A = A_;
  res         = whos('A');
  A_MegaBytes = res.bytes / 1024 / 1000;
  disp([ num2str(A_MegaBytes ) 'MB ']);
  MB = A_MegaBytes;
end
