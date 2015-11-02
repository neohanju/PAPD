#include "mex.h"

#define min(a,b) (((a) < (b)) ? (a) : (b))
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	// inputs
	double* partIdx1 = mxGetPr(prhs[0]); /* 1xN input matrix */
	double* partIdx2 = mxGetPr(prhs[1]);
	size_t numParts1 = mxGetN(prhs[0]);
	size_t numParts2 = mxGetN(prhs[1]);

	bool bHasCommon = false;
	for (int i = 0; i < min(numParts1, numParts2); i++)
	{
		if (partIdx1[i] != partIdx2[i]) { continue; }
		bHasCommon = true;
		break;
	}	
	// output
	plhs[0] = mxCreateLogicalScalar(bHasCommon);
	return;
}

