function  [vrcl] =  drawMultiObject( vrcl, varargin )
% input: 
%          vrcl.RGBvals,  an  M x 3 cell array of N RGB points
%          vrcl.img ,     handle on the image we're writing to
%          vrcl.zvals
%          vrcl.u, vrcl.v        projected image points, Mx1 cell array of 2xN arrays
%
%  output: vrcl.img is updated after rasterizing 

Nobjs  = numel( varargin );
Npts   = 0;
idx    = []; % store the start and end indices of each object in master list
if ( Nobjs < 1 ) 
  disp( 'invalid input, must have at least one draw object!' );
  return;
else
  for k = 1:Nobjs
    idx  = [idx,Npts+1];                                         %#ok<AGROW>
    Npts = Npts + numel( varargin{k}.u );
    idx  = [idx, Npts];                                          %#ok<AGROW>
  end
  fprintf('preparing to rasterize %d objects, %d points...\n', Nobjs, Npts );
end
  
% Stack up all the gfaces and sort back to front
colors =        zeros(Npts,6); % [r,g,b,alpha,kerSz,gam] 
zvals  =        zeros(Npts,1);
u      =        zeros(Npts,1);
v      =        zeros(Npts,1);

for  k = 1:Nobjs
    
    idx1=idx( 2*k-1 );
    idx2=idx( 2*k   );
    
    zvals(idx1:idx2) = varargin{k}.zvals;
    u(idx1:idx2) = varargin{k}.u;
    v(idx1:idx2) = varargin{k}.v;
    colors(idx1:idx2,1) = varargin{k}.R;
    colors(idx1:idx2,2) = varargin{k}.G;
    colors(idx1:idx2,3) = varargin{k}.B;
    colors(idx1:idx2,4) = varargin{k}.A;
    colors(idx1:idx2,5) = varargin{k}.kerSz;
    colors(idx1:idx2,6) = varargin{k}.gam;
end

% stupid rasterpts_mex compatability: need to be row vectors!
    colors = colors'; 
    u      = u';
    v      = v';
%

[zvals zorder] = sort(zvals,'descend');
vrcl.zvals     = zvals;
NxAA           = vrcl.NxAA;

% Draw everything in one bang in proper depth order. 
if( isfield(vrcl,'rawimg') )
  img  = vrcl.rawimg;
else
  img    = imresize(vrcl.img, NxAA,'bilinear');
end
% 
parfor k = 1:3
   img(:,:,k) = rasterpts_mex( u(zorder), v( zorder ), ... 
                         colors(k,zorder), img(:,:,k), ... 
                         colors(4,zorder), colors(5,zorder),colors(6,zorder) );
   fprintf('');
end

vrcl.rawimg = img;
img(img<0)  = 0;
img(img>1)  = 1;
vrcl.img    = imresize(img, 1/NxAA,'bilinear');

fprintf('');



end  % end function
