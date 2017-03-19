#include "Detection.h"

CONFIGURATION::CONFIGURATION(void)
{
	for (int pIdx = 0; pIdx < DPM_NUM_PART_TYPES; pIdx++) { this->partExist_[pIdx] = false; }
	this->numParts_ = 0;
}

CONFIGURATION::CONFIGURATION(bool initFlag)
{
	for (int pIdx = 0; pIdx < DPM_NUM_PART_TYPES; pIdx++) {	this->partExist_[pIdx] = initFlag; }
	this->numParts_ = initFlag? DPM_NUM_PART_TYPES : 0;
}

CONFIGURATION::~CONFIGURATION(void)
{
}

CONFIGURATION CONFIGURATION::operator+(const CONFIGURATION &x)
{
	CONFIGURATION tmp;
	tmp.numParts_ = 0;
	for (int pIdx = 0; pIdx < DPM_NUM_PART_TYPES; pIdx++)
	{
		tmp.partExist_[pIdx] = this->partExist_[pIdx] | x.partExist_[pIdx];
		if (tmp.partExist_[pIdx]) { tmp.numParts_++; }
	}
	return tmp;
}

bool CONFIGURATION::operator==(const CONFIGURATION &x)
{
	if (this->numParts_ != x.numParts_) { return false; }
	for (int pIdx = 0; pIdx < DPM_NUM_PART_TYPES; pIdx++)
	{
		if (this->partExist_[pIdx] != x.partExist_[pIdx]) { return false; }
	}
	return true;
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
CDetection::CDetection(void)
	: normalizedScore_(0.0)
	, globalDetectionProbability_(0.0)
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
CDetection::~CDetection(void)
{
}

/************************************************************************
 Method Name: CheckOverlap
 Description: 
	- examine whether the target detection covers the current detection or not
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
bool CDetection::CheckOverlap(const CDetection &targetDetection, const double partOverlapRatio) const
{
	double overlapedArea;
	for (int thisPartIdx = DPM_ROOT+1; thisPartIdx < DPM_NUM_PART_TYPES; thisPartIdx++)
	{		
		if (!this->configuration_.partExist_[thisPartIdx]) { continue; }

		// consider current part's total area covered by the target detection
		overlapedArea = 0.0;
		for (int targetPartIdx = DPM_ROOT+1; targetPartIdx < DPM_NUM_PART_TYPES; targetPartIdx++)
		{
			if (!targetDetection.configuration_.partExist_[targetPartIdx]) { continue; }
			overlapedArea += COORDS::GetOverlapArea(this->parts_[thisPartIdx]->coords_, targetDetection.parts_[targetPartIdx]->coords_);
		}		
		if (overlapedArea > partOverlapRatio * this->parts_[thisPartIdx]->coords_.area()) { return true; }

		// check the overlap of connection
		for (int cIdx = 0; cIdx < NUM_CONNECT_TYPES; cIdx++)
		{
			if (NULL == targetDetection.connections_[cIdx]) { continue; }
			//if (this->parts_[thisPartIdx]->centerCoords_.IsIntersect(targetDetection.connections_[cIdx]->connectionLine))
			if (this->parts_[thisPartIdx]->centerCoords_.IsIntersect(targetDetection.connections_[cIdx]->connectionLine))
			{
				return true;
			}
		}
	}
	return false;
}

/************************************************************************
 Method Name: IsAtFront
 Description: 
	- examine whether the current detection is at the front of the target 
	detection or not
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
bool CDetection::IsAtFront(const CDetection &targetDetection) const
{
	if (this->parts_[DPM_ROOT]->coords_.y2 > targetDetection.parts_[DPM_ROOT]->coords_.y2)
	{
		return true;
	}
	else if (this->parts_[DPM_ROOT]->coords_.y2 < targetDetection.parts_[DPM_ROOT]->coords_.y2)
	{
		return false;
	}
	else
	{
		return this->parts_[DPM_ROOT]->coords_.height() > targetDetection.parts_[DPM_ROOT]->coords_.height();
	}
}

/************************************************************************
 Method Name: IsCompatible
 Description: 
	- 
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
bool CDetection::IsCompatible(const CDetection &detection1, const CDetection &detection2, const double rootMaxOverlap, const double partMaxOverlap)
{
	// check common part
	for (int typeIdx = 0; typeIdx < DPM_NUM_PART_TYPES; typeIdx++)
	{
		if (!detection1.configuration_.partExist_[typeIdx] || !detection2.configuration_.partExist_[typeIdx]) { continue; }
		if (detection1.parts_[typeIdx] == detection2.parts_[typeIdx]) { return false; }
	}

	//// check overlap (if two detections are not overlaped with their roots, they are compatible)
	//if (detection1.parts_[DPM_ROOT]->CheckOverlap(detection2.parts_[DPM_ROOT], 0.0)) { return true; }

	// check root overlap
	if (detection1.parts_[DPM_ROOT]->CheckOverlap(detection2.parts_[DPM_ROOT], rootMaxOverlap)) { return false; }

	// check part overlap
	if (detection1.CheckOverlap(detection2, partMaxOverlap)
		|| detection2.CheckOverlap(detection1, partMaxOverlap))
	{ return false; }

	return true;
}

/************************************************************************
 Method Name: NumOccludedParts
 Description: 
	- 
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
int CDetection::NumOccludedParts(const CDetection &targetDetection, const double partOverlapRatio)
{
	int    numOverlapedParts  = 0;
	bool   bConnectionOverlap = false;
	double PartOverlapedArea  = 0.0;
	for (int thisPartIdx = DPM_ROOT+1; thisPartIdx < DPM_NUM_PART_TYPES; thisPartIdx++)
	{		
		if (this->configuration_.partExist_[thisPartIdx]) { continue; }

		// consider current part's total area covered by the target detection
		PartOverlapedArea = 0.0;
		for (int targetPartIdx = DPM_ROOT+1; targetPartIdx < DPM_NUM_PART_TYPES; targetPartIdx++)
		{
			if (targetDetection.configuration_.partExist_[targetPartIdx])
			{
				PartOverlapedArea += COORDS::GetOverlapArea(this->parts_[thisPartIdx]->coords_, 
					                                        targetDetection.parts_[targetPartIdx]->coords_);
			}
		}		
		if (PartOverlapedArea > this->parts_[thisPartIdx]->coords_.area() * partOverlapRatio)
		{ 
			numOverlapedParts++; 
			continue;
		}

		// check the overlap of connection
		bConnectionOverlap = false;
		for (int cIdx = 0; cIdx < NUM_CONNECT_TYPES; cIdx++)
		{
			if (NULL == targetDetection.connections_[cIdx]) { continue; }
			//if (this->parts_[thisPartIdx]->centerCoords_.IsIntersect(targetDetection.connections_[cIdx]->connectionLine))
			if (this->parts_[thisPartIdx]->centerCoords_.IsIntersect(targetDetection.connections_[cIdx]->connectionLine))
			{
				bConnectionOverlap = true;
				break;
			}
		}
		if (bConnectionOverlap)
		{
			numOverlapedParts++;
			continue;
		}
	}
	return numOverlapedParts;
}

/************************************************************************
 Method Name: GetTotalPartScore
 Description: 
	- 
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
double CDetection::GetTotalPartScore(void) const
{
	double totalScore = 0.0;
	for (int partIdx = 0; partIdx < DPM_NUM_PART_TYPES; partIdx++)
	{
		if (this->configuration_.numParts_ < DPM_NUM_PART_TYPES && DPM_ROOT == partIdx) { continue; }
		if (this->configuration_.partExist_[partIdx]) { totalScore += this->parts_[partIdx]->score_; }
	}
	return totalScore;
}

//()()
//('')HAANJU.YOO
