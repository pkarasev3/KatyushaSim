function [ rocket ] = drawPlane3D( rocket )
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
   floorz = rocket.floorz;
   fscale = rocket.fscale;
   imgH = NxAA * imgH;
   imgW = NxAA * imgW;
      
   if( isfield(rocket,'floor_img') )
    tex_floor = rocket.floor_img;
   else
    error('must have floor texture!');
   end
   
   floor_sz         = size(tex_floor);
   
   fl_h             = linspace( -1, 1, floor_sz(1) );
   fl_w             = floor_sz(2)/floor_sz(1) * linspace( -1, 1, floor_sz(2) );
   [floorx floory]  = meshgrid( fscale * fl_w, fscale * fl_h );
   
   floorz           = floorz + 0*floorx;

   
   % Floor is stationary
   floor_xyz1 = [-floorx(:)' ; -floorz(:)' ; floory(:)' ; 1+0*floorz(:)' ];
   floor_xyz2 = floor_xyz1 .* (1.0 + randn( size(floor_xyz1) )*5e-2 );
   floor_xyz3 = floor_xyz1 .* (1.0 + randn( size(floor_xyz1) )*5e-2 );
   
   faces0 = [floor_xyz1 , floor_xyz2, floor_xyz3 ];
   
      
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
   
    floor_r  = tex_floor(:,:,1);
    floor_g  = tex_floor(:,:,2);
    floor_b  = tex_floor(:,:,3);

    rocket.colors{1}  = repmat([  floor_r(:)' ],1,3);
    rocket.colors{2}  = repmat([  floor_g(:)' ],1,3);
    rocket.colors{3}  = repmat([  floor_b(:)' ],1,3);
    
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
     rocket.A     = [ 0.5 * ones(numel(zorder),1) ];
     rocket.kerSz = [ 0 * ones(numel(zorder),1)  ];
     rocket.zvals = [ zvals(zorder) ];
     rocket.u     = [ u(zorder) ];
     rocket.v     = [ v(zorder) ];
     rocket.gam   = [ 0.01 * ones(numel(zorder),1) ];
     
     fprintf('');

     return;
    

end
