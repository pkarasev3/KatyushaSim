simfuncs = genpath('../');
addpath(simfuncs);
datainc  = genpath('../../../data');
addpath(datainc);
utilpaths = genpath('~/source/tann-lab/trunk/matlab_utils/');
addpath(utilpaths);

lookAt = [0,0,0];
[gCam]= ( [eye(3,3) ,[ -6;-10;-40 ]; [ 0 0 0 1]] * ... 
              [ expm( skewsym([ .1 .1 .1]) ) ,[0 0 0]' ; [ 0 0 0 1]]) ^(-1);
Nimgs = 200;
gObj    = eye(4,4);

% img params
 clear vrcl; 
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
 vrcl.floor_img = imresize(imread_float('map01.jpg'),1.0);
 for( k = 1:3 )
   vrcl.floor_img(:,:,k) = histeq( (0.2 + vrcl.floor_img(:,:,k)).^(1/2) );
 end
 
% multiple targets: different gObj and possibly drawing functions!
rocket_1 = vrcl;
rocket_2 = vrcl;
rocket_3 = vrcl;
plane_1  = vrcl;
rocket_1.gObj = gObj;
rocket_2.gObj = gObj;
rocket_3.gObj = gObj;
plane_1.gObj  = gObj;

if( ~exist('obj','var') )
  buff_sz = 640*480*3 + 14;
  obj = tcpip('localhost', 5001, 'OutputBufferSize',buff_sz,'InputBufferSize',buff_sz);
  fopen(obj);
end

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
rocket_2  = drawRocket02( rocket_2 ); 
rocket_1  = drawRocket01( rocket_1 ); 
rocket_3  = drawRocket01( rocket_3 );
plane_1   = drawPlane3D( plane_1 );

rocket_1.gSE3 = gCam;
rocket_2.gSE3 = gCam;
rocket_3.gSE3 = gCam;
plane_1.gSE3  = gCam;

 % send all objects to varyadic function to get image 
 vrcl      = drawMultiObject(vrcl,rocket_1,rocket_2, rocket_3,plane_1);
 
 vrcl.img  = vrcl.img + (0.001 + rand(size(vrcl.img))*0.01 ) ./ (0.1 + vrcl.img );
 
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
 end
 drawnow;
 fprintf('');
end

 fclose(obj);
