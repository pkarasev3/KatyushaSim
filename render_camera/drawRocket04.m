function [ rocket ] = drawRocket02( rocket )
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
   Npts = rocket.Npts;
   ptype= rocket.ptype;
   f_in = rocket.f_in;
   gObj = rocket.gObj;
   
   imgH = NxAA * imgH;
   imgW = NxAA * imgW;
      
   % step 1, create the plane face
   facerange  = linspace(-1,1,Npts);
   [x y] = meshgrid(facerange, 1.5*facerange);
   x = .1*x;
   y =.1*y;
    onez  = 0.1 * ones(1,Npts^2);
   face1 = [  x(:)';     y(:)';     -onez*1.0;          ones(1,Npts^2) ];
   face2 = [ -x(:)';     y(:)';      onez*1.0;          ones(1,Npts^2) ];
   face3 = [ -onez;      y(:)';         1.0*x(:)';      ones(1,Npts^2) ];    
   face4 = [  onez;      y(:)';         1.0*x(:)';      ones(1,Npts^2) ];    
   face5 = [  y(:)';  -onez*1.5;      -1.0*x(:)';    ones(1,Npts^2) ];    
   face6 = [  y(:)';   onez*1.5;      -1.0*x(:)';    ones(1,Npts^2) ];    
      
   faces0 = [face1 face2 face3 face4 face5 face6];
   faces0 = faces0 .* (1 + 0.00*randn(size(faces0)));
   rface = sqrt( 5*faces0(1,:).^2+5*faces0(3,:).^2 + 0.05);
   faces0(2,:) = faces0(2,:) * 7.0; 
   faces0(1,:) = faces0(1,:) ./ rface;
   faces0(3,:) = faces0(3,:) ./ rface;
      
   % step 2. apply object's rigid transformation and projection
   rocket.faces = gObj * faces0;
   
   
   % step 3. Camera Transform
   gfaces   = gSE3 * rocket.faces;
      
   
   f = f_in * NxAA; % Must scale f if rendering larger size!
   z_ = 0.00;       % prevent extremely rapid 1/z effect 
   if( strcmp(ptype,'perspective' ) )
        u = imgW/2 + f * gfaces(1,:) ./ (z_ + gfaces(3,:) );
        v = imgH/2 + f * gfaces(2,:) ./ (z_ + gfaces(3,:) );
   else
        s = mean( gfaces(3,:) );
        u = imgW/2 + f * gfaces(1,:) / s;
        v = imgH/2 + f * gfaces(2,:) / s;
   end
   
      % step 3. set color values for original points
            
		  Msz = repmat( numel(facerange),1,2);
      Mlen = Msz(1)*Msz(2);
      
      % step 4. reload textures if we havent or the image size changed
      loadTextures = false; 
      if(  isfield( rocket, 'textures' ) )
        prevSz  = size( rocket.textures{1} );
        if( sum( abs(prevSz(1:2) - Msz ) ) > 0 ) 
            loadTextures = true;
        end
      else
        loadTextures = true;
      end 
      
      if(  loadTextures )
         fprintf('...loading textures ...\n ' );
        body_img     = imread_float('flare.jpg');
        body_img(:)  = (histeq(body_img(:))).^2-0.2;
        tex_back  = imresize( double( body_img )  , Msz,'bilinear'); 
        tex_front = imresize( double( body_img ) , Msz,'bilinear'); 
        tex_side  = imresize( double( body_img )  , Msz,'bilinear'); 
        tex_top   = imresize( double( body_img )   , Msz,'bilinear');       
        rocket.textures  = {tex_back, tex_front, tex_top, tex_top, tex_side, tex_side};
      
      
        colorsR  = zeros( numel(rocket.textures), Mlen )';
        colorsG  = zeros( numel(rocket.textures), Mlen )';
        colorsB  = zeros( numel(rocket.textures), Mlen )';
        Ntex     = numel(rocket.textures);
        parfor k = 1:Ntex
          colorsR(:,k) = reshape( rocket.textures{k}(:,:,1) , Mlen,1);
          colorsG(:,k) = reshape( rocket.textures{k}(:,:,2) , Mlen,1);
          colorsB(:,k) = reshape( rocket.textures{k}(:,:,3) , Mlen,1);
        end
        rocket.colors   = { colorsR(:)', colorsG(:)', colorsB(:)' };
        rocket.img      = imresize( zeros(imgH,imgW,3), 1/NxAA, 'bilinear' );
        rocket.plume    = zeros(imgH,imgW,3);
      end
     % step 4. sort by depth so we can draw in back-to-front order
     [zvals zorder] = sort( gfaces(3,:),'descend');
     
     % step 5. make a plume     
     plen       = 20; % plume length
     plume_span = 0.5 + plen ./ ( 1 + plen * logspace(-1.5,0,rocket.Npts^2) );
     pfile      = sqrt( .5 * exp( -(plume_span - 1*plen/2).^2 / (plen) ) );
     plume_xyz0 = gObj * [ (randn(1,Npts^2)).*(pfile); ... 
                      plume_span; (randn(1,Npts^2)).*(pfile); 1+0*plume_span ];
     plume_xyz  = gSE3 * plume_xyz0;
     pu         = imgW/2 + f * plume_xyz(1,:) ./ (z_ + plume_xyz(3,:) );
     pv         = imgH/2 + f * plume_xyz(2,:) ./ (z_ + plume_xyz(3,:) );
     [pzvals pzorder] = sort( plume_xyz(3,:),'descend');
     plumeRGB   = {[],[],[]};
     plumeRGB{1}= ((plume_span - plen/2).^2) / plen * 110;
     plumeRGB{2}= sqrt((plume_span - 3*plen/4).^2)  * 70;
     plumeRGB{3}= sqrt((plume_span - 2*plen/3).^2)  * 90;
     for k = 1:3
       plumeRGB{k} = plumeRGB{k} / 1500.0;
       plumeRGB{k}(plume_xyz0(2,:) > 0 ) = 0;
     end
     
     bPlotDebug = false;
     if( bPlotDebug )
       plot3d_debug_plume( );
     end
     
     % step 6. Bag and Tag it for later rasterizing in batch
     rocket.R     = [plumeRGB{1}(pzorder)';  rocket.colors{1}(zorder)'];
     rocket.G     = [plumeRGB{2}(pzorder)';  rocket.colors{2}(zorder)'];
     rocket.B     = [plumeRGB{3}(pzorder)';  rocket.colors{3}(zorder)'];
     
     plume_a      = 0.1 * ones(numel(pzorder),1);
    
     rocket.A     = [ plume_a ; 0.5 * ones(numel(zorder),1) ];
     
     plume_ker          = 0 * ones(numel(pzorder),1);
     
     body_ker = 0 * ones(numel(zorder),1);
     body_ker(1:100:end) = 1;
     rocket.kerSz = [ plume_ker   ; body_ker ];
     rocket.zvals = [ pzvals(pzorder)' ; zvals(zorder)' ];
     rocket.u     = [ pu(pzorder)' ;  u(zorder)' ];
     rocket.v     = [ pv(pzorder)' ;  v(zorder)' ];
     rocket.gam   = [ 0.0 * ones(numel(pzorder),1) ; 0.0 * ones(numel(zorder),1) ];
     
     fprintf('');

     return;
     
    function plot3d_debug_plume( )
      sfigure(3); title('plume-3d rocket02');
      plot3( gfaces(1,:), gfaces(2,:), gfaces(3,:),'r.')
      hold on;
      plot3( plume_xyz(1,:), plume_xyz(2,:), plume_xyz(3,:),'b.'); hold off;
    end

end
