function img_out = silent_rectangle(cen, rad, img_in, color_nofig, W )
% cen: (i,j) , rad (i,j) , img_in (uint8!), 
% color_nofig([256 100 0], W (width)
% Draw box entirely on the image, not in a figure
% Therefore, it can be:
%          a) saved without displaying to screen (faster)
%          b) displayed without figure grabbing focus via sfigure() , so
%                user can multi-task while displaying

    if( ~exist( 'color_nofig','var') )
        color_nofig = [255, 0, 0];
    end
    nc = size( img_in, 3 );
    rad = 1+mean(rad); % display a square as aspect ratio is exactly what 
                                         % we want to ignore in case of profile view
                                         % +1 so target is fully unobscured by box
    img_r = img_in(:,:,1);
    img_g = img_in(:,:,2);
    img_b = img_in(:,:,3);
    img_out = zeros( size(img_in ) );
    if( ~exist('W','var') )
      W = 2; % line thickness
    end
    
    for k = 1:nc
        lefti = repmat( round(cen(1)-rad:cen(1)+rad), 1, W );
        leftj = [round(repmat( cen(2)-rad, 1, numel(lefti)/W )) , ...
                        round(repmat( cen(2)-rad-1, 1, numel(lefti)/W ))];
        left_idx = safe_sub2ind( size( img_in(:,:,k) ), lefti, leftj );
        
        righti = repmat( round(cen(1)-rad:cen(1)+rad), 1, W);
        rightj = [round(repmat( cen(2)+rad, 1, numel(righti)/W )), ...
                        round(repmat( cen(2)+rad+1, 1, numel(righti)/W ))];
        right_idx = safe_sub2ind( size(img_in(:,:,k)), righti, rightj );
        
        upj = repmat(round(cen(2)-rad:cen(2)+rad),1,W);
        upi = [round(repmat( cen(1)-rad, 1, numel(upj)/W )), ...
                     round(repmat( cen(1)-rad-1, 1, numel(upj)/W )) ];
        up_idx = safe_sub2ind( size(img_in(:,:,k)), upi, upj );
        
        downj = repmat(round(cen(2)-rad:cen(2)+rad),1,W);
        downi = [round(repmat( cen(1)+rad, 1, numel(downj)/W )), ... 
                     round(repmat( cen(1)+rad+1, 1, numel(downj)/W )) ];
        down_idx = safe_sub2ind( size(img_in(:,:,k)), downi, downj );
        
        idx_all = [left_idx right_idx up_idx down_idx ];
        if( 1 == k )
            img_r(idx_all) = color_nofig(k);
            img_out(:,:,1) = img_r;
        elseif( 2 == k )
            img_g(idx_all) = color_nofig(k);
            img_out(:,:,2) = img_g;
        else
            img_b(idx_all) = color_nofig(k);
            img_out(:,:,3) = img_b;
        end
    end
    img_out = uint8(img_out);
    
    
end
