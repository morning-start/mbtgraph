export const hopcroftKarpGraph = {
  nodes: [
    { data: { id: '0', label: 'U₀' } },
    { data: { id: '1', label: 'U₁' } },
    { data: { id: '2', label: 'U₂' } },
    { data: { id: '3', label: 'V₀' } },
    { data: { id: '4', label: 'V₁' } },
    { data: { id: '5', label: 'V₂' } },
  ],
  edges: [
    { data: { id: 'e03', source: '0', target: '3' } },
    { data: { id: 'e04', source: '0', target: '4' } },
    { data: { id: 'e13', source: '1', target: '3' } },
    { data: { id: 'e14', source: '1', target: '4' } },
    { data: { id: 'e15', source: '1', target: '5' } },
    { data: { id: 'e24', source: '2', target: '4' } },
    { data: { id: 'e25', source: '2', target: '5' } },
  ],
  startNode: '0',
};
