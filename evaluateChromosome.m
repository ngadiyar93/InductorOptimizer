function [evaluatedChrom] = evaluateChromosome(chromosome, settings)
    % SYNTAX
    % evaluatedChrom = evaluateChromosome(chromosome, settings)
    %
    % DESCRIPTION
    % Evaluates a chromosome
    %
    % REQUIRED ARGUMENTS
    % chromosome: Individual chromosome
    % settings: constants etc
    %
    %
    % OUTPUT VARIABLES
    % evaluatedChrom: Results after evaluating the chromosome.
    %% Initialize objectives
    O_1 = 0;
    O_2 = 0;
    O_3 = 0;
    
   %% Core selection
   dimensions = selectCore(chromosome);
   
   winding = selectWinding(chromosome, dimensions, settings);
   
   %% FEA evaluation
    [losses, force, volume, mass, Ind, Res]  = evaluateAFPM(dimensions,...
                                     winding, settings);
               
   %% Objective function Evaluation       
   
   if (abs(Ind - settings.L_ref) < 1e-6) % 1uH tolerance
        O_1 = losses.Ecore, losses.Icore + settings.I_pk^2*Res; % Total losses
        
        O_2 = mass; % Mass

        O_3 = max(abs(force)); % Force on I core
        
   else
        O_1 = inf; % Total losses
        
        O_2 = inf; % Mass

        O_3 = inf; % Force on I core
end