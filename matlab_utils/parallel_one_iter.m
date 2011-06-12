function parallel_one_iter()

addpath('../synth_image_gen/');


gSE3 = GetCameraSE3MatrixOGL( 2*[1 0.9 1.1], [0 0 0] );


disp('running serial...');

tic
for i = 1:30
    img = drawCube3D( 300, 300, gSE3, 50, 'perspective' ) ;
    if( mod( i,5 ) == 0 )
      imwrite(img,'imgSerial.png','png');
      loc = pwd();
      disp([ loc 'imgSerial.png' ] )
    end
    i
end
disp('Serial Compute Time: ')

toc


end