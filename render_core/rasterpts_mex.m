function img = rasterpts_mex(u,v,colors,img,alpha,stepsz,gam)
 

 if( nargin < 5 )
   alpha  = 0.7 + 0 * u;
 end
 if( nargin < 6 )
   stepsz = 1 + 0 * u; 
 end
 if( nargin < 7 )
   gam = 0.0 + 0 * u; 
 end

  %-- call the mex function (compiled and protected)
 img = rasterpts_c(u,v,colors,img,alpha,stepsz,gam);
  
  
  
%  code being replaced that is slow:
% 
%   for k = 1 : length(zorder) 
%       ii = round( v( zorder( k ) ) );
%       jj = round( u( zorder( k ) ) );
%       if( ii < 1 || ii > imgH || jj < 1 || jj > imgW )
%          continue; 
%       end
%       img(ii,jj) = img(ii,jj)*0.05+0.95*colors( zorder(k) );
%    end
