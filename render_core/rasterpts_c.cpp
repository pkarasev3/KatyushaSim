#include <matrix.h>
#include <mex.h> 
#include <math.h>
#include <cmath>
#include <iostream>

typedef int mwSize;
typedef int mwIndex;
typedef int mwSignedIndex;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs,  const mxArray *prhs[])
{

//declare variables
    double *u_in, *v_in, *colors_in, *img_out_m, *params_in;
    double *a_in, *kersz_in, *img_in, *gam_in; // alpha, 'kernel' step-size, time integration rate
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
    dims    = mxGetDimensions(prhs[0]);
    numdims = mxGetNumberOfDimensions(prhs[0]);

// number of points being rasterized (in back to front order!)
    num_pts = (int)dims[1];
    
   bool bDebugPrintF = false;
   if( bDebugPrintF ) {
     mexPrintf("num_pts= %d \n ",num_pts);
   }
// set the output pointer associated with image being written
    img_out_m = mxGetPr(plhs[0]);

//associate pointers of incoming data
    u_in       = mxGetPr(prhs[0]); // projected x coords 
    v_in       = mxGetPr(prhs[1]); // projected y coords 
    colors_in  = mxGetPr(prhs[2]); // color values 
    a_in       = mxGetPr(prhs[4]); // back to front alpha rate 
    kersz_in   = mxGetPr(prhs[5]); // spatial window size
    gam_in     = mxGetPr(prhs[6]); // time-integration
    img_in     = mxGetPr(prhs[3]);

    // 'integration box' for one point
    int    stepsz = 0;
    // 'integration rate' along ray. lower = more back-to-front contribution.
    double alpha  = 0.5;
    // 'time integration'
    double gam    = 0.0; 

//main program
    // fill in to start with
    for(i=0; i<imgH*imgW; i++) { 
       img_out_m[i] = img_in[ i ] * 0.25;
    }

    for(k=0;k<num_pts;k++)        // for every point
    {
      i_ = (int) ( v_in[k] - 1); 
      if( i_ < 0 ) 
         i_ = 0;
      j_ = (int) ( u_in[k] - 1);
      if( j_ < 0 )
         j_ = 0;
      
      stepsz = kersz_in[k];
      alpha  = a_in[k];
      gam    = gam_in[k];
      
      for( i = i_-stepsz; i <= i_+stepsz; i++ ) {
          for( j = j_-stepsz; j <= j_+stepsz; j++ ) {
           if( !(i < 0 || i >= imgH || j < 0 || j >= imgW)  ) 
           { // ensure in-bounds on image 
             double scale = exp( -(pow( double( j ) - double( j_ ) , 2.0 ) + 
                                  pow( double( i ) - double( i_ ) , 2.0 ) )/0.5 );
             double old_val          = (1-alpha) * scale * img_out_m[ j*imgH + i ];
             img_out_m[ j*imgH + i ] = old_val + (alpha) * colors_in[k];
           }
        }
      }
           
  }

    return;
}
