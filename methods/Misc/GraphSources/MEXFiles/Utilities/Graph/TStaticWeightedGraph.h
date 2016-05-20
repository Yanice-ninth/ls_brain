/* 
	file:	TStaticGraph (.h & .cpp)
	class:	TStaticGraph
	This is a helper cass which can effectively import and - most importantly - browse directed graphs. 
	It is especially optimized to provide top speed for accessing nodes and the node neighbours. Most access operations 
	on the graph are performed in O(1), rather then O(log(N)), typicall for TDynamicGraph, which is optimized for both 
	insertion and access operations.

*/

#ifndef T_STATIC_WEIGHTED_GRAPH
#define T_STATIC_WEIGHTED_GRAPH
	#include "..\..\Utilities\Graph\TStaticGraph.h"	
class  TStaticWeightedGraph : public TStaticGraph {
public:
	TStaticWeightedGraph() :  TStaticGraph() {}
	TStaticWeightedGraph(const mxArray*	pInputGraph,const mxArray*	Direction);
		//  pInputGraph -	must contain the graph, created by MatLab's GraphLoad or related function.
		//  Direction	-	case - insensitive string having one of the following values: 'direct', 'inverse' or 'both'.
	TStaticWeightedGraph(const mxArray*	pInputGraph,EDirection	Direction);

	~TStaticWeightedGraph() {}

	const std::vector<unsigned int>& Neighbours(unsigned int Node) const { return FGraph[Node-1]; }
	const std::vector<double>& Weights(unsigned int Node) const { return FGraphWeights[Node-1]; }
	//std::multimap <unsigned int, unsigned int> Histogram
	// If 'Inverse' is true, the actual direction will be inverse of the provided one. Only applies to Direct and Inverse. Not to Both.
  	void Assign(const mxArray*	pInputGraph, const mxArray*	Direction,bool Inverse=false)		{	SetDir(GetDirection(Direction),Inverse); Assign(pInputGraph); }
	void Assign(const mxArray*	pInputGraph, EDirection Direction,bool Inverse=false)			{	SetDir(Direction,Inverse); Assign(pInputGraph); }
	virtual void Assign(const mxArray*	pInputGraph);
	virtual void Clear();
	virtual std::vector<unsigned int> GetAllNodesIDs() const;	// O( Number of Links*log(NumberOfNodes) ).

	unsigned int GetMaxNodeID() const { return (unsigned int)FGraph.size(); }

	// For each node, sorts it's links.
	void SortNodes();
	// returns list of node IDs sorted by their degree. Each element of the verctor contains  1. NodeID 2. Node Degree
	std::vector< std::pair<unsigned int, unsigned int> > GetNodesByDegree(bool Descending = true) const;

protected:

private:
	TStaticWeightedGraph(const TStaticGraph&); // Ensures efficiency of the code by preventing the user from accidently creating copies of the graph. 
	const TStaticWeightedGraph& operator=(const TStaticGraph&);

	std::vector< std::vector<double> > FGraphWeights;

};
#endif	// T_STATIC_WEIGHTED_GRAPH
