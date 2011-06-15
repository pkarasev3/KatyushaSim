simfuncs = genpath('../');
addpath(simfuncs);
datainc  = genpath('../../../data');
addpath(datainc);
utilpaths = genpath('~/source/tann-lab/trunk/matlab_utils/');
addpath(utilpaths);

lookAt = [0,0,0];
[gCam]= ( [eye(3,3) ,[ 3;-3;-35 ]; [ 0 0 0 1]] * ... 
              [ expm( skewsym([ .1 .1 .1]) ) ,[0 0 0]' ; [ 0 0 0 1]]) ^(-1);
Nimgs = 200;
gObj    = eye(4,4);

% img params
 clear vrcl; 
 clear rocket*;
 clear stars*;
 vrcl.Npts  = 160;
 vrcl.NxAA  = 2;
 vrcl.imgH  = 480;
 vrcl.imgW  = 640;
 vrcl.ptype = 'perspective';
 vrcl.f_in  = vrcl.imgH*1.0;
 vrcl.gSE3  = gCam;
 vrcl.img   = zeros(vrcl.imgH,vrcl.imgW,3);
 
% multiple targets: different gObj and possibly drawing functions!
rocket_1 = vrcl;
rocket_2 = vrcl;
rocket_3 = vrcl;
stars_1  = vrcl;
rocket_1.gObj = gObj;
rocket_2.gObj = gObj;
rocket_3.gObj = gObj;

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
 stars_1.gObj   = eye(4,4);
                                
% get projected and colored points for each object
rocket_2  = drawRocket02( rocket_2 ); 
rocket_1  = drawRocket01( rocket_1 ); 
rocket_3  = drawRocket01( rocket_3 );
stars_1   = drawStars3D( stars_1 );

% send all objects to varyadic function to get image 
 vrcl      = drawMultiObject(vrcl,rocket_1,rocket_2, rocket_3,stars_1);
 
 sfigure(1); imshow(vrcl.img);  title( num2str_fixed_width(k) );
 print_mbytes( vrcl ); 
 
 writeImages = false; % save images to disk?
 if( writeImages )
  imwrite( uint16( (2^16 - 1)*vrcl.img ), ...
                        ['./output/rocket_simdemo_' num2str_fixed_width(k) '.png'] );
 end
 drawnow;
 fprintf('');
end

 
