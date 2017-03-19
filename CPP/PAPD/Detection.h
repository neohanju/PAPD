#pragma once
#include "Part.h"
#include "PAPD_defines.h"

class CONFIGURATION
{
public:
	CONFIGURATION(void);
	CONFIGURATION(bool initFlag);
	~CONFIGURATION(void);	
	CONFIGURATION operator+(const CONFIGURATION &x);	
	bool operator==(const CONFIGURATION &x);	
public:
	bool partExist_[DPM_NUM_PART_TYPES];
	int  numParts_;
};

class CDetection
{
	//------------------------------------------------------
	// METHODS
	//------------------------------------------------------
public:
	CDetection(void);
	~CDetection(void);
	bool   CheckOverlap(const CDetection &targetDetection, const double partOverlapRatio) const;
	bool   IsAtFront(const CDetection &targetDetection) const;
	static bool IsCompatible(const CDetection &detection1, const CDetection &detection2, const double rootMaxOverlap, const double partMaxOverlap);
	int    NumOccludedParts(const CDetection &targetDetection, const double partOverlapRatio);
	double GetTotalPartScore(void) const;
	

	//------------------------------------------------------
	// VARIABLES
	//------------------------------------------------------
public:
	DPM_COMPONENT componentIndex_;
	CONFIGURATION configuration_;
	double        detectionScore_;
	double        totalScore_;
	CPart*        parts_[DPM_NUM_PART_TYPES];
	PART_CONNECT* connections_[NUM_CONNECT_TYPES];
	double        normalizedScore_;
	double        globalDetectionProbability_;
};

typedef std::vector<CDetection> DetectionSet;

//()()
//('')HAANJU.YOO
