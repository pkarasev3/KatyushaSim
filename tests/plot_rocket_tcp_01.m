load rocket_tcp_01

x0 = [0;0;0;1];

Npts = numel( gCamAll );

sfigure(1); clf; hold on;

xlabel('x'); ylabel('y'); zlabel('z'); 
axis equal;

for k = 1:Npts
  
  cam_k = gCamAll{k}^-1 * x0;
  obj_k = gObjAll{k} * x0;
  
  if( k == 1 )
    plot3( cam_k(1), cam_k(3), -cam_k(2), 'bo','MarkerSize',8);
    plot3( obj_k(1), obj_k(3), -obj_k(2), 'ro','MarkerSize',8);
  end
  plot3( cam_k(1), cam_k(3), -cam_k(2), 'b-.');
  plot3( obj_k(1), obj_k(3), -obj_k(2), 'r-.');
  
  if( mod(k,40) == 0 )
    plot3( cam_k(1), cam_k(3), -cam_k(2), 'b.','MarkerSize',8);
    plot3( obj_k(1), obj_k(3), -obj_k(2), 'r.','MarkerSize',8);
  end
  
  pause(0.001);
  
end
plot3( cam_k(1), cam_k(3), -cam_k(2), 'b*','MarkerSize',8);
plot3( obj_k(1), obj_k(3), -obj_k(2), 'r*','MarkerSize',8);
hold off;
