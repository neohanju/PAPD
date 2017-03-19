/******************************************************************************
 *                          MAIN for PAPD
 ******************************************************************************
 *               .__                           __.
 *                \ `\~~---..---~~~~~~--.---~~| /   
 *                 `~-.   `                   .~         _____ 
 *                     ~.                .--~~    .---~~~    /
 *                      / .-.      .-.      |  <~~        __/
 *                     |  |_|      |_|       \  \     .--'
 *                    /-.      -       .-.    |  \_   \_
 *                    \-'   -..-..-    `-'    |    \__  \_ 
 *                     `.                     |     _/  _/
 *                     ~-                .,-\   _/  _/
 *                      /                 -~~~~\ /_  /_
 *                     |               /   |    \  \_  \_ 
 *                     |   /          /   /      | _/  _/
 *                     |  |          |   /    .,-|/  _/ 
 *                     )__/           \_/    -~~~| _/
 *                       \                      /  \
 *                        |           |        /_---` 
 *                        \    .______|      ./
 *                        (   /        \    /
 *                        `--'          /__/
 *
 ******************************************************************************/
#include "stdafx.h"
#include "PAPD.h"

const char parameterFilePath[128] = "data\\parameters.txt";

int _tmain(int argc, _TCHAR* argv[])
{
	CParameterParser paramParser;
	PARAM_SET params;
	paramParser.ReadParams(parameterFilePath, params);
	
	// get parameters
	int startFrameIdx = 0;
	int endFrameIdx = 0;
	for (int paramIdx = 0; paramIdx < params.size(); paramIdx++)
	{
		if      (0 == params[paramIdx].first.compare("START_FRAME_IDX"))    { startFrameIdx = std::stoi(params[paramIdx].second); }
		else if (0 == params[paramIdx].first.compare("END_FRAME_IDX"))      { endFrameIdx   = std::stoi(params[paramIdx].second); }		
	}

	// initialization
	CPAPD PAPD;
	PAPD.Initialize(params);

	//---------------------------------------------------------
	// MAIN LOOP
	//---------------------------------------------------------
	
	for (int frameIdx = startFrameIdx; frameIdx <= endFrameIdx; frameIdx++)
	{
		printf("==========================================================\n");
		printf("= FRAME %04d\n", frameIdx);
		printf("==========================================================\n");
		PAPD.Run(frameIdx);
	}

	return 0;
}

//()()
//('')HAANJU.YOO


