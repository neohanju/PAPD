#pragma once
#include "cv.h"

struct defInfo
{
	double w[4];
	int blockLabel;
	cv::Point2d anchor;
};

class CPartModel
{
	//------------------------------------------------------
	// METHODS
	//------------------------------------------------------
public:
	CPartModel(void);
	~CPartModel(void);
	bool LoadModel(const char *filepath);

	//------------------------------------------------------
	// VARIABLES
	//------------------------------------------------------
public:
	double sbin_;
	double thresh_;
	cv::Size maxSize_;
	cv::Size minSize_;
	int interval_;
	int numBlocks_;
	int numComponents_;
	// cv::Mat coeff_;
	// rootfilters_
	// offsets_
	// components_
	// partfilters_
	std::vector<defInfo> defs_;
	// cascade_
};

//()()
//('')HAANJU.YOO
