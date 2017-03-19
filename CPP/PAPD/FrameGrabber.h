/******************************************************************************
 * Name : CFrameGrabber
 * Date : 2016.01.27
 * Author : HAANJU.YOO
 * Version : 0.9
 * Description :
 *	class for grabbing frame images
 *
 ******************************************************************************/
#pragma once
#include "cv.h"

typedef enum { HJ_GRAB_CONSECUTIVE = 0, HJ_GRAB_REALTIME } HJ_GRAB_MODE;

namespace hj {

class CFrameGrabber
{
	//------------------------------------------------------
	// METHODS
	//------------------------------------------------------
public:
	CFrameGrabber(void);
	~CFrameGrabber(void);

	bool Open(const char *basepath, const char *imagenamePrefix, HJ_GRAB_MODE mode = HJ_GRAB_CONSECUTIVE, int numDigits = 0);
	void Close(void);
	cv::Mat GrabGrame(size_t frameIndex = 0);

	//------------------------------------------------------
	// VARIABLES
	//------------------------------------------------------
private:
	bool bInit_;
	char strFilepath_[128];
	HJ_GRAB_MODE grabMode_;
	cv::Mat currFrame_;
	cv::Mat nextFrame_;
};

}

//()()
//('')HAANJU.YOO
