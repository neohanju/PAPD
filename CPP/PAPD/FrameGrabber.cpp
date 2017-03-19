#include "FrameGrabber.h"

namespace hj {

/************************************************************************
 Method Name: 
 Description: 
	- 
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
CFrameGrabber::CFrameGrabber(void)
{
}


/************************************************************************
 Method Name: 
 Description: 
	- 
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
CFrameGrabber::~CFrameGrabber(void)
{
}


/************************************************************************
 Method Name: 
 Description: 
	- 
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
bool CFrameGrabber::Open(const char *basepath, 
						 const char *imagenamePrefix, 
						 HJ_GRAB_MODE mode,
						 int numDigits)
{
	if (bInit_) { this->Close(); }

	if (0 == numDigits)
	{
		// TODO: read directory and save file list
	}
	else
	{
		sprintf_s(strFilepath_, "%s\\%s");
	}

	return bInit_;
}


/************************************************************************
 Method Name: 
 Description: 
	- 
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
void CFrameGrabber::Close(void)
{
	if (!bInit_) { return; }

	// memory clean-up
	if (!currFrame_.empty()) { currFrame_.release(); }
	if (!nextFrame_.empty()) { nextFrame_.release(); }

	bInit_ = false;
}


/************************************************************************
 Method Name: 
 Description: 
	- 
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
cv::Mat CFrameGrabber::GrabGrame(size_t frameIndex)
{
	return currFrame_;
}

}
