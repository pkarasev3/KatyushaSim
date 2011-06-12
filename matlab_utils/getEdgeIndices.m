function edgeIndices = getEdgeIndices(imgHeight, imgWidth, margin)
%compute indices at the edge of an image
%
%INPUT:
% - imgHeight: double height of the image
% - imgWidth: double width of the image
% - margin: (optional) margin of pixels from edge, default 1
%
%OUTPUT:
% - edgeIndices = logical matrix (imgHeight x imgWidth) being true at the
%                 pixels specified by margin. false elsewhere.

if nargin < 3
    margin = 1;
end

edgeIndices = false(imgHeight, imgWidth);
edgeIndices(1:margin, :) = true;
edgeIndices(end-margin+1:end, :) = true;
edgeIndices(:, end-margin+1:end) = true;
edgeIndices(:, 1:margin) = true;
    