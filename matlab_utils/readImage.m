function img=readImage(vidName, frm, extension)
%read an image
%
%INPUT:
% - vidName: string, name of video
% - frm: + if double: frame number
%        + if string: frame filename (including some 3 char extension,
%                           which will be overwritten by input "extension")
% - extension: (optional) string, extension type to be loaded,
%              default 'png'

if nargin < 3
    extension = 'png';
end

vidPath = getVidPath(vidName);

if isnumeric(frm)
    frm = frmNum2frmName(frm);
end

img=imread([vidPath extension '/' frm(1:end-4) '.' extension]);

    