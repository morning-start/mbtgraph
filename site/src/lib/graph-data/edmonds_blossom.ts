export const edmondsBlossomGraph = {
  nodes: [
    { data: { id: '0', label: 'A' } },
    { data: { id: '1', label: 'B' } },
    { data: { id: '2', label: 'C' } },
    { data: { id: '3', label: 'D' } },
    { data: { id: '4', label: 'E' } },
    { data: { id: '5', label: 'F' } },
  ],
  edges: [
    { data: { id: 'e01', source: '0', target: '1' } },
    { data: { id: 'e02', source: '0', target: '2' } },
    { data: { id: 'e12', source: '1', target: '2' } },
    { data: { id: 'e23', source: '2', target: '3' } },
    { data: { id: 'e34', source: '3', target: '4' } },
    { data: { id: 'e35', source: '3', target: '5' } },
    { data: { id: 'e45', source: '4', target: '5' } },
  ],
  startNode: '0',
};
