clear all;
close all;
clc;

%% This is a test script that tests if the FEA works okay
dimensions.t_T = 3e-3;
dimensions.t_Cu = 4e-3;
dimensions.t_C = 5e-3;
dimensions.g = 1e-3;
dimensions.w_E = 13e-3;
dimensions.w_C = 9e-3;
dimensions.d = 4e-3;

winding.N_t = 10;
winding.gauge = 30;

settings.I_pk = 10;
settings.meshSize = 0.0005;
settings.steps = 5;
settings.frequency = 60;
settings.L_ref = 1e-3;
settings.J = 10;

[losses, force, volume, mass, Ind, Res] = evaluateInductorFEMM(dimensions, winding, settings);
