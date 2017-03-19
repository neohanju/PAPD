/******************************************************************************
 * Name : CPAPD
 * Date : 2016.01.27
 * Author : HAANJU.YOO
 * Version : 0.9
 * Description :
 *	class for 'Part Association for Pedestrian Detection'
 *
 ******************************************************************************/
#pragma once
#include "cv.h"
#include "Detection.h"
#include "ParameterParser.h"
#include "opencv2\highgui\highgui.hpp"
#include <list>

class CPAPD
{
	//------------------------------------------------------
	// METHODS
	//------------------------------------------------------
public:
	CPAPD(void);
	~CPAPD(void);
	bool Initialize(const PARAM_SET &params);
	bool Finalize(void);	
	void Run(int frameIdx);
private:
	bool LoadDetections(const char *filepath, const CPartModel &model);
	void Association(const cv::Mat inputFrame, const DetectionSet &inputDetections, DetectionSet &outputDetections);
	void Visualization(const cv::Mat inputFrame, const DetectionSet &resultDetectionSet, const int frameIdx);
	void GenerateConfigurations(const int AffinityMatrix[][DPM_NUM_PART_TYPES]);
	bool CheckConnectivityOfConfiguration(const int startPartIndex, const CONFIGURATION &configuration, const int AffinityMatrix[][DPM_NUM_PART_TYPES], const CONFIGURATION *exception = NULL);
	void Clustering(const DetectionSet &candidateDetections, std::vector<DetectionSet> &outputClusters, std::vector<unsigned int> *vecNumPedestrianEstimation = NULL);
	void GenerateCandidateDetections(const DetectionSet &inputDetections, DetectionSet &outputDetections, const double minOcclusionRatio);

	// visualization related
	void ShowDetection(const cv::String strWindowName, const cv::Mat inputFrame, const CDetection &detection, int windowX = 0, int windowY = 0);
	void ShowDetections(const cv::String strWindowName, const cv::Mat inputFrame, const DetectionSet &detections, int windowX = 0, int windowY = 0);
	void ShowAssociations(const cv::String strWindowName, const cv::Mat inputFrame, const DetectionSet &detections, int windowX = 0, int windowY = 0, cv::Mat *outputImage = NULL);

	// file interface
	bool SaveResult(const char *filepath, const DetectionSet &resultDetections);
	
	//------------------------------------------------------
	// VARIABLES
	//------------------------------------------------------
public:
private:
	bool		 bInit_;
	DetectionSet detectionSetBuffer_;	
	DetectionSet resultDetectionSet_;
	DetectionSet optimalDetections_;

	std::list<CPart>        listParts_;
	std::list<CDetection>   listDetections_;
	std::list<PART_CONNECT> listConnections_;

	std::string strDatasetPath_;
	std::string strPartInputPath_;
	std::string strOutputPath_;
	CPartModel  partModel_;

	double nmsRootRatio_;
	double nmsHeadRatio_;
	double nmsPartRatio_;
	double nmsEvalRatio_;
	double partCoverRatio_;
	double solverTimelimit_;
	bool   bVisualize_;
	bool   bRecord_;
		
	std::vector<CONFIGURATION> configurations_;

	CvVideoWriter *vwOutputVideo_;
};

//()()
//('')HAANJU.YOO


