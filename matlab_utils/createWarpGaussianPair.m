function [A,B] = createWarpGaussianPair( N, p1, sx, sy )

if( nargin < 1 )
    N = 200;
end
if( nargin ~= 4 )
    p1 = 0.15;
    sx = 0.3;
    sy = 0.6;
end
xgrid = linspace(-4,4,N);
ygrid = linspace(-4,4,N);
[xx yy] = meshgrid( xgrid, ygrid );

% 'image 0' 
A = exp( -(xx.^2+yy.^2) );
A( A < p1 ) = 0.0;

% ground truth displacement field

shiftx = sx;
shifty = sy;
xxB = xx + shiftx;
yyB = yy + shifty;

% B(x,y) = A(x+u,y+v)
B = interp2( xx, yy, A, xxB, yyB, 'linear', A(end,end) );
