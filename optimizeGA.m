clear all;
close all;
clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following weblinks may be useful:
% https://www.mathworks.com/help/gads/gamultiobj-algorithm.html#mw_6002e074-50fd-4796-9036-ed518d604365
% https://www.mathworks.com/help/gads/gamultiobj.html?s_tid=doc_ta
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set the paths
addpath('C:\\femm42\mfiles'); % If FEMM is not installed on C://femm42, 
                               % modify this to reflect FEMM path                           
dir = pwd;

% Helper function path
helperFolder = '\Helper functions';
helperPath = sprintf('%s%s',dir,helperFolder);
addpath(helperPath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%DO NOT CHANGE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A = []; % Linear inequality constraints (We keep this empty)
b = []; % Linear inequality constraints (We keep this empty)
Aeq = []; % Linear equality constraints (We keep this empty)
beq = []; % Linear equality constraints (We keep this empty)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Settings
settings.I_pk = 10; % Max current
settings.meshSize = 0.0005; % Max mesh element size
settings.steps = 36; % Number of steps each design is evaluated at
settings.frequency = 60; % Fundamental freq
settings.L_ref = 1e-3; % Reference inductor (the value we want)
settings.J = 10e6; % Max current density in A/mm^2
settings.k_p = 0.75; %Fill factor

%% Define the functions
fitnessFunction = @(chromosome)evaluateChromosome(chromosome, settings);% This will be the MATLAB function that evaluates each generation
constraint = @(chromosome)constraintFunction(chromosome, settings);
gaoutfun = @saveDesign; % This function saves designs at the end of each generation


%% Optimization variables and objectives
numVariables = 8; % Number of free variables
% variables: [t_T, t_Cu, t_C, w_E, w_C, d, g, AWG] 
% AWG is dimensionless; rest are in units of [meters]
boundsLo = [1e-3,  2.5e-3, 3e-3, 6e-3, 4e-3, 3e-3, 0.5e-3, 18]; % Lower bounds
boundsHi = [6e-3, 9e-3, 10e-3, 15e-3, 10e-3, 10e-3, 5e-3, 42];% Upper Bounds

numObj =3; %Number of objectives

%% Set the optimization options
generations = 50; % Set the number of generations
population = 100; % Set the population size (This is the number of individuals per generation)
initPop = []; % Initial population
options = optimoptions(@gamultiobj,'PlotFcn',@gaplotpareto, 'MaxGenerations',...
                        generations, 'InitialPopulationMatrix',initPop,'PopulationSize',...
                        population,'OutputFcn',gaoutfun,'UseParallel',1);

% optimoptions is used to set the optimization options for gamultiobj
% The plot function is selected as gaplotpareto (a default matlab function)

%% Run the optimization
[x,Fval,exitFlag,Output,population, scores] = gamultiobj(fitnessFunction,numVariables,A, ...
    b,Aeq,beq,boundsLo,boundsHi,constraint,options);

%% Save results
save('OptimizationResults.mat');

%% Plot the pareto front
%close all;
dotsize = 9;
plot_size = [0.25 2.5 2.3 1.75]; %You can change this to vary the plot size
figure(1)
scatter([Fval(:,1)], [Fval(:,2)],dotsize,'filled')
xlabel('$O_1$', 'Interpreter','latex','FontSize',6,...
            'FontName','TimesNewRoman');
ylabel('$O_2$', 'Interpreter','latex','FontSize',6,...
            'FontName','TimesNewRoman');      
set(gca,'FontName','TimesNewRoman','FontSize',6,'color', 'none');
set(gcf, 'PaperPositionMode', 'manual', 'PaperUnits', 'inches', 'PaperPosition', plot_size);
print('-dsvg','-noui','paretoPlot'); 
