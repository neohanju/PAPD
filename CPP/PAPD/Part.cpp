#include "Part.h"

const double PART_SIZE_IN_ANCHOR_DOMAIN = 6.0;
const double PART_DISPLACEMENT_THRESHOLD_X = 9.0;
const double PART_DISPLACEMENT_THRESHOLD_Y = 9.0;

/************************************************************************
 Method Name: IsIntersect
 Description: 
	- 
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
bool COORDS::IsIntersect(const hj::LINE_SEGMENT lineSegment)
{
	hj::LINE_SEGMENT curEdge;
	// top
	curEdge.first.x  = this->x1;  curEdge.first.y  = this->y1;
	curEdge.second.x = this->x2;  curEdge.second.y = this->y1;
	if (hj::GetIntersection(lineSegment, curEdge)) { return true; }

	// left
	curEdge.first.x  = this->x1;  curEdge.first.y  = this->y1;
	curEdge.second.x = this->x1;  curEdge.second.y = this->y2;
	if (hj::GetIntersection(lineSegment, curEdge)) { return true; }

	// right
	curEdge.first.x  = this->x2;  curEdge.first.y  = this->y1;
	curEdge.second.x = this->x2;  curEdge.second.y = this->y2;
	if (hj::GetIntersection(lineSegment, curEdge)) { return true; }

	// bottom
	curEdge.first.x  = this->x1;  curEdge.first.y  = this->y2;
	curEdge.second.x = this->x2;  curEdge.second.y = this->y2;
	if (hj::GetIntersection(lineSegment, curEdge)) { return true; }

	return false;
}

/************************************************************************
 Method Name: GetOverlapArea
 Description: 
	- 
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
double COORDS::GetOverlapArea(const COORDS coords1, const COORDS coords2)
{
	double x1 = std::max(coords1.x1, coords2.x1);
	double x2 = std::min(coords1.x2, coords2.x2);
	double overlapW = x2 - x1 + 1.0;
	if (0 > overlapW) { return 0.0; }

	double y1 = std::max(coords1.y1, coords2.y1);	
	double y2 = std::min(coords1.y2, coords2.y2);	
	double overlapH = y2 - y1 + 1.0;
	if (0 > overlapH) { return 0.0; }

	return overlapW * overlapH;
}

/************************************************************************
 Method Name: CPart
 Description: 
	- Constructor
 Input Arguments:
	- 
 Return Values:
	- none
************************************************************************/
CPart::CPart()
{
}

/************************************************************************
 Method Name: ~CPart
 Description: 
	- Destructor
 Input Arguments:
	- none
 Return Values:
	- none
************************************************************************/
CPart::~CPart(void)
{
}

/************************************************************************
 Method Name: EstimateMissingPartRect
 Description: 
	- Estimate the rect (or bounding box) of a missing part with the current part and part model
 Input Arguments:
	- partModel: class instance for the part model
	- targetPartType: type of the target (estimating) part
	- targetPartComponent: component number of the target part
 Return Values:
	- COORDS (x1, y1, x2, y2)
************************************************************************/
COORDS CPart::EstimateMissingPartRect(int targetPartType, int targetPartComponent, const CPartModel &partModel)
{
	// find location of the target part
	cv::Point2d anchorBasis(0.0, 0.0);
	if (0 < type_) { anchorBasis = partModel.defs_[type_-1+(component_-1)*8].anchor; }
	cv::Point2d anchorPart = partModel.defs_[targetPartType-1+(targetPartComponent-1)*8].anchor;
	cv::Point2d partLocation = cv::Point2d(coords_.x1, coords_.y1) + anchor2pixel_ * (anchorPart - anchorBasis);

	// target part size in anchor domain (w = 6 / h = 6)
	double partSize = anchor2pixel_ * PART_SIZE_IN_ANCHOR_DOMAIN;

	// estimated part
	COORDS estimatedPart(partLocation.x, partLocation.y, partLocation.x + partSize, partLocation.y + partSize);

	return estimatedPart;
}

/************************************************************************
 Method Name: IsAssociable
 Description: 
	- Check whether two parts (this & input part) are associable or not
 Input Arguments:
	- targetPart: part for examination
 Return Values:
	- true: associable / false: not associable
************************************************************************/
bool CPart::IsAssociable(const CPart &targetPart)
{	
	if (this->type_ == targetPart.type_ || this->component_ != targetPart.component_) { return false; }

	// relative distance between two parts('s anchors)
	cv::Point2d vecAnchorDiff = this->anchor_ - targetPart.anchor_;

	// relative center distance
	cv::Point2d vecCenterDiff = binScale_ // ( * 2 * 0.5 for center position)
		                      * (cv::Point2d(coords_.x1 + coords_.x2, coords_.y1 + coords_.y2)
		                      -  cv::Point2d(targetPart.coords_.x1 + targetPart.coords_.x2, 
							                 targetPart.coords_.y1 + targetPart.coords_.y2));
	
	// displacement between desired part center and real center
	cv::Point2d displacement(std::abs(vecAnchorDiff.x - vecCenterDiff.x), std::abs(vecAnchorDiff.y - vecCenterDiff.y));

	// check
	if (displacement.x > PART_DISPLACEMENT_THRESHOLD_X || displacement.y > PART_DISPLACEMENT_THRESHOLD_Y) {	return false; }

	return true;
}

/************************************************************************
 Method Name: CheckOverlap
 Description: 
	- Check whether two parts (this & input part) are overlapped each other or not
 Input Arguments:
	- targetPart: part for examination
	- overlapRatio: minimum overlap ratio
 Return Values:
	- true: overlapped / false: not overlapped
************************************************************************/
bool CPart::CheckOverlap(const CPart *targetPart, double overlapRatio)
{
	return COORDS::GetOverlapArea(this->coords_, targetPart->coords_) > overlapRatio * std::min(this->coords_.area(), targetPart->coords_.area());
}

/************************************************************************
 Method Name: NonMaximalSuppression
 Description: 
	- Constructor
 Input Arguments:
	- 
 Return Values:
	- none
************************************************************************/
bool ScoreSortAscendComparator(const std::pair<int, double> score1, const std::pair<int, double> score2)
{
	return score1.second < score2.second;
}
std::vector<int> CPart::NonMaximalSuppression(const std::vector<CPart*> parts, const double overlap, std::vector<CPart*> *resultParts)
{	
	std::vector<int> vecPickedIdx; vecPickedIdx.reserve(parts.size());
	std::vector<int> vecRemainIdx(parts.size(), 0);
	std::vector<std::pair<int, double>> sortedScores(parts.size());
	if (NULL != resultParts)
	{
		resultParts->clear();
		resultParts->reserve(parts.size());
	}

	// sort by detection score
	for (int sIdx = 0; sIdx < parts.size(); sIdx++)
	{	
		sortedScores[sIdx].first  = sIdx;
		sortedScores[sIdx].second = parts[sIdx]->score_;
	}
	std::sort(sortedScores.begin(), sortedScores.end(), ScoreSortAscendComparator);
	for (int iIdx = 0; iIdx < sortedScores.size(); iIdx++)
	{
		vecRemainIdx[iIdx] = sortedScores[iIdx].first;
	}

	// pick and ban
	while (0 < vecRemainIdx.size())
	{
		int curIdx = vecRemainIdx.back();		
		vecPickedIdx.push_back(curIdx);	
		vecRemainIdx.pop_back();
		std::vector<int> vecNewRemainIdx; vecNewRemainIdx.reserve(vecRemainIdx.size());
		for (int iIdx = 0; iIdx < vecRemainIdx.size(); iIdx++)
		{
			if (COORDS::GetOverlapArea(parts[curIdx]->coords_, parts[vecRemainIdx[iIdx]]->coords_) 
				< std::min(parts[curIdx]->coords_.area(), parts[vecRemainIdx[iIdx]]->coords_.area()) * overlap)
			{
				vecNewRemainIdx.push_back(vecRemainIdx[iIdx]);
			}
		}
		vecRemainIdx = vecNewRemainIdx;
		if (NULL != resultParts) { resultParts->push_back(parts[curIdx]); }
	}

	return vecPickedIdx;
}

//()()
//('')HAANJU.YOO

