#pragma once
#include "cv.h"
#include "hjlib.h"

typedef std::pair<unsigned int, unsigned int> PAIR_UINT;

typedef enum {
	DPM_ROOT = 0,	DPM_HEAD,	DPM_FOOT_L,
	DPM_SHOULDER_R,	DPM_GROIN,	DPM_SHOULDER_L,
	DPM_ARM_R,		DPM_ARM_L,	DPM_FOOT_R,
	DPM_NUM_PART_TYPES
} DPM_PART_TYPE;

struct PART_CONNECT
{
	DPM_PART_TYPE    from;
	DPM_PART_TYPE    to;
	hj::LINE_SEGMENT connectionLine;
};

typedef enum {
	CONNECT_HEAD_GROIN = 0, CONNECT_HEAD_SL,
	CONNECT_HEAD_SR,        CONNECT_SL_SR,
	CONNECT_SL_AL,          CONNECT_SR_AR,
	CONNECT_GROIN_FL,       CONNECT_GROIN_FR,
	CONNECT_HEAD_FL,        CONNECT_HEAD_FR,
	NUM_CONNECT_TYPES
} CONNECT_TYPE;

const PART_CONNECT DEFAULT_CONNECT[NUM_CONNECT_TYPES] = {
	{DPM_HEAD,       DPM_GROIN,      std::make_pair(cv::Point2d(0.0, 0.0), cv::Point2d(0.0, 0.0))},
	{DPM_HEAD,       DPM_SHOULDER_L, std::make_pair(cv::Point2d(0.0, 0.0), cv::Point2d(0.0, 0.0))},
	{DPM_HEAD,       DPM_SHOULDER_R, std::make_pair(cv::Point2d(0.0, 0.0), cv::Point2d(0.0, 0.0))},
	{DPM_SHOULDER_L, DPM_SHOULDER_R, std::make_pair(cv::Point2d(0.0, 0.0), cv::Point2d(0.0, 0.0))},
	{DPM_SHOULDER_L, DPM_ARM_L,      std::make_pair(cv::Point2d(0.0, 0.0), cv::Point2d(0.0, 0.0))},
	{DPM_SHOULDER_R, DPM_ARM_R,      std::make_pair(cv::Point2d(0.0, 0.0), cv::Point2d(0.0, 0.0))},
	{DPM_GROIN,      DPM_FOOT_L,     std::make_pair(cv::Point2d(0.0, 0.0), cv::Point2d(0.0, 0.0))},
	{DPM_GROIN,      DPM_FOOT_R,     std::make_pair(cv::Point2d(0.0, 0.0), cv::Point2d(0.0, 0.0))},
	{DPM_HEAD,       DPM_FOOT_L,     std::make_pair(cv::Point2d(0.0, 0.0), cv::Point2d(0.0, 0.0))},
	{DPM_HEAD,       DPM_FOOT_R,     std::make_pair(cv::Point2d(0.0, 0.0), cv::Point2d(0.0, 0.0))}
};

typedef enum { DPM_COMPONENT_R = 0, DPM_COMPONENT_L, DPM_NUM_COMPONENTS } DPM_COMPONENT;
 //    2
 // 4     6
 // 7     8
 //    5
 //  9   3

//()()
//('')HAANJU.YOO
