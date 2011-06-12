function [img2] = imdownsamp(img,NN,bAllowZeroPad)
bIsInteger = 0;
if( isinteger(img) )
    img=double(img);
    bIsInteger = 1;
end
[h,w,numcolors] = size(img);

% should it automatically zero pad to integer multiple?
if( nargin == 3 )
   bPad = bAllowZeroPad;
else
    bPad = 0;
end

hMod = mod(h,NN);
wMod = mod(w,NN);
if( hMod ~= 0 )
    hMod = NN - hMod;
end
if( hMod ~= 0 )
    wMod = NN - wMod;
end

if( bPad && ( 0 ~= hMod + wMod ) ) % input size not divisible by N
    img_padded = zeros(h+hMod,w+wMod,numcolors);
    img_padded(1:h,1:w,:) = img;
    for k = 1:numcolors
        if( hMod > 0 )
            img_padded(h+1:h+hMod,1:w,k) = repmat(img(h,:,k),hMod,1);
        end
        if( wMod > 0 )
            img_padded(1:h,w+1:w+wMod,k) = repmat(img(:,w,k),1,wMod);
        end
    end
    img = img_padded;
    [h,w,numcolors] = size(img);
else
    % warning('let it crash due to non-integer indices'); %#ok<WNTAG>
    % either it was cleanly divisible, or not an integer and we'll crash
end

img2 = zeros(h/NN,w/NN,numcolors);
for cidx = 1:numcolors
   im2 = img(:,:,cidx);
   downimg = decimate(im2(:),NN,8,'fir'); % down sample columns
   im2 = reshape(downimg,h/NN,w)';
   downimg = decimate(im2(:),NN,8,'fir'); % down sample rows
   im2 = reshape(downimg,w/NN,h/NN)';
   img2(:,:,cidx) = im2;
end

if( bIsInteger ) % if it came in as uint8, return uint8
    img2 = uint8(img2);
end
