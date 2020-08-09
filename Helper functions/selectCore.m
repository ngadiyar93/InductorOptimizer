function dimensions = selectCore(chromosome)
% SELECTCORE is used to select the core from the lookuptable and return 
% the dimensions per the parameterization

load('InductorData.mat');

coreLength = 1e-3*(2*(chromosome(1)+chromosome(2))+chromosome(3));

for i=1:5
    errArray(i) = abs(coreLength-InductorData(i,2));
end

minerr = min(errArray);
a = find(minerr);

dims = InductorData(a,:);

dimensions.t_T = 1e-3*(dims(2)-dims(6))/2;
dimensions.t_Cu = 1e-3*(dims(6)-dims(7))/2;
dimensions.t_C = dims(7)*1e-3;
dimensions.g = chromosome(7);
dimensions.w_E = dims(3)*1e-3;
dimensions.w_C = dims(5).1e-3;
dimensions.d = dims(4)*1e-3;

end
