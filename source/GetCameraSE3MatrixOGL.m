function [camA RR TT] = GetCameraSE3MatrixOGL( pos, lookat, strname, fignum ) 
dbstop if error 
% the matrix that transforms the 
% camera to be at pos, viewing the origin
% The T part of the matrix is just [pos]

% This .m function is designed to follow the OpenGL "lookat()"
% http://www.opengl.org/documentation/specs/man_pages/hardcopy/GL/html/glu/lookat.html

if nargin < 3, strname = 'Camera Origin'; end
if nargin < 4, fignum = 1; end

lookat = lookat(:);
T = pos(:);
TT = eye(4,4); TT(4,4) = 1; TT(1:3,4) = -T;

dir = -(lookat-T) / norm(T-lookat); % direction from point to origin


up = [0;1;0];
s = cross(dir,up); % s  Perp dir,up
s = s / norm(s);
u = cross(s,dir);  % u  Perp s,dir
u = u / norm(u);
R = [s';u';-dir'];
RR = [R zeros(3,1); zeros(1,3) 1];
camA = RR * TT;  % for transforming points to the view


