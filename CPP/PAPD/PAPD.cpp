#include "PAPD.h"
#include "GraphSolver.h"
#include <iostream>
#include <sstream>
#include <fstream>
#include <time.h>
#include <direct.h>

#define DO_RECORD

const int AffinityMatrix_[DPM_NUM_PART_TYPES][DPM_NUM_PART_TYPES] = {
	{0, 0, 0, 0, 0, 0, 0, 0, 0}, // ROOT: 0 (double resolution)
	{0, 0, 0, 1, 0, 1, 0, 0, 0}, //   1
	{0, 0, 0, 0, 1, 0, 0, 1, 1}, // 3   5
	{0, 1, 0, 0, 0, 1, 1, 0, 0}, // 6   7
	{0, 0, 1, 0, 0, 0, 1, 1, 1}, //   4
	{0, 1, 0, 1, 0, 0, 0, 1, 0}, //  8 2
	{0, 0, 0, 1, 1, 0, 0, 0, 1},
	{0, 0, 1, 0, 1, 1, 0, 0, 0},
	{0, 0, 1, 0, 1, 0, 1, 0, 0}
};

const cv::Scalar COLOR_PARULA[DPM_NUM_PART_TYPES] = {
	cv::Scalar(134.9460,  42.4065,  53.0655),
	cv::Scalar(224.7219,  98.0571,   3.7134),
	cv::Scalar(212.3704, 131.5545,  20.2661),
	cv::Scalar(199.4992, 165.5492,   5.8076),
	cv::Scalar(160.8922, 183.9570,  50.6303),
	cv::Scalar(117.2299, 190.9854, 139.1248),
	cv::Scalar( 88.3193, 186.6664, 210.7766),
	cv::Scalar( 49.5592, 201.1026, 253.6708),
	cv::Scalar( 13.7190, 250.6905, 248.9565)
};

const std::vector<cv::Scalar> COLORS = hj::GenerateColors(3000);

bool ClusterIDAscendComparator(const PAIR_UINT &pair1, const PAIR_UINT &pair2)
{
	return pair1.second < pair2.second;
}
bool GDPDescendComparator(const CDetection &detection1, const CDetection &detection2)
{
	return detection1.globalDetectionProbability_ > detection2.globalDetectionProbability_;
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
CPAPD::CPAPD(void)
	: bInit_(false)
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
CPAPD::~CPAPD(void)
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
bool CPAPD::Initialize(const PARAM_SET &params)
{
	if (bInit_) { return false; }

	// set parameters
	std::string strPartModelPath;
	for (int paramIdx = 0; paramIdx < params.size(); paramIdx++)
	{		
		if      (0 == params[paramIdx].first.compare("DATASET_PATH"))       { strDatasetPath_   = params[paramIdx].second; }
		else if (0 == params[paramIdx].first.compare("PART_DETECTION_DIR")) { strPartInputPath_ = strDatasetPath_ + "/" + params[paramIdx].second; }
		else if (0 == params[paramIdx].first.compare("PART_MODEL_FILE"))    { strPartModelPath  = params[paramIdx].second; }
		else if (0 == params[paramIdx].first.compare("RESULT_DIR"))         { strOutputPath_    = params[paramIdx].second; }
		else if (0 == params[paramIdx].first.compare("ROOT_MAX_OVERLAP"))   { nmsRootRatio_     = std::stod(params[paramIdx].second); }
		else if (0 == params[paramIdx].first.compare("HEAD_NMS_RATIO"))     { nmsHeadRatio_     = std::stod(params[paramIdx].second); }
		else if (0 == params[paramIdx].first.compare("PART_NMS_RATIO"))     { nmsPartRatio_     = std::stod(params[paramIdx].second); }
		else if (0 == params[paramIdx].first.compare("EVAL_MIN_OVERLAP"))   { nmsEvalRatio_     = std::stod(params[paramIdx].second); }
		else if (0 == params[paramIdx].first.compare("PART_COVER_RATIO"))   { partCoverRatio_   = std::stod(params[paramIdx].second); }
		else if (0 == params[paramIdx].first.compare("SOVLER_TIMELIMIT"))   { solverTimelimit_  = std::stod(params[paramIdx].second); }		
		else if (0 == params[paramIdx].first.compare("DO_RECORD"))          { bRecord_          = 1 == std::stoi(params[paramIdx].second); }
	}

	// generate candidate configurations
	GenerateConfigurations(AffinityMatrix_);

	// load part model
	partModel_.LoadModel(strPartModelPath.c_str());

	// generate result saving path	
	_mkdir(strOutputPath_.c_str());

	// video related
	vwOutputVideo_ = NULL;
	
	return bInit_ = true;
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
bool CPAPD::Finalize(void)
{
	if (!bInit_) { return false; }

	listDetections_.clear();
	listParts_.clear();
	listConnections_.clear();

	cv::destroyAllWindows();

	bInit_ = false;
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
void CPAPD::Run(int frameIdx)
{
	std::string strImagePath  = strDatasetPath_   + hj::sprintf("/frame_%04d.jpg", frameIdx);
	std::string strPartPath   = strPartInputPath_ + hj::sprintf("/frame_%04d_part_candidates.txt", frameIdx);
	std::string strResultPath = strOutputPath_    + hj::sprintf("/frame_%04d_result.txt", frameIdx);

	// load image
	cv::Mat inputFrame = cv::imread(strImagePath);

	// load detections
	LoadDetections(strPartPath.c_str(), partModel_);

	// association
	Association(inputFrame, detectionSetBuffer_, resultDetectionSet_);

	// visualization
	Visualization(inputFrame, resultDetectionSet_, frameIdx);
	//cv::waitKey(0);

	// save frame result
	//SaveResult(strResultPath.c_str(), resultDetectionSet_);
	SaveResult(strResultPath.c_str(), optimalDetections_);
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
bool CPAPD::LoadDetections(const char *filepath, const CPartModel &model)
{
	assert(bInit_);

	// reset part instances
	detectionSetBuffer_.clear();
	listParts_.clear();	
	double curPyramidLevel = 0.0;

	// file reading
	std::ifstream fstrIn;
	fstrIn.open(filepath);
	if (!fstrIn.good()) 
	{
		std::cerr << "Cannot find file <" << filepath << ">";
		return false; // exit if file not found
	}

	// get lines
	std::deque<std::string> lines;
	while (!fstrIn.eof())
	{
		std::string elem;
		std::getline(fstrIn, elem);
		if (0 == elem.size()) { continue; }
		lines.push_back(elem);
	}
	fstrIn.close();

	// parsing each line and save them to a CDetection instance
	detectionSetBuffer_.resize(lines.size());
	for (int lIdx = 0; lIdx < lines.size(); lIdx++)
	{
		std::stringstream ss(lines[lIdx]);
		std::string item;
		std::vector<double> values;
		values.reserve(48);
		while (std::getline(ss, item, ','))
		{
			values.push_back(std::stod(item));
		}

		detectionSetBuffer_[lIdx].componentIndex_ = (DPM_COMPONENT)((int)values[0] - 1); // to consider the index difference between MATLAB and C++
		detectionSetBuffer_[lIdx].configuration_  = CONFIGURATION(true);
		detectionSetBuffer_[lIdx].detectionScore_ = values[1];
		detectionSetBuffer_[lIdx].totalScore_     = 0.0;		
		curPyramidLevel = values[2];
		
		// generate CPart instances
		int pos = 3;		
		for (int pIdx = 0; pIdx < DPM_NUM_PART_TYPES; pIdx++)
		{
			CPart newPart;
			newPart.rootID_       = lIdx;
			newPart.component_    = detectionSetBuffer_[lIdx].componentIndex_;
			newPart.type_         = pIdx;
			newPart.coords_       = COORDS(values[pos], values[pos+1], values[pos+2], values[pos+3]);
			newPart.score_        = values[pos+4];
			newPart.scale_        = std::pow(2.0, -(curPyramidLevel - 1) / model.interval_);
			newPart.binScale_     = newPart.scale_ / model.sbin_;
			newPart.anchor2pixel_ = model.sbin_ / newPart.scale_;
			newPart.anchor_       = model.defs_[pIdx].anchor;

			double w = newPart.coords_.x2 - newPart.coords_.x1;
			double h = newPart.coords_.y2 - newPart.coords_.y1;
			newPart.centerCoords_ = COORDS(newPart.coords_.x1 + 0.1 * w, newPart.coords_.y1 + 0.1 * h, 
				                           newPart.coords_.x2 - 0.1 * w, newPart.coords_.y2 - 0.1 * h);

			listParts_.push_back(newPart);
			detectionSetBuffer_[lIdx].parts_[pIdx] = &listParts_.back();

			// get total score
			detectionSetBuffer_[lIdx].totalScore_ += newPart.score_;

			pos += 5;
		}

		// part connections
		for (int cIdx = 0; cIdx < NUM_CONNECT_TYPES; cIdx++)
		{
			PART_CONNECT newConnect = DEFAULT_CONNECT[cIdx];
			newConnect.connectionLine.first  = detectionSetBuffer_[lIdx].parts_[newConnect.from]->coords_.center();
			newConnect.connectionLine.second = detectionSetBuffer_[lIdx].parts_[newConnect.to]->coords_.center();
			listConnections_.push_back(newConnect);
			detectionSetBuffer_[lIdx].connections_[cIdx] = &listConnections_.back();
		}

		detectionSetBuffer_[lIdx].globalDetectionProbability_ = 0.0;
	}

	//// DEBUG
	//for (DetectionSet::iterator dIter = detectionSetBuffer_.begin(); dIter != detectionSetBuffer_.end(); /* do in the loop */)
	//{
	//	if (200.0 < (*dIter).parts_[DPM_ROOT]->coords_.height())
	//	{
	//		dIter = detectionSetBuffer_.erase(dIter);
	//		continue;
	//	}
	//	dIter++;
	//}

	return true;
}

/************************************************************************
 Method Name: Association
 Description: 
	- do association with part detections
 Input Arguments:
	- inputFrame: input image frame
	- detections: input detections (containing each part)
	- outputDetections(output): result detections
 Return Values:
	- none
************************************************************************/
void CPAPD::Association(const cv::Mat inputFrame, const DetectionSet &inputDetections, DetectionSet &outputDetections)
{
	assert(bInit_);
	time_t timeStart = clock();

	outputDetections.clear();	
	DetectionSet optimalDetections;	
	
	// DEBUG
	//ShowDetections("raw inputs", inputFrame, inputDetections, 0, 0);
	//cv::waitKey(0);

	//---------------------------------------------------------
	// NMS WITH HEAD
	//---------------------------------------------------------		
	std::vector<CPart*> vecHeads[DPM_NUM_COMPONENTS];
	std::vector<int>    vecIndex[DPM_NUM_COMPONENTS];
	for (int cIdx = 0; cIdx < DPM_NUM_COMPONENTS; cIdx++)
	{
		vecHeads[cIdx].reserve(inputDetections.size());
		vecIndex[cIdx].reserve(inputDetections.size());
	}
	for (int dIdx = 0; dIdx < inputDetections.size(); dIdx++)
	{	
		vecHeads[inputDetections[dIdx].componentIndex_].push_back(inputDetections[dIdx].parts_[DPM_HEAD]);
		vecIndex[inputDetections[dIdx].componentIndex_].push_back(dIdx);
	}	
	DetectionSet suppressedDetections; suppressedDetections.reserve(inputDetections.size());
	for (int cIdx = 0; cIdx < DPM_NUM_COMPONENTS; cIdx++)
	{
		std::vector<int> vecRemainDetectionIdx = CPart::NonMaximalSuppression(vecHeads[cIdx], nmsHeadRatio_);
		for (int dIdx = 0; dIdx < vecRemainDetectionIdx.size(); dIdx++)
		{
			suppressedDetections.push_back(inputDetections[vecIndex[cIdx][vecRemainDetectionIdx[dIdx]]]);
		}
	}
	for (int cIdx = 0; cIdx < DPM_NUM_COMPONENTS; cIdx++)
	{
		vecHeads[cIdx].clear();
		vecIndex[cIdx].clear();
	}
	
	// DEBUG
	// SHOW NMS RESULTS
	//ShowDetections("after nms", inputFrame, suppressedDetections, 0, 500);
	//cv::waitKey(0);

	//---------------------------------------------------------
	// DETECTION CLUSTERING
	//---------------------------------------------------------  
	std::vector<unsigned int> numPedestriansInCluster;
	std::vector<DetectionSet> detectionClusters;
	Clustering(suppressedDetections, detectionClusters, &numPedestriansInCluster);
	
	std::vector<hj::Graph> graphQPs(detectionClusters.size());
	std::vector<hj::Mat2D> matQPs(detectionClusters.size());

	// DEBUG
	//for (int clusterIdx = 4; clusterIdx < detectionClusters.size(); clusterIdx++)
	for (int clusterIdx = 0; clusterIdx < detectionClusters.size(); clusterIdx++)
	{		
		printf("CLUSTER: %d\n", clusterIdx);
		//---------------------------------------------------------
		// GENERATE DETECTIONS
		//---------------------------------------------------------
		time_t timeDetectionGenerationStart = clock();
		printf("\tGenerate detections...");
		DetectionSet candidateDetections;
		GenerateCandidateDetections(detectionClusters[clusterIdx], candidateDetections, 0.0);
		printf("%f sec\n", (double)(clock() - timeDetectionGenerationStart) / (double)CLOCKS_PER_SEC);
		// classify detections

		if (2 > candidateDetections.size())
		{
			for (int dIdx = 0; dIdx < candidateDetections.size(); dIdx++)
			{
				candidateDetections[dIdx].globalDetectionProbability_ = 1.0;
				outputDetections.push_back(candidateDetections[dIdx]);
				optimalDetections.push_back(candidateDetections[dIdx]);
			}
			continue;
		}

		//---------------------------------------------------------
		// SCORE NORMALIZATION
		//---------------------------------------------------------		
		double minScore = DBL_MAX;
		double maxScore = DBL_MIN;
		for (int dIdx = 0; dIdx < candidateDetections.size(); dIdx++)
		{
			if (candidateDetections[dIdx].totalScore_ < minScore) { minScore = candidateDetections[dIdx].totalScore_; }
			if (candidateDetections[dIdx].totalScore_ > maxScore) { maxScore = candidateDetections[dIdx].totalScore_; }
		}
		if (DBL_MAX != minScore && DBL_MIN != maxScore)
		{
			double invScoreInterval = 1.0 / (maxScore - minScore);
			for (int dIdx = 0; dIdx < candidateDetections.size(); dIdx++)
			{
				candidateDetections[dIdx].normalizedScore_ = (candidateDetections[dIdx].totalScore_ - minScore) * invScoreInterval;
			}
		}

		// DEBUG
		//ShowDetections("current cluster", inputFrame, candidateDetections, 500, 500);

		//---------------------------------------------------------
		// OPTIMIZATION
		//---------------------------------------------------------
		// generate graph for QP
		time_t timeGraphGenerationStart = clock();		

		matQPs[clusterIdx].resize((int)candidateDetections.size(), (int)candidateDetections.size());
		graphQPs[clusterIdx].AddVertices(candidateDetections.size());
		hj::VertexSet curVertexSet = graphQPs[clusterIdx].GetAllVerteces();
		for (int dIdx = 0; dIdx < candidateDetections.size(); dIdx++)
		{
			printf("\r\tGraph construction: %d/%d...", dIdx+1, candidateDetections.size());

			// unary score
			int numVisibleParts = candidateDetections[dIdx].configuration_.numParts_;
			curVertexSet[dIdx]->weight = 
				std::pow(candidateDetections[dIdx].normalizedScore_, 2.0) * std::pow((double)numVisibleParts / (double)DPM_NUM_PART_TYPES, 2.0) // filter score
				//candidateDetections[dIdx].normalizedScore_ * std::pow((double)numVisibleParts / (double)DPM_NUM_PART_TYPES, 2.0) // filter score
				+ numVisibleParts - DPM_NUM_PART_TYPES; // occlusion penalty

			// pairwise score
			for (int colIdx = dIdx + 1; colIdx < candidateDetections.size(); colIdx++)
			{
				//// DEBUG
				//DetectionSet detectionPair(2);
				//detectionPair[0] = candidateDetections[dIdx];
				//detectionPair[1] = candidateDetections[colIdx];
				//ShowAssociations("detection pairs", inputFrame, detectionPair, 1000, 500);

				if (!CDetection::IsCompatible(candidateDetections[dIdx], candidateDetections[colIdx], nmsRootRatio_, nmsPartRatio_))
				{
					// edge between incompatible detections
					graphQPs[clusterIdx].AddEdge(curVertexSet[dIdx], curVertexSet[colIdx]);
					continue;
				}

				// to avoid cash miss, fill only the upper triangle of QPmat with a total value
				matQPs[clusterIdx].at(dIdx, colIdx) = candidateDetections[dIdx].IsAtFront(candidateDetections[colIdx])
					? candidateDetections[colIdx].NumOccludedParts(candidateDetections[dIdx], nmsPartRatio_)
					: candidateDetections[dIdx].NumOccludedParts(candidateDetections[colIdx], nmsPartRatio_);
			}
		}
		printf("%f sec\n", (double)(clock() - timeGraphGenerationStart) / (double)CLOCKS_PER_SEC);

		hj::CGraphSolver solver;
		hj::stGraphSolvingResult solvingResult;
		solver.Initialize(&graphQPs[clusterIdx], HJ_GRAPH_SOLVER_BLS4QP, matQPs[clusterIdx]);

		time_t timeGraphSolvingStart = clock();		
		solver.Solve();
		solvingResult = solver.GetResult();
		printf("%f sec\n", (double)(clock() - timeGraphSolvingStart) / (double)CLOCKS_PER_SEC);

		//---------------------------------------------------------
		// GLOBAL DETECTION PROBABILITY
		//---------------------------------------------------------
		double hypothesisTotalScore = 0.0;
		for (int sIdx = 0; sIdx < solvingResult.vecSolutions.size(); sIdx++)
		{
			hypothesisTotalScore += solvingResult.vecSolutions[sIdx].second;
		}
		for (int sIdx = 0; sIdx < solvingResult.vecSolutions.size(); sIdx++)
		{
			double curHypothesisProbability = solvingResult.vecSolutions[sIdx].second / hypothesisTotalScore;
			for (int vIdx = 0; vIdx < solvingResult.vecSolutions[sIdx].first.size(); vIdx++)
			{
				candidateDetections[solvingResult.vecSolutions[sIdx].first[vIdx]->id].globalDetectionProbability_ += curHypothesisProbability;
			}
		}
		for (int dIdx = 0; dIdx < candidateDetections.size(); dIdx++)
		{
			if (0.0 < candidateDetections[dIdx].globalDetectionProbability_)
			{
				outputDetections.push_back(candidateDetections[dIdx]);
			}
		}
		//outputDetections.insert(outputDetections.end(), candidateDetections.begin(), candidateDetections.end());

		//---------------------------------------------------------
		// OPTIMAL DETECTIONS
		//---------------------------------------------------------		
		if (0 == solvingResult.vecSolutions.size()) { continue; }
		DetectionSet resultDetections; resultDetections.reserve(solvingResult.vecSolutions.front().first.size());
		for (int vIdx = 0; vIdx < solvingResult.vecSolutions.front().first.size(); vIdx++)
		{
			resultDetections.push_back(candidateDetections[solvingResult.vecSolutions.front().first[vIdx]->id]);
		}
		optimalDetections.insert(optimalDetections.end(), resultDetections.begin(), resultDetections.end());

		//// DEBUG
		//ShowAssociations("optimization result", inputFrame, resultDetections, 500, 30);
		//cv::waitKey(0);
		//for (int sIdx = 1; sIdx < solvingResult.vecSolutions.size(); sIdx++)
		//{
		//	DetectionSet subsolutionDetections; subsolutionDetections.reserve(solvingResult.vecSolutions[sIdx].first.size());
		//	for (int vIdx = 0; vIdx < solvingResult.vecSolutions.front().first.size(); vIdx++)
		//	{
		//		subsolutionDetections.push_back(candidateDetections[solvingResult.vecSolutions[sIdx].first[vIdx]->id]);
		//	}
		//	ShowAssociations("subsolutions result", inputFrame, subsolutionDetections, 1000, 30);
		//	cv::waitKey(0);
		//}
	}
	std::sort(outputDetections.begin(), outputDetections.end(), GDPDescendComparator);

	printf("Total elapsed time : %f sec\n", (double)(clock() - timeStart) / (double)CLOCKS_PER_SEC);

	//---------------------------------------------------------
	// RESULT PACKAGING
	//---------------------------------------------------------
	optimalDetections_ = optimalDetections;	
}

/************************************************************************
 Method Name: Visualization
 Description: 
	- 
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
void CPAPD::Visualization(const cv::Mat inputFrame, const DetectionSet &resultDetectionSet, const int frameIdx)
{
	cv::Mat displayImage;
	ShowAssociations("optimization result", inputFrame, optimalDetections_, 500, 30, &displayImage);
	char strFrameInfo[100];
	sprintf_s(strFrameInfo, "Frame: %04d", frameIdx);
	cv::rectangle(displayImage, cv::Rect(5, 2, 145, 22), cv::Scalar(0, 0, 0), CV_FILLED);
	cv::putText(displayImage, strFrameInfo, cv::Point(6, 20), cv::FONT_HERSHEY_SIMPLEX, 0.7, cv::Scalar(255, 255, 255));
	cv::namedWindow("result");
	cv::moveWindow("result", 700, 10);
	cv::imshow("result", displayImage);	
	cv::waitKey(1);

	if (bRecord_)
	{
		IplImage *currentFrame = new IplImage(displayImage);
		if (NULL == vwOutputVideo_) 
		{
			// logging related
			time_t curTimer = time(NULL);
			struct tm timeStruct;
			localtime_s(&timeStruct, &curTimer);
			char resultFileDate[256];
			char resultOutputFileName[256];
			sprintf_s(resultFileDate, "%s/result_%02d%02d%02d_%02d%02d%02d", 
				strOutputPath_.c_str(),
				timeStruct.tm_year + 1900, 
				timeStruct.tm_mon+1, 
				timeStruct.tm_mday, 
				timeStruct.tm_hour, 
				timeStruct.tm_min, 
				timeStruct.tm_sec);

			sprintf_s(resultOutputFileName, "%s.avi", resultFileDate);
			vwOutputVideo_ = cvCreateVideoWriter(resultOutputFileName, CV_FOURCC('M','J','P','G'), 15, cvGetSize(currentFrame), 1);		
		}	
		cvWriteFrame(vwOutputVideo_, currentFrame);
		delete currentFrame;
	}
	displayImage.release();
}

/************************************************************************
 Method Name: GenerateConfigurations
 Description: 
	- 
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
void CPAPD::GenerateConfigurations(const int AffinityMatrix[][DPM_NUM_PART_TYPES])
{
	size_t numCandidateConfigurations = (size_t)std::pow(2.0, DPM_NUM_PART_TYPES - 2);
	configurations_.clear();
	configurations_.reserve(numCandidateConfigurations);

	CONFIGURATION baseConfiguration;
	baseConfiguration.partExist_[0] = true;	// root
	baseConfiguration.partExist_[1] = true;	// head
	baseConfiguration.numParts_ = 2;

	for (int cIdx = 0; cIdx < numCandidateConfigurations; cIdx++)
	{
		CONFIGURATION newConfiguration = baseConfiguration;
		int currentBit = 0x01 << (DPM_NUM_PART_TYPES - 3);
		for (int partIdx = 2; partIdx < DPM_NUM_PART_TYPES; partIdx++)
		{
			newConfiguration.partExist_[partIdx] = 0 < (cIdx & currentBit)? true : false;
			if (newConfiguration.partExist_[partIdx]) { newConfiguration.numParts_++; }
			currentBit = currentBit >> 1;
		}

		// check connectivity
		if (CheckConnectivityOfConfiguration(1, newConfiguration, AffinityMatrix, &baseConfiguration))
		{
			configurations_.push_back(newConfiguration);
		}
	}
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
bool CPAPD::CheckConnectivityOfConfiguration(
	const int startPartIndex,
	const CONFIGURATION &configuration, 
	const int AffinityMatrix[][DPM_NUM_PART_TYPES], 
	const CONFIGURATION *exception)
{	
	CONFIGURATION uncoveredPart = configuration;
	if (NULL != exception)
	{
		for (int pIdx = 0; pIdx < DPM_NUM_PART_TYPES; pIdx++)
		{
			uncoveredPart.partExist_[pIdx] &= !exception->partExist_[pIdx];
		}
	}

	// path finding
	std::deque<int> currParts; currParts.push_back(startPartIndex);
	std::deque<int> nextParts;
	while (0 < currParts.size())
	{
		for (std::deque<int>::iterator pIter = currParts.begin(); pIter != currParts.end(); pIter++)
		{
			uncoveredPart.partExist_[*pIter] = false;
			for (int partIdx = 0; partIdx < DPM_NUM_PART_TYPES; partIdx++)
			{
				if (!configuration.partExist_[partIdx] 
				|| 0 == AffinityMatrix[*pIter][partIdx] 
				|| 0 == uncoveredPart.partExist_[partIdx])
				{ continue; }
				nextParts.push_back(partIdx);
			}
		}
		currParts = nextParts;
		nextParts.clear();
	}

	// result
	for (int partIdx = 0; partIdx < DPM_NUM_PART_TYPES; partIdx++)
	{
		if (configuration.partExist_[partIdx] && uncoveredPart.partExist_[partIdx]) { return false; }
	}
	return true;
}

/************************************************************************
 Method Name: Clustering
 Description: 
	- clustering detections among their overlap ratio
 Input Arguments:
	- candidateDetections: detections for handling
	- outputClusters(output): result
	- vecNumPedestrianEstimation(output): 1 <- sole detection / 0 <- unknown number of detections
 Return Values:
	- none
************************************************************************/
void CPAPD::Clustering(const DetectionSet &candidateDetections, std::vector<DetectionSet> &outputClusters, std::vector<unsigned int> *vecNumPedestrianEstimation)
{
	for (int clusterIdx = 0; clusterIdx < outputClusters.size(); clusterIdx++) { outputClusters[clusterIdx].clear(); }
	outputClusters.clear();

	//---------------------------------------------------------
	// CLUSTERING TRACKS
	//---------------------------------------------------------   
	int newClusterLabel = 0;   
	std::vector<int> clusterLabels(candidateDetections.size(), -1);   
	for (int dIdx1 = 0; dIdx1 < candidateDetections.size(); dIdx1++)
	{
		if (0 > clusterLabels[dIdx1]) { clusterLabels[dIdx1] = newClusterLabel++; }

		int curLabel = clusterLabels[dIdx1];
		for (int dIdx2 = dIdx1+1; dIdx2 < candidateDetections.size(); dIdx2++)
		{			
			if (curLabel == clusterLabels[dIdx2]) { continue; }

			// check adjacency			
			if (!candidateDetections[dIdx1].CheckOverlap(candidateDetections[dIdx2], 0.0)) { continue; }

			// assign label
			if (0 > clusterLabels[dIdx2])
			{
				clusterLabels[dIdx2] = curLabel;
				continue;
			}

			// entire label refresh
			if (curLabel < clusterLabels[dIdx2])
			{
				for (int dIdx3 = 0; dIdx3 < candidateDetections.size(); dIdx3++)
				{
					if (clusterLabels[dIdx3] == clusterLabels[dIdx2]) { clusterLabels[dIdx3] = curLabel; }
				}
			}
			else
			{
				for (int dIdx3 = 0; dIdx3 < candidateDetections.size(); dIdx3++)
				{
					if (clusterLabels[dIdx3] == curLabel) { clusterLabels[dIdx3] = clusterLabels[dIdx2]; }
				}
				curLabel = clusterLabels[dIdx2];
			}
		}
	}

	// label sorting (element index / cluster index)
	std::vector<PAIR_UINT> vecPairsForSorting(candidateDetections.size());
	for (int detectIdx = 0; detectIdx < candidateDetections.size(); detectIdx++)
	{
		vecPairsForSorting[detectIdx].first = (unsigned int)detectIdx;
		vecPairsForSorting[detectIdx].second = (unsigned int)clusterLabels[detectIdx];
	}
	std::sort(vecPairsForSorting.begin(), vecPairsForSorting.end(), ClusterIDAscendComparator);

	// collect detections according to their clustering labels	
	outputClusters.resize(candidateDetections.size());
	outputClusters[0].push_back(candidateDetections[vecPairsForSorting[0].first]);
	int numCluster = 0;
	unsigned int prevLabel = vecPairsForSorting.front().second;   
	for (int detectIdx = 1; detectIdx < vecPairsForSorting.size(); detectIdx++)
	{
		if (vecPairsForSorting[detectIdx].second != prevLabel)
		{
			numCluster++;
			prevLabel = vecPairsForSorting[detectIdx].second;
		}
		outputClusters[numCluster].push_back(candidateDetections[vecPairsForSorting[detectIdx].first]);
	}
	outputClusters.erase(outputClusters.begin() + numCluster + 1, outputClusters.end());
	if (NULL == vecNumPedestrianEstimation) { return; }

	//---------------------------------------------------------
	// SINGLE HEAD CLUSTER PICK
	//---------------------------------------------------------  	
	// estimate the number of targets in each cluster
	vecNumPedestrianEstimation->resize(outputClusters.size(), 0);
	for (int clusterIdx = 0; clusterIdx < outputClusters.size(); clusterIdx++)
	{
		// heads of same components, or non-overlapped heads -> not sole head cluseter
		size_t numCurDetections = outputClusters[clusterIdx].size();
		bool bSoleHead = true;
		for (int d1 = 0; d1 < numCurDetections - 1; d1++)
		{
			for (int d2 = d1 + 1; d2 < numCurDetections; d2++)
			{
				// check component and overlap
				if (outputClusters[clusterIdx][d1].componentIndex_ == outputClusters[clusterIdx][d2].componentIndex_
				|| !outputClusters[clusterIdx][d1].parts_[1]->CheckOverlap(outputClusters[clusterIdx][d2].parts_[1], 0.0))
				{
					bSoleHead = false;
					break;
				}
			}
			if (!bSoleHead)	{ break; }
		}
		if (bSoleHead) { (*vecNumPedestrianEstimation)[clusterIdx] = 1; }
	}
}

/************************************************************************
 Method Name: GenerateCandidateDetections
 Description: 
	- 
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
void CPAPD::GenerateCandidateDetections(const DetectionSet &inputDetections, DetectionSet &outputDetections, const double minOcclusionRatio)
{	
	outputDetections.clear();

	for (int dIdx = 0; dIdx < inputDetections.size(); dIdx++)
	{
		//---------------------------------------------------------
		// NON-OCCLUDED PARTS
		//---------------------------------------------------------
		// must include a part that does not occluded by other detections
		CONFIGURATION mustIncluded;
		for (int partIdx = 0; partIdx < DPM_NUM_PART_TYPES; partIdx++)
		{
			mustIncluded.partExist_[partIdx] = true;
			for (int compDetectIdx = 0; compDetectIdx < inputDetections.size(); compDetectIdx++)
			{
				if (dIdx == compDetectIdx) { continue; }
				for (int compPartIdx = 0; compPartIdx < DPM_NUM_PART_TYPES; compPartIdx++)
				{
					if (inputDetections[dIdx].parts_[partIdx]->CheckOverlap(inputDetections[compDetectIdx].parts_[compPartIdx], minOcclusionRatio))
					{
						mustIncluded.partExist_[partIdx] = false;
						break;
					}
				}
				if (!mustIncluded.partExist_[partIdx]) { break; }
			}
		}

		//---------------------------------------------------------
		// ENUMERATION
		//---------------------------------------------------------
		DetectionSet newDetections; // save detections from current detection because of duplication check
		for (int cIdx = 0; cIdx < configurations_.size(); cIdx++)
		{
			CONFIGURATION curConfiguration = configurations_[cIdx] + mustIncluded;
			// check duplication
			bool bDuplicated = false;
			for (int compIdx = 0; compIdx < newDetections.size(); compIdx++)
			{
				if (newDetections[compIdx].configuration_ == curConfiguration)
				{
					bDuplicated = true;
					break;
				}
			}
			if (bDuplicated) { continue; }

			// generate detection instance
			CDetection newDetection = inputDetections[dIdx];
			newDetection.configuration_ = curConfiguration;
			//for (int partIdx = 0; partIdx < DPM_NUM_PART_TYPES; partIdx++)
			//{
			//	if (curConfiguration.partExist_[partIdx]) { continue; }
			//	newDetection.parts_[partIdx] = NULL;
			//}
			newDetection.totalScore_ = newDetection.GetTotalPartScore();
			for (int cIdx = 0; cIdx < NUM_CONNECT_TYPES; cIdx++)
			{
				if (!newDetection.configuration_.partExist_[newDetection.connections_[cIdx]->from]
				 || !newDetection.configuration_.partExist_[newDetection.connections_[cIdx]->to])
				{
					newDetection.connections_[cIdx] = NULL;
				}
			}
			// detectionScore_ does not changed
			newDetections.push_back(newDetection);
		}
		outputDetections.insert(outputDetections.end(), newDetections.begin(), newDetections.end());
	}
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
void CPAPD::ShowDetection(const cv::String strWindowName, const cv::Mat inputFrame, const CDetection &detection, int windowX, int windowY)
{
	cv::namedWindow(strWindowName);
	cv::moveWindow(strWindowName, windowX, windowY);
	cv::Rect cropZone = detection.parts_[DPM_ROOT]->coords_.rect();
	const int margin = 10;
	cropZone.x      = std::max(0, (int)(0.5 * (double)cropZone.x) - margin);
	cropZone.y      = std::max(0, (int)(0.5 * (double)cropZone.y) - margin);
	cropZone.width  = std::min(inputFrame.cols - cropZone.x, (int)(0.5 * (double)cropZone.width) + 2 * margin);
	cropZone.height = std::min(inputFrame.rows - cropZone.y, (int)(0.5 * (double)cropZone.height) + 2 * margin);
	cv::Mat displayImage = inputFrame(cropZone).clone();

	for (int pIdx = 0; pIdx < DPM_NUM_PART_TYPES; pIdx++)
	{
		if (!detection.configuration_.partExist_[pIdx]) { continue; }
		cv::Rect rescaledRect = detection.parts_[pIdx]->coords_.rect();
		rescaledRect.x      = (int)(0.5 * (double)rescaledRect.x) - cropZone.x;
		rescaledRect.y      = (int)(0.5 * (double)rescaledRect.y) - cropZone.y;
		rescaledRect.width  = (int)(0.5 * (double)rescaledRect.width);
		rescaledRect.height = (int)(0.5 * (double)rescaledRect.height);
		cv::rectangle(displayImage, rescaledRect, COLOR_PARULA[pIdx]);			
	}
	cv::imshow(strWindowName, displayImage);
	cv::waitKey(1);
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
void CPAPD::ShowDetections(const cv::String strWindowName, const cv::Mat inputFrame, const DetectionSet &detections, int windowX, int windowY)
{
	cv::namedWindow(strWindowName);
	cv::moveWindow(strWindowName, windowX, windowY);
	cv::Mat displayImage = inputFrame.clone();
	for (int dIdx = 0; dIdx < detections.size(); dIdx++)
	{
		for (int pIdx = 0; pIdx < DPM_NUM_PART_TYPES; pIdx++)
		{
			if (!detections[dIdx].configuration_.partExist_[pIdx]) { continue; }
			cv::Rect rescaledRect = detections[dIdx].parts_[pIdx]->coords_.rect();
			rescaledRect.x      = (int)(0.5 * (double)rescaledRect.x);
			rescaledRect.y      = (int)(0.5 * (double)rescaledRect.y);
			rescaledRect.width  = (int)(0.5 * (double)rescaledRect.width);
			rescaledRect.height = (int)(0.5 * (double)rescaledRect.height);
			cv::rectangle(displayImage, rescaledRect, COLOR_PARULA[pIdx]);			
		}
	}
	cv::imshow(strWindowName, displayImage);
	cv::waitKey(1);
}

/************************************************************************
 Method Name: ShowAssociations
 Description: 
	- 
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
void CPAPD::ShowAssociations(const cv::String strWindowName, const cv::Mat inputFrame, const DetectionSet &detections, int windowX, int windowY, cv::Mat *outputImage)
{	
	cv::Mat displayImage = inputFrame.clone();
	for (int dIdx = 0; dIdx < detections.size(); dIdx++)
	{
		for (int pIdx = DPM_ROOT+1; pIdx < DPM_NUM_PART_TYPES; pIdx++)
		{
			if (!detections[dIdx].configuration_.partExist_[pIdx]) { continue; }
			cv::Rect rescaledRect = detections[dIdx].parts_[pIdx]->coords_.rect();
			rescaledRect.x      = (int)(0.5 * (double)rescaledRect.x);
			rescaledRect.y      = (int)(0.5 * (double)rescaledRect.y);
			rescaledRect.width  = (int)(0.5 * (double)rescaledRect.width);
			rescaledRect.height = (int)(0.5 * (double)rescaledRect.height);
			hj::alphaRectangle(displayImage, rescaledRect, COLORS[dIdx]);
			cv::rectangle(displayImage, rescaledRect, COLORS[dIdx]);
		}
	}
	if (NULL == outputImage)
	{	
		cv::namedWindow(strWindowName);
		cv::moveWindow(strWindowName, windowX, windowY);
		cv::imshow(strWindowName, displayImage);		
		cv::waitKey(1);
	}
	else
	{
		if (!outputImage->empty()) { outputImage->release(); }
		*outputImage = displayImage.clone();
	}
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
bool CPAPD::SaveResult(const char *filepath, const DetectionSet &resultDetections)
{
	double x1 = 0.0, y1 = 0.0, x2 = 0.0, y2 = 0.0, globalDetectionProbability = 0.0, detectionScore = 0.0;
	try
	{
		FILE *fp;
		fopen_s(&fp, filepath, "w");
		for (int dIdx = 0; dIdx < resultDetections.size(); dIdx++)
		{
			x1 = resultDetections[dIdx].parts_[DPM_ROOT]->coords_.x1;
			x2 = resultDetections[dIdx].parts_[DPM_ROOT]->coords_.x2;
			y1 = resultDetections[dIdx].parts_[DPM_ROOT]->coords_.y1;
			y2 = resultDetections[dIdx].parts_[DPM_ROOT]->coords_.y2;
			//globalDetectionProbability = resultDetections[dIdx].globalDetectionProbability_;
			//fprintf_s(fp, "%f %f %f %f %f\n", x1, y1, x2, y2, globalDetectionProbability);
			detectionScore = resultDetections[dIdx].totalScore_;
			fprintf_s(fp, "%f %f %f %f %f\n", x1, y1, x2, y2, detectionScore);
		}
		fclose(fp);
	}
	catch (int nError)
	{
		printf("[ERROR] Error is occured at save result!!: %d\n", nError);
		return false;
	}
	return true;
}

//()()
//('')HAANJU.YOO

