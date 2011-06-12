function [fractal] = julia( numIter,sz,verboseDisplay,var1,var2)
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%               Julia Fractals Using Matlab
%               Written By Sridharan, Mithun Aiyswaryan
%               Christian Albrechts Universit�t zu Kiel, Germany
%               Mail Your Comments At: s.mithun@indiatimes.com
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%  Trick added by Peter Karasev: use fractal to make a pseduo-random x,y sequence
%  extra outputs:  x(t), y(t), positions on the edge of the fractal blob
%  sample use:
%  [a b c] = julia(30,500,1,-rand(1,1),rand(1,1)-0.5);


shiftD = @(M) M([1 1:end-1],:);
shiftL = @(M) M(:,[2:end end]);
shiftR = @(M) M(:,[1 1:end-1]);
shiftU = @(M) M([2:end end],:); %#ok<*NASGU>

if( nargin < 1 )
  numIter = 10;
end
if( nargin < 2 )
  sz = 100;
end
if( nargin < 5 )
  var1 = -0.5;
  var2 = -0.1*rand(1,1)*1i;
end
if( nargin < 4 )
  verboseDisplay = 0 ;
end

x0=0;
y0=0;
extent=1.1;
x=linspace(x0-extent,x0+extent,sz);
y=linspace(y0-extent,y0+extent,sz);
[xtrans,ytrans]=meshgrid(x,y);

ztrans=xtrans+1i*ytrans;

for k=1:numIter;
  ztrans=ztrans.^2+var1+var2;

  t=exp(-abs(ztrans));
  t( isnan(t) ) = 1e-9;
  t( t < 1e-9 ) = 1e-9;
  if( verboseDisplay>1)
    imagesc(t); title(['iteration ' num2str(k) ]); 
    drawnow;
  end
end

if( verboseDisplay > 0 )
  sfigure(1);
  imagesc(t);
  axis('square','equal','off'); colormap default;
  var1+var2*1i %#ok<NOPRT>
end

fractal = t;
