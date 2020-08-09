function drawLine(x1, y1, x2, y2)
% drawLine draws a line between nodes (x1,y1) and (x2,y2)
mi_addnode(x1,y1)
mi_addnode(x2,y2)
mi_addsegment(x1,y1,x2,y2)
end
