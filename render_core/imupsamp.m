function [img2] = imupsamp(img,NN)

% if it came in as int, convert to double and make a note of it
bWasInt = 0;
if( isinteger(img) )
   bWasInt = 1;
   img = double(img);
end

[h,w,numcolors] = size(img);
img2 = zeros(h*NN,w*NN,numcolors);
for cidx = 1:numcolors
   im2 = img(:,:,cidx);
   upimg = interp(im2(:),NN); % upsample columns
   im2 = reshape(upimg,h*NN,w)';
   upimg = interp(im2(:),NN); % upsample rows
   im2 = reshape(upimg,w*NN,h*NN)';
   img2(:,:,cidx) = im2;
end

if( bWasInt )
   img2 = uint8( img2 ); 
end