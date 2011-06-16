!mkdir -p output
!mkdir -p input 
!./get_test_images_from_wwww.sh

simfuncs = genpath('../');
addpath(simfuncs);
addpath('../matlab_utils/');
addpath('./input');

lookAt = [0,0,0];
[gCam]= ( [eye(3,3) ,[ 3;-10;-50 ]; [ 0 0 0 1]] * ... 
              [ expm( skewsym([ .1 .1 .1]) ) ,[0 0 0]' ; [ 0 0 0 1]]) ^(-1);
Nimgs = 800;
gObj    = eye(4,4);

% img params
 clear vrcl*;
 clear rockat*;
 vrcl.Npts  = 160;
 vrcl.NxAA  = 2.0;
 vrcl.imgH  = 480;
 vrcl.imgW  = 640;
 vrcl.ptype = 'perspective';
 vrcl.f_in  = vrcl.imgH*1.0;
 vrcl.gSE3  = gCam;
 vrcl.img   = zeros(vrcl.imgH,vrcl.imgW,3);
 vrcl.floorz= 0.0;
 vrcl.fscale= 35.0;
 vrcl.floor_img = imresize(imread_float('map01small.jpg'),1.5);
  
% multiple targets: different gObj and possibly drawing functions!
rocket_1 = vrcl;
rocket_2 = vrcl;
rocket_3 = vrcl;
plane_1  = vrcl;
stars_1  = vrcl;

plane_1.gObj  = gObj;
stars_1.gObj  = gObj;

gObj(1,4) = 5;
rocket_1.gObj = gObj;

gObj(1,4) = -10; gObj(3,4) = -15;
rocket_2.gObj = gObj;

gObj(1,4) = -10; gObj(3,4) = 15;
rocket_3.gObj = gObj;

if( exist('obj','var') )
  fclose(obj);
  clear obj;
end
buff_sz = 640*480*3 + 14;
obj = tcpip('localhost', 5001, 'OutputBufferSize',buff_sz,'InputBufferSize',buff_sz);
fopen(obj);

img_out = zeros(vrcl.imgH,vrcl.imgW,3);

gCamAll = cell(1,Nimgs);
gObjAll = cell(1,Nimgs);
xyAll   = cell(1,Nimgs);

xi = 0;
yi = 0;
dT = 1/400;

for k = 1:Nimgs
    
 eta1   = [0; -1; 0] * 1.0;
 omega1 = [0.01*sin(7*pi*k/Nimgs)+.01; 0.01*sin(5*pi*k/Nimgs)+0.01; 0.01+0.01*sin(9*pi*k/Nimgs)];
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

rocket_1.gSE3 = gCam;
rocket_2.gSE3 = gCam;
rocket_3.gSE3 = gCam;
plane_1.gSE3  = gCam;
stars_1.gSE3  = gCam;
                                
gObjAll{k}     = [rocket_1.gObj , rocket_2.gObj, rocket_3.gObj ];
gCamAll{k}     = gCam;
                                
% get projected and colored points for each object

rocket_1  = drawRocket02( rocket_1 ); 
rocket_2  = drawRocket02( rocket_2 );
rocket_3  = drawRocket02( rocket_3 );
plane_1   = drawPlane3D( plane_1 );
stars_1   = drawStars3D( stars_1 );

 % send all objects to varyadic function to get image 
 vrcl      = drawMultiObject(vrcl,rocket_1,rocket_2,rocket_3,plane_1,stars_1);
 vrcl.img  = vrcl.img .*(1 + 1.5e-1 * randn(size(vrcl.img))) + 1e-2 * randn(size(vrcl.img)) ./ (1e-1 + vrcl.img);
 vrcl.img( vrcl.img > 1 ) = 1;
 vrcl.img( vrcl.img < 0 ) = 0;
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
 
 writeImages = true; % save images to disk?
 if( writeImages )
  imwrite( uint16( (2^16 - 1)*vrcl.img ), ...
                        ['./output/rocket_simdemo_' num2str_fixed_width(k) '.png'] );
  imwrite( uint8( (2^8 - 1)*vrcl.img ), ...
                        ['./output/rocket_simdemo_' num2str_fixed_width(k) '.jpg'] )                      
 end
 drawnow;

 
  [data_out,COUNT,MSG] = fread(obj,4);
  x = double(data_out(1) + 256*data_out(2) ); 
  y = double(data_out(3) + 256*data_out(4) );
  fprintf('x,y point: %f, %f \n',x,y);
  % Gains
      Kx             = 10;
      Ky             = 10;
  % Shifted/Scaled Coordinates
      xW             = (x/vrcl.imgW)-0.5;
      yW             = 0.5 - (y/vrcl.imgH);
      xi             = xi + 0.1*xW - 5e-2*xi^3;
      yi             = yi + 0.1*yW - 5e-2*yi^3;
  w_control      = zeros(3,1);
  w_control(1)   = -(  Ky * (yW+0.5*yi) ) ; % "tilt"
  w_control(2)   = -(  Kx * (xW+0.5*xi) ) ; % "pan"
  w_control(3)   = 0; % This might need to be non-zero for numerical reasons
  v_control      = [0;0;-30];
  zeta_CC        = [skewsym(w_control), v_control ; zeros(1,4) ];

  % control: update the camera pose
 
  gCam           = expm( zeta_CC * dT ) * gCam; 
 disp( gCam );
  
  xyAll{k} = [x;y];
 fprintf('');
end

save rocket_tcp_01 gObjAll gCamAll xyAll

 fclose(obj);
 
