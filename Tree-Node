select node,
case when parent_node is null then 'Root' else 
    (case when node in (select parent_node from Tree) then 'Inner' else 'Leaf' end) end as lk 
from tree_nodes;
