function setFigure(fh,pos,scalein)
    if( nargin < 3 )
        scalein =1;
    end
    set(fh,'Position', [pos 400*scalein 300*scalein]);
end
