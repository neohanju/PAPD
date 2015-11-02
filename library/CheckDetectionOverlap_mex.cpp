#include "mex.h"
#include "math.h"

#define NUM_COORDS (4)
#define max(a,b) (((a) > (b)) ? (a) : (b))
#define min(a,b) (((a) < (b)) ? (a) : (b))
#define ROUND(a) (floor(a+0.5))

struct rect_ { int x1, y1, x2, y2, w, h; };

void FillOverlapRegion(rect_ rectTarget, rect_ rectCheckOverlap, char *overlapMap)
{
	int x1 = max(rectTarget.x1, rectCheckOverlap.x1);
	int y1 = max(rectTarget.y1, rectCheckOverlap.y1);
	int x2 = min(rectTarget.x2, rectCheckOverlap.x2);
	int y2 = min(rectTarget.y2, rectCheckOverlap.y2);
	int commonW = x2 - x1 + 1;
	int commonH = y2 - y1 + 1;
	//int commonW = min(x2 - x1 + 1, rectTarget.w);
	//int commonH = min(y2 - y1 + 1, rectTarget.h);
	if (0 >= commonW || 0 >= commonH) { return; }
	int commonX = x1 - rectTarget.x1; // different from MATLAB code
	int commonY = y1 - rectTarget.y1;
	
	// fill overlapped region
	int rowStart = rectTarget.h * commonX + commonY;
	for (int colIdx = 0; colIdx < commonW; colIdx++) {
		for (int rowIdx = 0; rowIdx < commonH; rowIdx++) {
			overlapMap[rowStart + rowIdx] = 1;
		}
		rowStart += rectTarget.h;
	}
}

double GetOverlapRegionRatio(rect_ rect, char *overlapMatp)
{
	int numTotalPixel   = rect.w * rect.h;
	int numCoveredPixel = 0;
	double overlapRatio = 0.0;
	for (int pos = 0; pos < numTotalPixel; pos++)
	{
		numCoveredPixel += (int)overlapMatp[pos];
	}
	overlapRatio = (double)numCoveredPixel / (double)numTotalPixel;
	return overlapRatio;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	/* input:
		- CD1PartCoords: 4xN double, [0, 0, 0, 0]' for visible parts
		- CD2PartCoords: 4xN double, [0, 0, 0, 0]' for missed parts
		- partOccMaxOverlap
		- rescaleForSpeedup
	*/
	// combinations
	double* CD1PartCoords = mxGetPr(prhs[0]);
	double* CD2PartCoords = mxGetPr(prhs[1]);
	size_t numCD1Parts    = mxGetN(prhs[0]);
	size_t numCD2Parts    = mxGetN(prhs[1]);
	// scalar parameters
	double maxOverlap = mxGetScalar(prhs[2]);
	double rescale    = mxGetScalar(prhs[3]);
	// for processing
	char *overlapMap = NULL;
	// output
	bool bOverlap = false;

	int CD1CoordsIdx = 0;
	for (int pIdx1 = 0; pIdx1 < numCD1Parts; pIdx1++, CD1CoordsIdx += NUM_COORDS)
	{			
		rect_ rectTarget;
		rectTarget.x1 = (int)ROUND(CD1PartCoords[CD1CoordsIdx] / rescale);	
		rectTarget.x2 = (int)ROUND(CD1PartCoords[CD1CoordsIdx+2] / rescale);
		if (0 == rectTarget.x1 && 0 == rectTarget.x2) { continue; } // check validity
		rectTarget.y1 = (int)ROUND(CD1PartCoords[CD1CoordsIdx+1] / rescale);
		rectTarget.y2 = (int)ROUND(CD1PartCoords[CD1CoordsIdx+3] / rescale);
		rectTarget.w = rectTarget.x2 - rectTarget.x1 + 1;
		rectTarget.h = rectTarget.y2 - rectTarget.y1 + 1;
		// cover map
		overlapMap = (char*)mxCalloc(rectTarget.w * rectTarget.h, sizeof(char));

		int CD2CoordsIdx = 0;
		for (int pIdx2 = 0; pIdx2 < numCD2Parts; pIdx2++, CD2CoordsIdx += NUM_COORDS)
		{
			rect_ rectCheckOverlap;
			rectCheckOverlap.x1 = (int)ROUND(CD2PartCoords[CD2CoordsIdx] / rescale);
			rectCheckOverlap.x2 = (int)ROUND(CD2PartCoords[CD2CoordsIdx+2] / rescale);
			if (0 == rectCheckOverlap.x1 && 0 == rectCheckOverlap.x2) { continue; } // check validity
			rectCheckOverlap.y1 = (int)ROUND(CD2PartCoords[CD2CoordsIdx+1] / rescale);
			rectCheckOverlap.y2 = (int)ROUND(CD2PartCoords[CD2CoordsIdx+3] / rescale);
			rectCheckOverlap.w = rectCheckOverlap.x2 - rectCheckOverlap.x1 + 1;
			rectCheckOverlap.h = rectCheckOverlap.y2 - rectCheckOverlap.y1 + 1;

			FillOverlapRegion(rectTarget, rectCheckOverlap, overlapMap);
		}

		// check overlap
		if (GetOverlapRegionRatio(rectTarget, overlapMap) >= maxOverlap)
		{
			bOverlap = true;
		}		
		mxFree(overlapMap);
		if (bOverlap) { break; }
	}
	plhs[0] = mxCreateLogicalScalar(bOverlap);
}

