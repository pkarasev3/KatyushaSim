function parallel_test ()

% test par-for .... parallelize?? 
% use instead ??? createMatlabPoolJob ???

sched = findResource('scheduler','type','local') 
set(sched,'ClusterSize',8) 

addpath('../synth_image_gen/');


gSE3 = GetCameraSE3MatrixOGL( 2*[1 0.9 1.1], [0 0 0] );


disp('running serial...');

tic
for i = 1:30
    img = drawCube3D( 300, 300, gSE3, 50, 'perspective' ) ;
    if( mod( i,5 ) == 0 )
      imwrite(img,'imgSerial.png','png');
    end
    i
end
disp('Serial Compute Time: ')
toc

tic
disp('Spawning threads for parallel (timer started, must count init cost...)...')
matlabpool open 4


parfor i = 1:30
     img = drawCube3D( 300, 300, gSE3, 50, 'perspective' ) ;
    if( mod( i,5 ) == 0 )
      imwrite(img,'imgParallel.png','png');
    end
    disp(num2str(i));
end
disp('Parallel Compute Time: ')
toc

disp('Shutting down threads...')
matlabpool close force

% PK Laptop: 27 parallel versus 38 secs for serial! (1.41)
% Wolverine quad core: 16.9 serials versus  10.8 parallel (1.57)
% Beast 16 (slowish) cores: 31.9 serial , 23.8 with 2 cores (crap longer if init time is counted - 41 sec )

end
