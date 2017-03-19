/******************************************************************************
 * Name : CPart
 * Date : 2016.01.27
 * Author : HAANJU.YOO
 * Version : 0.9
 * Description :
 *	- class for describing parts of each pedestrian
 ******************************************************************************/
#pragma once
#include "PartModel.h"
#include "hjlib.h"

class COORDS
{
	// METHODS
public:
	COORDS(void) {};
	COORDS(double _x1, double _y1, double _x2, double _y2) 
		: x1(_x1), y1(_y1), x2(_x2), y2(_y2)
		, width_(x2-x1+1.0), height_(y2-y1+1.0)
		, area_(width_*height_) {};
	~COORDS(void) {};
	double      area(void)   const { return area_; }
	double      width(void)  const { return width_; }
	double      height(void) const { return height_; }
	cv::Rect    rect(void)   const { return cv::Rect((int)x1, (int)y1, (int)(x2 - x1 + 1.0), (int)(y2 - y1 + 1.0)); };
	cv::Point2d center(void) const { return cv::Point2d(0.5 * (x1 + x2), 0.5 * (y1 + y2)); }
	bool        IsIntersect(const hj::LINE_SEGMENT lineSegment);
	static double GetOverlapArea(const COORDS coords1, const COORDS coords2);

	// VARIABLES
public:
	double x1, y1, x2, y2;
private:
	double width_;
	double height_;
	double area_;
};

class CPart
{
	//------------------------------------------------------
	// METHODS
	//------------------------------------------------------
public:
	CPart(void);
	~CPart(void);

	COORDS EstimateMissingPartRect(int targetPartType, int targetPartComponent, const CPartModel &partModel);
	bool   IsAssociable(const CPart &targetPart);
	bool   CheckOverlap(const CPart *targetPart, double overlapRatio);
	static std::vector<int> NonMaximalSuppression(const std::vector<CPart*> parts, const double overlap, std::vector<CPart*> *resultParts = NULL);
	//double GetOverlapArea(const CPart *targetPart);

	//------------------------------------------------------
	// VARIABLES
	//------------------------------------------------------
public:
	int rootID_;
	int component_;
	int type_;
	COORDS coords_;
	COORDS centerCoords_;
	double score_;
	double scale_;
	double binScale_;
	double anchor2pixel_;
	cv::Point2d anchor_;	
};

//()()
//('')HAANJU.YOO

