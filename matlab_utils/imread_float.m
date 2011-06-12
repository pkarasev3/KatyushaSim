function img = imread_float( str_filename )
%  read and doubleize the image, scale to [0,1]
  img = imread(str_filename);
  img = double(img)/255.0;
end
