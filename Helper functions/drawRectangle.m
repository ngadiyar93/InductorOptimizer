function drawRectangle(x,y,dim_w,dim_h,name,group,varargin)
% drawRectangle draws a rectange with the following properties
% x: x-coordinate of the bottom left vertex
% y: y-coordinate of the bottom left vertex
% dim_w: width
% dim_h: height
% name: Material name
% group: Group to which this block belongs
% The variable arguments enable setting boundary conditions, magnet 
% direction, circuit properties and many more. Ref: FEMM scripting manual.

p = inputParser;
addRequired(p,'x');
addRequired(p,'y');
addRequired(p,'dim_w');
addRequired(p,'dim_h');
addRequired(p,'name');
addRequired(p,'group');
addParameter(p,'incircuit','None');
addParameter(p,'magdir',0);
addParameter(p,'turns',0);
addParameter(p,'leftbc','none');
addParameter(p,'topbc','none');
addParameter(p,'rightbc','none');
addParameter(p,'botbc','none');
addParameter(p,'automesh',1);
addParameter(p,'meshsize',0.5);
parse(p,x,y,dim_w,dim_h,name,group,varargin{:});

mi_addnode(x,y);
mi_addnode(x+dim_w,y);
mi_addnode(x,y+dim_h);
mi_addnode(x+dim_w,y+dim_h);
mi_addsegment(x,y,x+dim_w,y);
mi_selectsegment(x+0.5*dim_w,y);
mi_setsegmentprop(p.Results.botbc, 0, 1, 0, group)
mi_clearselected();
mi_addsegment(x,y+dim_h,x+dim_w,y+dim_h);
mi_selectsegment(x+0.5*dim_w,y+dim_h);
mi_setsegmentprop(p.Results.topbc, 0, 1, 0, group)
mi_clearselected();
mi_addsegment(x,y,x,y+dim_h);
mi_selectsegment(x,y+0.5*dim_h);
mi_setsegmentprop(p.Results.leftbc, 0, 1, 0, group)
mi_clearselected();
mi_addsegment(x+dim_w,y,x+dim_w,y+dim_h);
mi_selectsegment(x+dim_w,y+0.5*dim_h);
mi_setsegmentprop(p.Results.rightbc, 0, 1, 0, group)
mi_clearselected();
mi_addblocklabel(x+0.5*dim_w,y+0.5*dim_h);
mi_selectlabel(x+0.5*dim_w,y+0.5*dim_h);
mi_setblockprop(name,p.Results.automesh,p.Results.meshsize,p.Results.incircuit, p.Results.magdir,group,p.Results.turns);
mi_clearselected();
end
