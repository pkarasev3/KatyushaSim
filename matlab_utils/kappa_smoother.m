function Iout = kappa_smoother( img, iter, bShow )
% do a 'kappa to the 1/3' nonlinear smoothing...
% usage:  [img_out] = kappa_smoother( image_in, iter )
% suggested: use 'iter' between 100 and 1000

dbstop if error
if(nargin<3)
  bShow = false;
end

shiftD = @(M) M([1 1:end-1],:);
shiftL = @(M) M(:,[2:end end]);
shiftR = @(M) M(:,[1 1:end-1]);
shiftU = @(M) M([2:end end],:);

dscale  = double( max(abs(img(:)) ) );
Iout    = double(img)/dscale;
ncolors = size(Iout,3);

[xx,yy] = meshgrid( 1:size(img,2), 1:size(img,1) );
xx = 20 * xx / size(img,2);
yy = 20 * yy / size(img,1);
sx = xx(1,2) - xx(1,1);
sy = yy(2,1) - yy(1,1);

dt = 0.1 * (sx * sy);

for n = 1:ncolors
  
  Ik = Iout(:,:,n);
  Ik_prv = Ik;
  for k = 1:iter
    
    dx = (shiftR(Ik)-shiftL(Ik))/(2*sx);
    dy = (shiftU(Ik)-shiftD(Ik))/(2*sy);
    dxx = (shiftR(Ik)+shiftL(Ik) - 2*Ik)/(sx^2);
    dyy = (shiftU(Ik)+shiftD(Ik) - 2*Ik)/(sy^2);
    dxy = (shiftR(shiftU(Ik))-shiftR(shiftD(Ik)) - shiftU(shiftL(Ik)) + shiftD(shiftL(Ik)))/(4*sx*sy);
    
    ngrad  = (dx.^2 + dy.^2);
    kappaN = (dyy .* dx.^2 - 2 * dx .* dy .* dxy + dxx .* dy.^2 );
    kappaD = ngrad.^(3/2);
    
    kappa = ( kappaN ./ (kappaD+1e-6) );
      
    dt = sx * sy / max(sqrt(ngrad(:)).*kappa(:)) * 0.5;
    
    %stability_factor = dt * max(kappa_term(:)) / (sx * sy ); 
    % must be less than 1...or 1/sqrt(2) 
    
    
    Ik = dt * kappa .* sqrt(ngrad) + Ik_prv;
    % Ik = dt * ( dxx + dyy ) + Ik_prv; % heat equation only
    Ik_prv = Ik;
    themax = max(Ik(:)) ;
    Ik = Ik / themax;
    Iout(:,:,n) =  Ik;
    
    if( bShow )
      imagesc( Iout ); drawnow;
    end
    
   
    
  end
  
  
  
end

Iout = Iout * dscale;

end
