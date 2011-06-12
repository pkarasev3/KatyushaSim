!mkdir -p output
!mkdir -p input 
!./get_test_images_from_wwww.sh

simfuncs = genpath('../');
addpath(simfuncs);
addpath('../matlab_utils/');
addpath('./input');

lookAt = [0,0,0];
[gCam]= ( [eye(3,3) ,[ 3;-10;-40 ]; [ 0 0 0 1]] * ... 
              [ expm( skewsym([ .1 .1 .1]) ) ,[0 0 0]' ; [ 0 0 0 1]]) ^(-1);
Nimgs = 200;
gObj    = eye(4,4);

% img params
 clear vrcl*;
 clear rockat*;
 vrcl.Npts  = 80;
 vrcl.NxAA  = 1.5;
 vrcl.imgH  = 480;
 vrcl.imgW  = 640;
 vrcl.ptype = 'perspective';
 vrcl.f_in  = vrcl.imgH*1.0;
 vrcl.gSE3  = gCam;
 vrcl.img   = zeros(vrcl.imgH,vrcl.imgW,3);
 vrcl.floorz= 0.0;
 vrcl.fscale= 20.0;
 vrcl.floor_img = imresize(imread_float('map01small.jpg'),1.0);
  
% multiple targets: different gObj and possibly drawing functions!
rocket_1 = vrcl;
rocket_2 = vrcl;
rocket_3 = vrcl;
plane_1  = vrcl;
rocket_1.gObj = gObj;
rocket_2.gObj = gObj;
rocket_3.gObj = gObj;
plane_1.gObj  = gObj;

if( exist('obj','var') )
  fclose(obj);
  clear obj;
end
buff_sz = 640*480*3 + 14;
obj = tcpip('localhost', 5001, 'OutputBufferSize',buff_sz,'InputBufferSize',buff_sz);
fopen(obj);

img_out = zeros(vrcl.imgH,vrcl.imgW,3);

for k = 1:Nimgs
    
 eta1   = [0; -1; 0];
 omega1 = [-0.05; 0.02; 0.02];
 eta2   = [0.05; -1.1; 0];
 omega2 = [-0.04; 0.03; -0.01];
 eta3   = [0.0; -1.4; 0.01];
 omega3 = [-0.06; 0.05; 0.05];
 
 % update by applying object-specific twists
rocket_1.gObj   = expm( [ [ skewsym(omega1) ,eta1 ]; ... 
                                  [ 0 0 0 0]]* .25 ) *rocket_1.gObj;
rocket_2.gObj   = expm( [ [ skewsym(omega2) ,eta2 ]; ... 
                                  [ 0 0 0 0]]* .25 ) *rocket_2.gObj;                                
rocket_3.gObj  = expm( [ [ skewsym(omega3) ,eta3 ]; ... 
                                  [ 0 0 0 0]]* .25 ) * rocket_3.gObj;                                
 
% get projected and colored points for each object
rocket_1  = drawRocket01( rocket_1 ); 
plane_1   = drawPlane3D( plane_1 );

rocket_1.gSE3 = gCam;
plane_1.gSE3  = gCam;

 % send all objects to varyadic function to get image 
 vrcl      = drawMultiObject(vrcl,rocket_1,plane_1);

 img_out   = img_out * 0.5 + (vrcl.img + (0.001 + rand(size(vrcl.img))*0.01 ) ./ (0.1 + vrcl.img ) )*0.5;
 
 sfigure(1); imshow(vrcl.img);  title( num2str_fixed_width(k) );
 print_mbytes( vrcl ); 
 
 % Need to put the bytes in the right order for opencv pointer cast
 % [B G R]_1 , [B G R]_2 , ... , across first, then down 
 raw_data = uint8(vrcl.img * 255);
 raw_rgb  = uint8(zeros( numel(vrcl.img(:)),1));
 raw_rgb(1:3:end) = raw_data(:,:,3)';
 raw_rgb(2:3:end) = raw_data(:,:,2)';
 raw_rgb(3:3:end) = raw_data(:,:,1)';
 
 % append a header and write to the stream
 raw_data = ['0123456789ABCD'  raw_rgb'];
 fwrite(obj,raw_data);
 
 writeImages = false; % save images to disk?
 if( writeImages )
  imwrite( uint16( (2^16 - 1)*vrcl.img ), ...
                        ['./output/rocket_simdemo_' num2str_fixed_width(k) '.png'] );
 end
 drawnow;

 img_smooth = imfilter( rgb2gray(img_out), fspecial('gaussian',[11 11],3.0),'replicate');
  [x y]     = find( max( img_smooth(:) ) == img_smooth );
  x = x(1); y = y(1);
  fprintf('x,y point: %f, %f \n',x,y);
  % Gains
      Kx             = 5;
      Ky             = 5;
  % Shifted/Scaled Coordinates
      xW             = (x/vrcl.imgW)-0.5;
      yW             = 0.5 - (y/vrcl.imgH);
  w_control      = zeros(3,1);
  w_control(1)   = -(  Ky * yW) ; % "tilt"
  w_control(2)   = -(  Kx * xW) ; % "pan"
  w_control(3)   = 0; % This might need to be non-zero for numerical reasons
  v_control      = [0;0;-50];
  zeta_CC        = [skewsym(w_control), v_control ; zeros(1,4) ];

  % control: update the camera pose
  dT             = 1.0 / Nimgs;
  gCam           = expm( zeta_CC * dT ) * gCam; 
 disp( gCam );
 
 fprintf('');
end

 fclose(obj);
