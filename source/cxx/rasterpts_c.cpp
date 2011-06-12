#include <matrix.h>
#include <mex.h> 
#include <math.h>
#include <cmath>

/* Definitions to keep compatibility with earlier versions of ML */
#ifndef MWSIZE_MAX
typedef int mwSize;
typedef int mwIndex;
typedef int mwSignedIndex;

#if (defined(_LP64) || defined(_WIN64)) && !defined(MX_COMPAT_32)
/* Currently 2^48 based on hardware limitations */
# define MWSIZE_MAX    281474976710655UL
# define MWINDEX_MAX   281474976710655UL
# define MWSINDEX_MAX  281474976710655L
# define MWSINDEX_MIN -281474976710655L
#else
# define MWSIZE_MAX    2147483647UL
# define MWINDEX_MAX   2147483647UL
# define MWSINDEX_MAX  2147483647L
# define MWSINDEX_MIN -2147483647L
#endif
#define MWSIZE_MIN    0UL
#define MWINDEX_MIN   0UL
#endif

/*
%  code being replaced that is slow:
% 
%   for k = 1 : length(zorder) 
%       ii = round( v( zorder( k ) ) );
%       jj = round( u( zorder( k ) ) );
%       if( ii < 1 || ii > imgH || jj < 1 || jj > imgW )
%          continue; 
%       end
%       img(ii,jj) = img(ii,jj)*0.05+0.95*colors( zorder(k) );
%    end */

// img = rasterpts_c(u,v,colors,img);
#define WINDOWSIZE 2
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

//declare variables
    double *u_in, *v_in, *colors_in, *img_out_m;
	 int numdims;
    const mwSize *dims;
    
    int num_pts;
    int i,j,k;
    int i_,j_;
    
    int imgH, imgW; 

    imgH = mxGetM(prhs[3]); 
    imgW = mxGetN(prhs[3]);

    /* Create an mxArray for the output data */
    plhs[0] = mxCreateDoubleMatrix( imgH , imgW, mxREAL);


//figure out dimensions
    dims = mxGetDimensions(prhs[0]);
    numdims = mxGetNumberOfDimensions(prhs[0]);

// number of points being rasterized (in back to front order!)
    num_pts = (int)dims[1];
  //  mexPrintf("num_pts= %d \n ",num_pts);
// set the output pointer associated with image being written
    img_out_m = mxGetPr(plhs[0]);

//associate pointers of incoming data
    u_in       = mxGetPr(prhs[0]);
    v_in       = mxGetPr(prhs[1]);
    colors_in  = mxGetPr(prhs[2]);

    double alpha = 0.5;
//main program
    
    for(i=0; i<imgH*imgW; i++){img_out_m[i] = 0.0;}

    for(k=0;k<num_pts;k++)        // for every point
    {
        i_ = (int) ( v_in[k] - 1); 
        if( i_ < 0 )
            i_ = 0;
        j_ = (int) ( u_in[k] - 1);
        if( j_ < 0 )
            j_ = 0;
  
        for( i = i_-WINDOWSIZE; i < i_+WINDOWSIZE; i++ ) {
            for( j = j_-WINDOWSIZE; j < j_+WINDOWSIZE; j++ ) {
                   if( !(i < 0 || i >= imgW || j < 0 || j >= imgH)  )
                      img_out_m[ j*imgH + i ] = img_out_m[ j*imgH + i ] * (1-alpha) 
                                               + (alpha) * colors_in[k];
            }
        }
             
    }

    return;
}
