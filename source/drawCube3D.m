function [img u_zord v_zord z_zord] = drawCube3D( imgH, imgW, gSE3, Npts,projection_type)
   %  inputs:
   %     Npts: number of points per face
   %     imgH: image height
   %     imgW: image width
   %     gSE3: rigid transform of the cube object
   % 
   %  outputs:
   %     img:   resulting image
   %     ximg:  xcoordinates of pre-image
   %     yimg:  ycoordinates of pre-image
   %     zimg:  zcoordinates of pre-image
   %     binary_mask:  1 for pixel generated by object, 0 for 
   %        background. denotes elements of other outputs that 
   %        came from the object(cube).
   
   dbstop if error
   
    NxAA = 3;
    Npts = Npts * NxAA^2 / 2;
   imgH = imgH * NxAA;
   imgW = imgW * NxAA;
  if( nargin < 2 )
       imgH = 180;
       imgW = 240;
   end
   if ( nargin < 3 )
       gSE3 = eye(4,4);
   end
   if( nargin < 4 )
       Npts = 5;
   end
   if( nargin < 5 )
       projection_type = 'ortho';
   end
  
     
   img         = zeros(imgH,imgW);
   ximg        = zeros(imgH,imgW);
   yimg        = zeros(imgH,imgW);
   zimg        = zeros(imgH,imgW);
   
   % step 1, create the 6 faces of cube
   facerange  = -1:2/Npts:1;
   [y z] = meshgrid(facerange, facerange);
   xF = (1);
   face1 = [ repmat( xF, 1, numel(y) ); 
             y(:)'; z(:)'; ones(1,numel(y)) ];
   xF = (-1);
   face2 = [ repmat( xF, 1, numel(y) ); 
             y(:)'; z(:)' ; ones(1,numel(y))];
   [x z] = meshgrid( facerange, facerange);
   yF = (1);
   face3 = [ x(:)'; repmat( yF, 1, numel(y) ); 
              z(:)' ; ones(1,numel(y))];
   yF = (-1);
   face4 = [ x(:)'; repmat( yF, 1, numel(y) ); 
              z(:)' ; ones(1,numel(y))];          
   zF = (1);
   [x y] = meshgrid( facerange, facerange);
   face5 = [ x(:)'; y(:)' ; 
             repmat( zF, 1, numel(y) );  ones(1,numel(z))];
   zF = (-1);
   face6 = [ x(:)'; y(:)' ; 
             repmat( zF, 1, numel(y) );  ones(1,numel(z))];
   faces0 = [face1 face2 face3 face4 face5 face6];   
   facesC = [face3 face6 face1 face5 face4 face2];
   facesB = [face4 face3 face1 face6 face2 face5];
   facesD = [face6 face5 face4 face3 face2 face1];
   %faces = [faces [ ( 0.5 + randn(3,size(faces,2))*0.00).*faces(1:3,:);faces(4,:)]]; % hypercube! 
   %faces0 
   %faces = [faces0,(facesB+repmat([0;2;-2;0],1,size(faces0,2))) , ... 
   %     (facesD+repmat([3;0;0;0],1,size(faces0,2))), (facesC+repmat([-3;0;0;0],1,size(faces0,2)))];
   faces = [faces0];
   NumAdd = size(faces,2)/size(faces0,2);
   
   
   % step 2. apply rigid transformation and projection
   gfaces = gSE3 * faces;
   f = imgW / 2;
    
   z_ = mean(abs(gfaces(3,:)))*0.0;
   gfaces(3,:) = gfaces(3,:)+z_;
   if( strcmp(projection_type,'perspective' ) )
        u = imgW/2 + f * gfaces(1,:) ./ (gfaces(3,:) ); % can't divide by zero if camera is in front of object
        v = imgH/2 + f * gfaces(2,:) ./ (gfaces(3,:) );
   else
        s = mean( gfaces(3,:) );
        u = imgW/2 + f * gfaces(1,:) / s;
        v = imgH/2 + f * gfaces(2,:) / s;
   end
   
   
   v = imgH - v; % flip in y-axis, y increases down on screen 
   x_coord = (faces(1,:));%-min(faces(1,:)))/(max(faces(1,:))-min(faces(1,:)));   
   y_coord = (faces(2,:));%-min(faces(2,:)))/(max(faces(2,:))-min(faces(2,:)));
   z_coord = (faces(3,:));%-min(faces(3,:)))/(max(faces(3,:))-min(faces(3,:)));
   
      % step 3. set color values for original points
	  
   	  
   
   color_method = 1;
   if( 0 == color_method )
       cvals = (1:numel(x)); cvals = 0.15+0.85*cvals / max(cvals(:));
       colors = [cvals (cvals+3) (cvals+1) (cvals+4) , ...
                         (cvals+2) (cvals+5)];
       colors = colors / max(colors(:));
   elseif( 1==color_method )
        colorsR = 1./((x_coord-0.5).^2+1e-1);
        colorsG = 1./((sin(y_coord) ).^2+1e-1);
        colorsB = x_coord+y_coord+z_coord;
   elseif( 2 == color_method ) % use texture images that have features!
		Msz = repmat( numel(facerange),1,2); Mlen = Msz(1)*Msz(2);
	    texture1 = reshape( imresize( double((imread('texture1.png'))),Msz), 1,3*Mlen); texture1 = texture1-min(texture1(:));
	    texture2 = reshape(imresize( double((imread('texture2.png'))),Msz), 1,3*Mlen);  texture2 = texture2-min(texture2(:));
	    texture3 = reshape(imresize( double((imread('texture5.png'))),Msz), 1,3*Mlen);  texture3 = texture3-min(texture3(:));
	    texture4 = reshape(imresize( double((imread('texture4.png'))),Msz), 1,3*Mlen);  texture4 = texture4-min(texture4(:));
	    texture5 = reshape(imresize( double((imread('texture3.png'))),Msz), 1,3*Mlen);  texture5 = texture5-min(texture5(:));
	    texture6 = reshape(imresize( double((imread('texture6.png'))),Msz), 1,3*Mlen);  texture6 = texture6-min(texture6(:));
		colorsR  = [ texture1(1:Mlen) texture2(1:Mlen) texture3(1:Mlen) texture4(1:Mlen) texture5(1:Mlen) texture6(1:Mlen) ];
        colorsG  = [ texture1(Mlen+1:2*Mlen) texture2(Mlen+1:2*Mlen) texture3(Mlen+1:2*Mlen) texture4(Mlen+1:2*Mlen) texture5(Mlen+1:2*Mlen) texture6(Mlen+1:2*Mlen) ];
        colorsB  = [ texture1(2*Mlen+1:3*Mlen) texture2(2*Mlen+1:3*Mlen) texture3(2*Mlen+1:3*Mlen) texture4(2*Mlen+1:3*Mlen) texture5(2*Mlen+1:3*Mlen) texture6(2*Mlen+1:3*Mlen) ];
        colorsR  = repmat( colorsR, 1, NumAdd ); colorsG  = repmat( colorsG, 1, NumAdd ); colorsB  = repmat( colorsB, 1, NumAdd );
    end
	
   % step 4. sort by depth so we can draw in back-to-front order
   [zvals zorder] = sort( gfaces(3,:),'descend');
   
   % step 5. draw colors
   if( 0 == color_method )
    img = rasterpts_mex( u(zorder), v( zorder ), colors( zorder ), img );
   elseif( 1 <= color_method )
       imgr = rasterpts_mex( u(zorder), v( zorder ), colorsR( zorder ), img );
       imgg = rasterpts_mex( u(zorder), v( zorder ), colorsG( zorder ), img );
       imgb = rasterpts_mex( u(zorder), v( zorder ), colorsB( zorder ), img );
       img = zeros( imgH,imgW,3); img(:,:,1)=imgr; img(:,:,2)=imgg;img(:,:,3)=imgb;
       img_bak = img;
       img = rgb2gray(img_bak);
   end
         
   shiftU = [img(1,:); img(1:end-1,:)]; 
   shiftD = [img(2:end,:); img(end,:)];
   shiftL = [img(:,1) img(:,1:end-1)];
   shiftR = [img(:,2:end)  img(:,end)];
   binary_mask = find( (shiftU .* shiftD .* shiftL .* shiftR) > 0 );
   
   if( 0 == color_method )
   img_tmp = zeros(size(img)); img_tmp( binary_mask ) = img(binary_mask);
   img = img_tmp;  img = img / max(img(:));
   elseif( 1 <= color_method )
       img = 0*img_bak;
       for k = 1:3
        imgk = img_bak(:,:,k);
        img_tmp = zeros(size(imgk)); 
        img_tmp( binary_mask ) = imgk(binary_mask);
        img(:,:,k) = img_tmp;  img(:,:,k) = img(:,:,k) / max(max(img(:,:,k)));
       end
   end
   
   img = imdownsamp(img,NxAA);
   breakhere = 1;
   %figure(1); imshow(img);
   u_zord = round( u(zorder)/NxAA );
   v_zord = round( v(zorder)/NxAA );
   z_zord = max(zvals(:))  + zeros(imgH/NxAA,imgW/NxAA);
   
   badidx1 = find( u_zord < 1 );   badidx2 = find( u_zord > size(img,2) );
   badidx3 = find( v_zord < 1 );   badidx4 = find( v_zord > size(img,1) );
   badidx  = union(badidx1,badidx2);   badidx_ = union(badidx3,badidx4);
   badidx  = union(badidx, badidx_ );
   
   zvals( badidx ) = []; u_zord(badidx) = []; v_zord(badidx) = [];
   
   for k = 1:numel(u_zord)
      z_zord( v_zord(k), u_zord(k) ) = zvals( k ); 
   end
  
end