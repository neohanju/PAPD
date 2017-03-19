#include "mex.h"

#define max(a,b) (((a) > (b)) ? (a) : (b))
#define min(a,b) (((a) < (b)) ? (a) : (b))
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	// inputs
	double *coords1   = mxGetPr(prhs[0]);     /* 1x4 input matrix */
	double *coords2   = mxGetPr(prhs[1]);     /* 1x4 input matrix */
	double minOverlap = mxGetScalar(prhs[2]); /* input scalar */

	bool bOverlaped = false;
	double area1 = (coords1[2]-coords1[0]+1)*(coords1[3]-coords1[1]+1);
	double area2 = (coords2[2]-coords2[0]+1)*(coords2[3]-coords2[1]+1);
	double x1 = max(coords1[0], coords2[0]);
	double y1 = max(coords1[1], coords2[1]);
	double x2 = min(coords1[2], coords2[2]);
	double y2 = min(coords1[3], coords2[3]);
	double commonW = x2-x1+1;
	double commonH = y2-y1+1;
	if (0 < commonW && 0 < commonH)
	{
		// compute overlap
		double overlap = commonW*commonH/min(area1, area2);
		if (overlap > minOverlap) { bOverlaped = true; }
	}

	// output
	plhs[0] = mxCreateLogicalScalar(bOverlaped);
	return;
}

