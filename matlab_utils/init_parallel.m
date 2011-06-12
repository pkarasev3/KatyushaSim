function init_parallel( N )
% initialize parallel threads for matlab if:
% 
% a) the function exists (on some computers it doesn't)
% b) its not already running
% 

  if( nargin < 1 )
    N = 4;
  end

  if( exist('matlabpool','file') )
    if( matlabpool('size') < N )
       matlabpool('close','force');
       matlabpool('open','local',N)
    end
  end

end
