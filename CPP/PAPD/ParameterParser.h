#pragma once

#include <vector>
#include <string>

typedef std::pair<std::string, std::string> PARAM_PAIR;
typedef std::vector<PARAM_PAIR> PARAM_SET;

class CParameterParser
{
public:
	CParameterParser(void);
	~CParameterParser(void);

	bool ReadParams(const char *filepath, PARAM_SET &params);
};

//()()
//('')HAANJU.YOO

