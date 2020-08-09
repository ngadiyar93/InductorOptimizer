function[state,options,changed] = saveDesign(options,state,~)
% SAVEDESIGN is the user defined output function for the optimization that
% gets called after each generation is evaluated. More info and example 
% here:
% https://www.mathworks.com/help/gads/custom-output-function-for-genetic-algorithm.html
changed = false;
data.generation = state.Generation;
data.population = state.Population;
data.ceq = state.Ceq;
data.c = state.C;
data.score = state.Score;
gen = state.Generation;
filename = ['gen_',num2str(gen),'data.mat'];
save(filename,'data');
fprintf('Generation %d evaluated and saved\n', gen);
end