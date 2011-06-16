function [ rocket ] = drawStars3D( rocket )
  % generate point cloud and color mapping
  dbstop if error
    if( nargin < 1 )
     rocket      = [];
     rocket.NxAA = 2;
     rocket.imgH = 256;
     rocket.imgW = 256;
     rocket.gSE3 = GetCameraSE3MatrixOGL( [5 5 5],[0,0,0] );
     rocket.Npts = 120;
     rocket.ptype= 'perspective';
     rocket.f_in = 320;
     rocket.gObj = eye(4,4);
   end

   NxAA = rocket.NxAA;
   imgH = rocket.imgH;
   imgW = rocket.imgW;
   gSE3 = rocket.gSE3;
   ptype= rocket.ptype;
   f_in = rocket.f_in;
   gObj = rocket.gObj;
   imgH = NxAA * imgH;
   imgW = NxAA * imgW;
   Npts = rocket.Npts;
   
   Npts_ = round(sqrt(Npts));
   

   if( ~isfield(rocket,'starsx') )
     spc   = linspace(-pi,pi,Npts_);
     [sthe sphi] = meshgrid( spc, spc);
     srad  = 500 + 100*randn(size(sthe));
     [starsx starsy starsz] = sph2cart(sthe,sphi,srad); %#ok<NASGU>
    
     starsx = repmat(starsx(:),Npts_,1);
     starsx = ( 2000 * rand( numel(starsx(:)), 1) - 1000 );
     starsy = repmat(starsy(:),Npts_,1);
     starsy = -0.05 - abs( ( 2000 * rand( numel(starsy(:)), 1) ) );
     starsz = ( 2000 * rand( numel(starsx(:)), 1) - 1000 );
     
     stardist = sqrt( starsz.^2 + starsy.^2 + starsx.^2 );
     starsy   = starsy - 100 ./ (5 + stardist );
   
     moon_pos  = [ randn(4,500) * 30 , randn(4,500) * 10 ];
     moon_pos(1,1:end/2) = moon_pos(1,1:end/2) + 50;
     moon_pos(2,1:end/2) = moon_pos(2,1:end/2) - 2000;
     moon_pos(3,1:end/2) = moon_pos(3,1:end/2) + 100;
     moon_pos(1,1+end/2:end) = moon_pos(1,1+end/2:end) + 300;
     moon_pos(2,1+end/2:end) = moon_pos(2,1+end/2:end) - 1900;
     moon_pos(3,1+end/2:end) = moon_pos(3,1+end/2:end) - 100;
     moon_pos(4,:) = moon_pos(3,:)*0 + 1;
     
     rocket.starsx = [starsx ; moon_pos(1,:)' ];
     rocket.starsy = [starsy ; moon_pos(2,:)' ];
     rocket.starsz = [starsz ; moon_pos(3,:)' ];
     rocket.moon_pos = moon_pos;
     
   end
   starsx = rocket.starsx;
   starsy = rocket.starsy;
   starsz = rocket.starsz;

   % stars is stationary
   faces0 = [starsx(:)' ; starsy(:)' ; starsz(:)' ; 1+0*starsz(:)' ];
   faces0 = [faces0];
      
   % step 2. apply object's rigid transformation and projection
   rocket.faces = gObj * faces0;
   
   
   % step 3. Camera Transform
   gfaces   = gSE3 * rocket.faces;
      
   
   f = f_in * NxAA; % Must scale f if rendering larger size!
   z_ = 0.00;
   if( strcmp(ptype,'perspective' ) )
        u = imgW/2 + f * gfaces(1,:) ./ (z_ + gfaces(3,:) );
        v = imgH/2 + f * gfaces(2,:) ./ (z_ + gfaces(3,:) );
   else
        s = mean( gfaces(3,:) );
        u = imgW/2 + f * gfaces(1,:) / s;
        v = imgH/2 + f * gfaces(2,:) / s;
   end
   
    stars_r = (0.3 + 0.1 * rand(numel(starsx(:)),1)) * 50 + randn(1,1)*2;
    stars_g = (0.3 + 0.1 * rand(numel(starsy(:)),1)) * 50 + randn(1,1)*2;
    stars_b = (0.3 + 0.1 * rand(numel(starsz(:)),1)) * 50 + randn(1,1)*2;

    rocket.colors{1}  = repmat([  stars_r(:)' ],1,1);
    rocket.colors{2}  = repmat([  stars_g(:)' ],1,1);
    rocket.colors{3}  = repmat([  stars_b(:)' ],1,1);
    
    % step 4. sort by depth so we can draw in back-to-front order
    [zvals zorder] = sort( gfaces(3,:),'descend');

    map_of_origin = inv(rocket.gSE3) * [0;0;0;1];           %#ok<NASGU,MINV>
    
    % Cull the garbage that is behind the camera:
    idx_bad1 = find( zvals < 1e-4 );
    
    % Cull the garbage that is out of bounds
    idx_bad2 = find( 0 < (u(zorder) < 0) + (u(zorder) > imgW) + (v(zorder) < 0) + (v(zorder) > imgH) );
    
    zorder = zorder( setdiff( 1:numel(zorder) , union( idx_bad1, idx_bad2 ) ) );
     
     % step 6. Bag and Tag it for later rasterizing in batch
     rocket.R     = [rocket.colors{1}(zorder)'];
     rocket.G     = [rocket.colors{2}(zorder)'];
     rocket.B     = [rocket.colors{3}(zorder)'];
     rocket.A     = [ 0.25 * ones(numel(zorder),1) ];
     rocket.kerSz = [ 0 * ones(numel(zorder),1)  ];
     rocket.kerSz(1:3:end) = 1;
     rocket.kerSz(1:10:end) = 2;
     rocket.kerSz(1:50:end) = 3;
     rocket.zvals = [ zvals(zorder) ];
     rocket.u     = [ u(zorder) ];
     rocket.v     = [ v(zorder) ];
     rocket.gam   = [ 0.0 * ones(numel(zorder),1) ];
     
     fprintf('');

     return;
    

end
