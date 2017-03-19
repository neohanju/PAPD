#include "ParameterParser.h"
#include <iostream>
#include <sstream>
#include <fstream>

const char strCommentStart = '%';
const char delim = '=';

CParameterParser::CParameterParser(void)
{
}


CParameterParser::~CParameterParser(void)
{
}

bool CParameterParser::ReadParams(const char *filepath, PARAM_SET &params)
{
	const int MAX_CHARS_PER_LINE = 10240;
	params.clear();

	// file reading object
	std::ifstream fstrIn;
	fstrIn.open(filepath);
	if (!fstrIn.good()) 
	{
		std::cerr << "Cannot find file <" << filepath << ">";
		return false; // exit if file not found
	}

	std::vector<std::string> lines;
	while (!fstrIn.eof())
	{
		char buf[MAX_CHARS_PER_LINE];
		fstrIn.getline(buf, MAX_CHARS_PER_LINE);
		if (strCommentStart == *buf || 0 == strlen(buf)) { continue; }
		
		std::stringstream ss(buf);
		std::string item;
		std::vector<std::string> tokens;
		
		while (std::getline(ss, item, delim))
		{
			tokens.push_back(item);
		}

		params.push_back(std::make_pair(tokens[0], tokens[1]));
	}
	fstrIn.close();

	return true;
}

//()()
//('')HAANJU.YOO

