#include "PartModel.h"
#include "ParameterParser.h"

/************************************************************************
 Method Name: 
 Description: 
	- 
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
CPartModel::CPartModel(void)
	: sbin_(8)
	, thresh_(-0.528783)
	, maxSize_(cv::Size(15, 5))
	, minSize_(cv::Size(15, 5))
	, interval_(10)
	, numBlocks_(28)
	, numComponents_(2)
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
CPartModel::~CPartModel(void)
{
}

/************************************************************************
 Method Name: LoadModel
 Description: 
	- 
 Input Arguments:
	- 
 Return Values:
	- 
************************************************************************/
bool CPartModel::LoadModel(const char *filepath)
{
	CParameterParser parser;
	PARAM_SET params;
	parser.ReadParams(filepath, params);

	for (int paramIdx = 0; paramIdx < params.size(); paramIdx++)
	{
		if      (0 == params[paramIdx].first.compare("sbin"))          { sbin_          = std::stod(params[paramIdx].second); }
		else if (0 == params[paramIdx].first.compare("thresh"))        { thresh_        = std::stod(params[paramIdx].second); }
		else if (0 == params[paramIdx].first.compare("interval"))      { interval_      = std::stoi(params[paramIdx].second); }
		else if (0 == params[paramIdx].first.compare("numblocks"))     { numBlocks_     = std::stoi(params[paramIdx].second); }
		else if (0 == params[paramIdx].first.compare("numcomponents")) { numComponents_ = std::stoi(params[paramIdx].second); }
		else if (0 == params[paramIdx].first.compare("numDefs"))
		{ 
			int numDefs = std::stoi(params[paramIdx].second);
			defs_.resize(numDefs);
			for (int defIdx = 0; defIdx < numDefs; defIdx++)
			{
				// w
				std::stringstream ssW(params[++paramIdx].second);
				std::string item;
				std::vector<std::string> tokens;
		
				while (std::getline(ssW, item, ',')) { tokens.push_back(item); }
				for (int wIdx = 0; wIdx < std::min((int)tokens.size(), 4); wIdx++)
				{
					defs_[defIdx].w[wIdx] = std::stod(tokens[wIdx]);
				}

				// blocklabel
				defs_[defIdx].blockLabel = std::stoi(params[++paramIdx].second);

				// anchor
				tokens.clear();
				std::stringstream ssAnchor(params[++paramIdx].second);
				while (std::getline(ssAnchor, item, ',')) { tokens.push_back(item); }
				defs_[defIdx].anchor = cv::Point2d(std::stod(tokens[0]), std::stod(tokens[1]));
			}
		}
	}

	return true;
}

//()()
//('')HAANJU.YOO
