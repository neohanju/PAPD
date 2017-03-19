//#include "stdafx.h"
//#include "GraphSolver.h"
//
//int _tmain(int argc, _TCHAR* argv[])
//{
//	hj::Graph testGraph;
//	hj::VertexSet vertices = testGraph.AddVertices(3);
//	hj::Mat2D matQ(3, 3);
//	vertices[0]->weight = 8;
//	vertices[1]->weight = 7;
//	vertices[2]->weight = 3;
//	testGraph.AddEdge(vertices[0], vertices[2]);
//	matQ.at(1, 2) = 12;
//	matQ.at(0, 1) = 2;
//	
//
//	hj::CGraphSolver solver;
//	solver.Initialize(&testGraph, HJ_GRAPH_SOLVER_BLS4QP, matQ);
//	hj::stGraphSolvingResult *solvingResult = solver.Solve();
//
//	return 0;
//}
//
////()()
////('')HAANJU.YOO
//
